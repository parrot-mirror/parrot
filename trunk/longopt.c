/* longopt.c
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#include "parrot/parrot.h"
#include "parrot/longopt.h"

static int longopt_get_longopt(Parrot_Interp, int argc, const char* argv[],
                               const struct longopt_opt_decl options[],
                               struct longopt_opt_info* info_buf);

static int longopt_get_shortopt(Parrot_Interp, int argc, const char* argv[],
                                const struct longopt_opt_decl options[],
                                struct longopt_opt_info* info_buf);

static char longopt_error_buffer[512];

/* longopt_get:  Gets long or short options, specified
 * in options[] (see longopt.dev).  Call it iteratively
 * with the same info_buf until it returns 0 or -1.
 * 0  means end of options.
 * -1 means error, with error put in info_buf->opt_error
 * Any other value is a valid option id.
 */
int
longopt_get(Parrot_Interp interp, int argc, const char* argv[],
            const struct longopt_opt_decl options[],
            struct longopt_opt_info* info_buf)
{
    int dex = info_buf->opt_index;
    
    info_buf->opt_id = 0;
    info_buf->opt_arg = info_buf->opt_error = NULL;

    if (dex >= argc || argv[dex] == NULL)
        return 0;

    if (argv[dex][0] != '-'
     || argv[dex][1] == '\0')
        return 0;

    if (info_buf->_shortopt_pos)
        return longopt_get_shortopt(interp, argc, argv, options, info_buf);
    
    if (argv[dex][1] == '-') { /* Long option or -- */
        if (argv[dex][2] == '\0') {
            ++info_buf->opt_index;
            return 0;
        }
        else {                   /* Long option */
            return longopt_get_longopt(interp, argc, argv, options, info_buf);
        }
    }
    else {                       /* Short option */
        return longopt_get_shortopt(interp, argc, argv, options, info_buf);
    }
}


/* longopt_get_longopt: Find the option id of a long option.
 * Fill info_buf appropriately, and return the option id.
 * argv[info_buf->opt_index] is guaranteed to have at least
 * three characters and start with --.
 */
static int
longopt_get_longopt(Parrot_Interp interp, int argc, const char* argv[],
                    const struct longopt_opt_decl options[],
                    struct longopt_opt_info* info_buf)
{
    int dex = info_buf->opt_index; 
    int optlen = 0;
    const struct longopt_opt_decl* dptr;
    
    while (argv[dex][optlen] != '\0' && argv[dex][optlen] != '=') {
        optlen++;
    }
   
    for (dptr = options; dptr->opt_id; dptr++) {
        int sptr;
        /* For each listed long option... */
        for (sptr = 0; dptr->opt_long[sptr]; sptr++) {
            if (strncmp(dptr->opt_long[sptr], argv[dex], optlen) == 0
             && dptr->opt_long[sptr][optlen] == '\0') {
                /* Found it */
                info_buf->opt_id = dptr->opt_id;
                ++info_buf->opt_index;
                
                /* XXX: (LP) if a longopt is given an argument when it's
                 * not expecting one, it is just ignored.  Bad. */

                if (dptr->opt_flags & OPTION_required_FLAG) {
                    if (argv[dex][optlen] == '=') {
                        info_buf->opt_arg = &argv[dex][optlen+1];
                    }
                    else {
                        info_buf->opt_arg = argv[dex+1];
                        ++info_buf->opt_index;
                    }
                }
                
                return dptr->opt_id;
            } 
        }
    }

    /* Couldn't find it. */
    info_buf->opt_id = -1;
    Parrot_snprintf(interp, longopt_error_buffer, 512, 
             "Option %s not known", argv[dex]);
    info_buf->opt_error = longopt_error_buffer;
    return -1;
}

/* longopt_get_shortopt: Find the option id of the next short option.
 * This next short option may be in the middle of a bundle (-abcd),
 * and info_buf->_shortopt_pos maintains a pointer into that bundle.
 * argv[info_buf->opt_index] is guaranteed to be at least two characters
 * long and start with a dash.
 */
static int 
longopt_get_shortopt(Parrot_Interp interp, int argc, const char* argv[],
                     const struct longopt_opt_decl options[],
                     struct longopt_opt_info* info_buf)
{
    int dex = info_buf->opt_index;
    const struct longopt_opt_decl* dptr;
    const char* pos;


    if (!info_buf->_shortopt_pos)
        info_buf->_shortopt_pos = &argv[dex][1];
    pos = info_buf->_shortopt_pos;

    for (dptr = options; dptr->opt_id; dptr++) {
        if (dptr->opt_short == *pos) {
            /* Found it */
            info_buf->opt_id = dptr->opt_id;
            
            if (dptr->opt_flags & OPTION_required_FLAG) {
                if (*(pos + 1)) {
                    info_buf->opt_arg = pos + 1;
                }
                else {
                    info_buf->opt_arg = argv[dex+1];
                }
                info_buf->_shortopt_pos = NULL;
                ++info_buf->opt_index;
            }
            else {             /* No argument expected */
                if (! *(pos + 1)) {
                    info_buf->_shortopt_pos = NULL;
                    ++info_buf->opt_index;
                }
                else {
                    ++info_buf->_shortopt_pos;
                }
            }
            
            return dptr->opt_id;
        }
    }
    
    /* Couldn't find it in the table */
    info_buf->opt_id = -1;
    Parrot_snprintf(interp, longopt_error_buffer, 512, 
             "Option -%c not known", *pos);
    info_buf->opt_error = longopt_error_buffer; 
    return -1;
}


/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
 */
