/*
Copyright (C) 2001-2007, The Perl Foundation.
$Id$

=head1 NAME

src/exit.c - Exit Handling

=head1 DESCRIPTION

Parrot's version of C<exit()>, C<on_exit()>, and friends.

C<Parrot_on_exit()> allows you register exit handlers which will be
called by C<Parrot_exit()> when the interpreter exits.

=head2 Functions

=over 4

=cut

*/

#include <stdlib.h>
#include "parrot/parrot.h"

/* HEADERIZER HFILE: include/parrot/exit.h */

/*

=item C<PARROT_API
void
Parrot_on_exit(PARROT_INTERP, NOTNULL(exit_handler_f function), NULLOK(void *arg))>

Register the specified function to be called on exit.

=cut

*/

PARROT_API
void
Parrot_on_exit(PARROT_INTERP, NOTNULL(exit_handler_f function), NULLOK(void *arg))
{
    /* RT#46403  we might want locking around the list access.   I'm sure this
     * will be the least of the threading issues. */

    handler_node_t* const new_node = mem_allocate_typed(handler_node_t);

    new_node->function = function;
    new_node->arg = arg;
    new_node->next = interp->exit_handler_list;
    interp->exit_handler_list = new_node;
}

/*

=item C<PARROT_API
PARROT_DOES_NOT_RETURN
void
Parrot_exit(PARROT_INTERP, int status)>

Exit, calling any registered exit handlers.

=cut

*/

PARROT_API
PARROT_DOES_NOT_RETURN
void
Parrot_exit(PARROT_INTERP, int status)
{
    /* call all the exit handlers */
    /* we are well "below" the runloop now, where lo_var_ptr
     * is set usually - exit handlers may run some resource-hungry
     * stuff like printing profile stats - a DOD run would kill
     * resources - RT#46405 reset stacktop or better disable GC
     */
    /*
     * we don't allow new exit_handlers being installed inside exit handlers
     * - do we?
     * and: interp->exit_handler_list is gone, after the last exit handler
     *      (Parrot_really_destroy) has run
     */
    handler_node_t *node = interp->exit_handler_list;

    Parrot_block_DOD(interp);
    Parrot_block_GC(interp);

    while (node) {
        handler_node_t * const next = node->next;

        (node->function)(interp, status, node->arg);
        mem_sys_free(node);
        node = next;
    }
    exit(status);
}

/*

=back

=head1 SEE ALSO

F<include/parrot/exit.h> and F<t/src/exit.t>.

=head1 HISTORY

Initial version by Josh Wilmes.

=cut

*/


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
