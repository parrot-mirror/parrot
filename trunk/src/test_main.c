/* test_main.c
 *  Copyright: (When this is determined...it will go here)
 *  CVS Info
 *     $Id$
 *  Overview:
 *     A sample test program
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#include "parrot/parrot.h"

int
main(int argc, char **argv) {
    int i;
    int tracing;
    int bounds_checking;

    struct Parrot_Interp *interpreter;
    init_world();
  
    interpreter = make_interpreter();
    
    /*
    ** Look for the '-t' tracing and '-b' bounds checking switches.
    ** We really should use getopt, but are we allowed?
    */

    tracing         = 0;
    bounds_checking = 0;

    while (argc > 1 && argv[1][0] == '-') {
        if (argv[1][1] == 't' && argv[1][2] == '\0') {
            tracing = 1;
            for(i = 2; i < argc; i++) {
                argv[i-1] = argv[i];
            }
            argc--;
        }
        else if (argv[1][1] == 'b' && argv[1][2] == '\0') {
            bounds_checking = 1;
            for(i = 2; i < argc; i++) {
                argv[i-1] = argv[i];
            }
            argc--;
        }
    }

    /* If we got only the program name, complain */
    if (argc == 1) {
        fprintf(stderr, "%s: usage: %s prog\n", argv[0], argv[0]);
        exit(1);
    }
    else if (argc == 2 && !strcmp(argv[1], "-s")) { /* String tests */
        STRING *s = string_make("foo", 3, enc_native, 0, 0);
        STRING *t = string_make("quux", 4, enc_native, 0, 0);
        int i;
        time_t foo;
        
        printf("String %p has length %i: %.*s\n", (void *) s, 
                (int) string_length(s), s->bufused,
                (char *) s->bufstart);
        string_concat(s, t, 0);
        printf("String %p has length %i: %.*s\n", (void *) s, 
                (int) string_length(s), s->bufused,
                (char *) s->bufstart);
        string_chopn(s, 4);
        printf("String %p has length %i: %.*s\n", (void *) s, 
                (int) string_length(s), s->bufused,
                (char *) s->bufstart);
        string_chopn(s, 4);
        printf("String %p has length %i: %.*s\n", (void *) s, 
                (int) string_length(s), s->bufused,
                (char *) s->bufstart);

        foo = time(0);
        for (i = 0; i < 100000000; i++) {
            string_concat(s, t, 0);
            string_chopn(s, 4);
        }
        printf("10000000 concats and chops took %li seconds.\n", time(0)-foo);
        string_destroy(s);
    }
    /* Otherwise load in the program they gave and try that */
    else {
        opcode_t *program_code;        
        long program_size;
        struct stat file_stat;
        int fd;
        struct PackFile * pf;

        if (stat(argv[1], &file_stat)) {
            printf("can't stat %s, code %i\n", argv[1], errno);
            return 1;
        }
        fd = open(argv[1], O_RDONLY);
        if (!fd) {
            printf("Can't open, error %i\n", errno);
            return 1;
        }
        
        program_size = file_stat.st_size;

#ifndef HAS_HEADER_SYSMMAN
        program_code = (opcode_t*)mem_sys_allocate(program_size);
        read(fd, (void*)program_code, program_size);
#else
        program_code = (opcode_t*)mmap(0, program_size, PROT_READ, MAP_SHARED, fd, 0);
#endif

        if (!program_code) {
            printf("Can't mmap, code %i\n", errno);
            return 1;
        }
        
        pf = PackFile_new();
        if( !PackFile_unpack(pf, (char *)program_code, program_size) ) {
            printf( "Can't unpack.\n" );
            return 1;
        }

        if (tracing) {
            interpreter->flags |= PARROT_TRACE_FLAG;
        }

        if (bounds_checking) {
            interpreter->flags |= PARROT_BOUNDS_FLAG;
        }

        runops(interpreter, pf);
        
    }
    return 0;
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
