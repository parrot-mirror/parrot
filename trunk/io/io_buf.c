/* io_buf.c
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *      $Id$
 *  Overview:
 *      The "buf" layer of Parrot IO. Buffering and all the fun stuff.
 *
 *  Data Structure and Algorithms:
 *  History:
 *      Initially written by Melvin Smith
 *  Notes:
 *  References:
 *      Some ideas from AT&T SFIO
 */

#include "parrot/parrot.h"

/* Defined at bottom */
extern ParrotIOLayerAPI pio_buf_layer_api;

ParrotIOLayer pio_buf_layer = {
    NULL,
    "buf",
    PIO_L_TERMINAL,
    &pio_buf_layer_api,
    0, 0
};

/*
 * Currently keeping layer prototypes local to each layer
 * file.
 */

INTVAL PIO_buf_init(theINTERP, ParrotIOLayer *l);
ParrotIO *PIO_buf_open(theINTERP, ParrotIOLayer *l,
                         const char *path, INTVAL flags);
INTVAL PIO_buf_setbuf(theINTERP, ParrotIOLayer *l,
                        ParrotIO *io, size_t bufsize);
INTVAL PIO_buf_setlinebuf(theINTERP, ParrotIOLayer *l, ParrotIO *io);
ParrotIO *PIO_buf_fdopen(theINTERP, ParrotIOLayer *l,
                           PIOHANDLE fd, INTVAL flags);
INTVAL PIO_buf_close(theINTERP, ParrotIOLayer *l, ParrotIO *io);
INTVAL PIO_buf_flush(theINTERP, ParrotIOLayer *l, ParrotIO *io);
size_t PIO_buf_read(theINTERP, ParrotIOLayer *l,
                      ParrotIO *io, void *buffer, size_t len);
size_t PIO_buf_write(theINTERP, ParrotIOLayer *l,
                       ParrotIO *io, const void *buffer, size_t len);
INTVAL PIO_buf_puts(theINTERP, ParrotIOLayer *l, ParrotIO *io,
                      const char *s);
INTVAL PIO_buf_seek(theINTERP, ParrotIOLayer *l, ParrotIO *io,
                      INTVAL hi, INTVAL lo, INTVAL whence);
PIOOFF_T PIO_buf_tell(theINTERP, ParrotIOLayer *l, ParrotIO *io);


/* Local util functions */
size_t PIO_buf_writethru(theINTERP, ParrotIOLayer *layer,
                           ParrotIO *io, const void *buffer, size_t len);




INTVAL
PIO_buf_init(theINTERP, ParrotIOLayer *layer)
{
    if (PIO_STDOUT(interpreter))
        PIO_buf_setlinebuf(interpreter, layer, PIO_STDOUT(interpreter));
    if (PIO_STDIN(interpreter))
        PIO_buf_setbuf(interpreter, layer, PIO_STDIN(interpreter),
                         PIO_UNBOUND);
    return 0;
}


ParrotIO *
PIO_buf_open(theINTERP, ParrotIOLayer *layer,
               const char *path, INTVAL flags)
{
    ParrotIO *io;
    ParrotIOLayer *l = layer;
    while (l) {
        l = PIO_DOWNLAYER(l);
        if (l && l->api->Open) break;
    }
    if (!l) {
        /* Now underlying layer found */
        return NULL;
    }

    io = (*l->api->Open) (interpreter, l, path, flags);
    /*
     * We have an IO stream now setup stuff
     * for our layer before returning it.
     */
    PIO_buf_setbuf(interpreter, l, io, PIO_UNBOUND);
    return io;
}


/*
 * Don't pass setbuf() calls down the stack, top layer wins.
 * This doesn't mean other layers can't buffer, I just to
 * think about the mechanism for buffer control or if it even
 * makes sense this way. Most layers will not implement setbuf()...
 */
INTVAL
PIO_buf_setbuf(theINTERP, ParrotIOLayer *layer, ParrotIO *io, size_t bufsize)
{
    ParrotIOLayer *l = layer;
    ParrotIOBuf *b = &io->b;
    /* If there is a buffer, make sure we flush before
     * dinking around with the buffer.
     */
    if (b->startb)
        PIO_buf_flush(interpreter, l, io);

    /* Choose an appropriate buffer size for caller */
    if (bufsize == PIO_UNBOUND) {
        b->size = PIO_getblksize(io->fd);
    }
    else {
        b->size = (bufsize >= PIO_GRAIN ? bufsize : PIO_GRAIN);
    }

    if (b->startb && (b->flags & PIO_BF_MALLOC)) {
        free(b->startb);
        b->startb = b->next = NULL;
    }

    if (b->size > 0) {
        b->startb = b->next = malloc(b->size);
        b->flags |= PIO_BF_MALLOC;
    }

    if (bufsize != 0)
        io->flags |= PIO_F_BLKBUF;
    else
        io->flags &= ~(PIO_F_BLKBUF | PIO_F_LINEBUF);

    return 0;
}


INTVAL
PIO_buf_setlinebuf(theINTERP, ParrotIOLayer *l, ParrotIO *io)
{
    /* Reuse setbuf call */
    int err;
    if ((err = PIO_buf_setbuf(interpreter, l, io, PIO_LINEBUFSIZE)) >= 0) {
        /* Then switch to linebuf */
        io->flags &= ~PIO_F_BLKBUF;
        io->flags |= PIO_F_LINEBUF;
        return 0;
    }
    return err;
}


ParrotIO *
PIO_buf_fdopen(theINTERP, ParrotIOLayer *layer, PIOHANDLE fd, INTVAL flags)
{
    ParrotIO *io;
    ParrotIOLayer *l = PIO_DOWNLAYER(layer);
    while (l) {
        if (l->api->FDOpen) {
            io = (*l->api->FDOpen) (interpreter, l, fd, flags);
            if (PIO_isatty(fd))
                PIO_buf_setlinebuf(interpreter, l, io);
            else
                PIO_buf_setbuf(interpreter, l, io, PIO_UNBOUND);
            return io;
        }
        l = PIO_DOWNLAYER(l);
    }
    return NULL;
}


INTVAL
PIO_buf_close(theINTERP, ParrotIOLayer *layer, ParrotIO *io)
{
    ParrotIOLayer *l = PIO_DOWNLAYER(layer);
    PIO_buf_flush(interpreter, layer, io);
    while (l) {
        if (l->api->Close) {
            return (*l->api->Close) (interpreter, l, io);
        }
        l = PIO_DOWNLAYER(l);
    }
    return 0;
}


INTVAL
PIO_buf_flush(theINTERP, ParrotIOLayer *layer, ParrotIO *io)
{
    long wrote;
    size_t to_write;
    /*
     * Either buffering is null, disabled, or empty.
     */
    if (!io->b.startb
        || (io->flags & (PIO_F_BLKBUF | PIO_F_LINEBUF)) == 0
        || (io->b.flags & (PIO_BF_WRITEBUF | PIO_BF_READBUF)) == 0)
        return 0;
    /*
     * Write flush
     */
    if (io->b.flags & PIO_BF_WRITEBUF) {
        ParrotIOLayer *l = layer;
        to_write = io->b.next - io->b.startb;

        /* Flush to next layer */
        wrote = PIO_buf_writethru(interpreter, l, io,
                                    io->b.startb, to_write);
        if (wrote == (long)to_write) {
            io->b.next = io->b.startb;
            /* Release buffer */
            io->b.flags &= ~PIO_BF_WRITEBUF;
            return 0;
        }
        else {
            /* FIXME: I/O Error */
        }
    }
    else {
        /* Read flush */
        io->b.flags &= ~PIO_BF_READBUF;
        io->b.next = io->b.startb;
    }
    return -1;
}


size_t
PIO_buf_read(theINTERP, ParrotIOLayer *layer, ParrotIO *io,
               void *buffer, size_t len)
{
    UNUSED(interpreter);
    UNUSED(layer);
    UNUSED(io);
    UNUSED(buffer);
    UNUSED(len);
    return 0;
}


size_t
PIO_buf_write(theINTERP, ParrotIOLayer *layer, ParrotIO *io,
                const void *buffer, size_t len)
{
    size_t avail;
    long wrote;

    if (len <= 0)
        return 0;
    if (io->b.flags & PIO_BF_WRITEBUF) {
        avail = io->b.size - (io->b.next - io->b.startb);
    }
    else if (io->b.flags & PIO_BF_READBUF) {
        io->b.flags &= ~PIO_BF_READBUF;
        io->b.next = io->b.startb;
        avail = io->b.size;
    }
    else {
        avail = io->b.size;
    }

    /*
     * Large writes (multiples of blocksize) should write
     * through generally for best performance, else you are
     * just doing extra memcpys.
     * FIXME: This is badly optimized, will fixup later.
     */
    if (len >= io->b.size) {
        /* Write through, skip buffer. */
        PIO_buf_flush(interpreter, layer, io);
        wrote = PIO_buf_writethru(interpreter, layer, io, buffer, len);
        if (wrote == (long)len)
            return wrote;
        else {
            /* FIXME: Write error */
        }
    }
    else if (avail > len) {
        io->b.flags |= PIO_BF_WRITEBUF;
        memcpy(io->b.next, buffer, len);
        io->b.next += len;
        return len;
    }
    else {
        unsigned int diff = (int)(len - avail);

        io->b.flags |= PIO_BF_WRITEBUF;
        /* Fill remainder, flush, then try to buffer more */
        memcpy(io->b.next, buffer, diff);
        /* We don't call flush here because it clears flag */
        PIO_buf_flush(interpreter, layer, io);
        memcpy(io->b.startb, ((const char *)buffer + diff), len - diff);
        io->b.next = io->b.startb + (len - diff);
        return len;
    }
    return (size_t)-1;
}


/*
 * Skip buffers, write through.
 * PIO_buf_flush() should directly precede a call to this func.
 */
size_t
PIO_buf_writethru(theINTERP, ParrotIOLayer *layer,
                    ParrotIO *io, const void *buffer, size_t len)
{
    ParrotIOLayer *l;
    l = layer;
    while ((l = PIO_DOWNLAYER(l)) != NULL) {
        if (l->api->Write)
            return (*l->api->Write) (interpreter, l, io, buffer, len);
    }
    return (size_t)-1;
}


INTVAL
PIO_buf_puts(theINTERP, ParrotIOLayer *layer, ParrotIO *io, const char *s)
{
    ParrotIOLayer *l = layer;
    while ((l = PIO_DOWNLAYER(l)) != NULL) {
        if (l->api->PutS) {
            return (*l->api->PutS) (interpreter, l, io, s);
        }
    }
    return 0;
}


INTVAL
PIO_buf_seek(theINTERP, ParrotIOLayer *l, ParrotIO *io,
               INTVAL hi, INTVAL lo, INTVAL whence)
{
    int hardseek = 0;
    UNUSED(hardseek)

        if (io->flags & PIO_F_SHARED ||
            !(io->flags & (PIO_F_BLKBUF | PIO_F_LINEBUF))) {
        hardseek = 1;
    }

    if (io->b.flags & (PIO_BF_READBUF | PIO_BF_WRITEBUF)) {
        /* FIXME: Flush on seek for now */
        PIO_buf_flush(interpreter, l, io);
    }

    /*
     * TODO : Try to satisfy seek request in buffer if possible,
     * else make IO request.
     */
    internal_exception(PIO_NOT_IMPLEMENTED, "Seek not implemented");
    return -1;
}


PIOOFF_T
PIO_buf_tell(theINTERP, ParrotIOLayer *l, ParrotIO *io)
{
    return io->fpos;
}



ParrotIOLayerAPI pio_buf_layer_api = {
    PIO_buf_init,
    PIO_base_new_layer,
    PIO_base_delete_layer,
    PIO_null_push_layer,
    PIO_null_pop_layer,
    PIO_buf_open,
    PIO_null_open2,
    PIO_null_open3,
    PIO_null_open_async,
    PIO_buf_fdopen,
    PIO_buf_close,
    PIO_buf_write,
    PIO_null_write_async,
    PIO_buf_read,
    PIO_null_read_async,
    PIO_buf_flush,
    PIO_null_seek,
    PIO_null_tell,
    PIO_buf_setbuf,
    PIO_buf_setlinebuf,
    PIO_null_getcount,
    PIO_null_fill,
    PIO_buf_puts,
    PIO_null_gets,
    PIO_null_eof
};



/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
