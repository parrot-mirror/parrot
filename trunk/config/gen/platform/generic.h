/*
** platform.h [generic version]
*/


/*
** I/O:
*/

#define DEFAULT_OPEN_MODE S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
#ifndef S_ISREG
#  define S_ISREG(m) ((m & S_IFMT) == S_IFREG)
#endif

/*
** Miscellaneous:
*/


/*
** Dynamic Loading:
*/

#define PARROT_DLOPEN_FLAGS RTLD_LAZY

/*
 * signal handling
 */

#if defined(HAS_HEADER_SIGNAL) && defined(HAS_HEADER_SYSTYPES)
#  include <signal.h>
#  include <sys/types.h>
#  define dumpcore() kill(0, SIGQUIT)
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
