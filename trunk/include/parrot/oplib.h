/* oplib.h
 *  Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
 *  CVS Info
 *     $Id$
 *  Overview:
 *     Header file for op libraries.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#if !defined(PARROT_OPLIB_H_GUARD)
#define PARROT_OPLIB_H_GUARD

#include "parrot/config.h"
#include "parrot/op.h"


/*
** op_lib_t
*/

typedef struct {
    const char *name;
    INTVAL      major_version;
    INTVAL      minor_version;
    INTVAL      patch_version;
    size_t      op_count;
    op_info_t * op_info_table;
    void *      op_func_table;
    int (*op_code)(const char * name, int full);
} op_lib_t;

/* when init = true initialize, else de_initialize */
typedef op_lib_t *(*oplib_init_f)(int init);

#endif

/*
 * Local variables:
 * c-indentation-style: bsd
 * c-basic-offset: 4
 * indent-tabs-mode: nil
 * End:
 *
 * vim: expandtab shiftwidth=4:
*/
