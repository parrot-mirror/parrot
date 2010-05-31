/*
Copyright (C) 2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/list.c - Implementation of double linked lists.

=head1 DESCRIPTION

This code implements double linked list of GCable objects.

=cut

*/

#include "parrot/parrot.h"
#include "list.h"

/* HEADERIZER HFILE: src/gc/list.h */

/* HEADERIZER BEGIN: static */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: static */

/*

=over 4

=cut

*/

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
struct Linked_List*
Parrot_gc_allocate_linked_list(SHIM_INTERP)
{
    Linked_List *res = (Linked_List*)mem_sys_allocate_zeroed(sizeof (Linked_List));
    return res;
}

PARROT_EXPORT
void
Parrot_gc_destroy_linked_list(SHIM_INTERP, ARGMOD(Linked_List* list))
{
    mem_sys_free(list);
}

PARROT_EXPORT
void
Parrot_gc_list_append(SHIM_INTERP, ARGMOD(Linked_List *list), ARGMOD(List_Item_Header *item))
{
    item->prev = item->next = NULL;

    if (list->last) {
        item->prev = list->last;
        list->last->next = item;
    }

    list->last = item;

    if (!list->first)
        list->first = item;

    list->count++;

    item->owner = list;
}

PARROT_EXPORT
void
Parrot_gc_list_prepend(SHIM_INTERP, ARGMOD(Linked_List *list), ARGMOD(List_Item_Header *item))
{
    /* First item */
    if (!list->first) {
        list->first = list->last = item;
        item->prev = item->next = NULL;
    }
    else {
        item->prev = NULL;
        item->next = list->first;
        list->first = item;
    }
    list->count++;
}

PARROT_EXPORT
void
Parrot_gc_list_remove(SHIM_INTERP, ARGMOD(Linked_List *list), ARGMOD(List_Item_Header *item))
{
    List_Item_Header *next = item->next;
    List_Item_Header *prev = item->prev;

    PARROT_ASSERT(list == item->owner);

    /* First item */
    if (list->first == item)
        list->first = next;

    if (list->last == item)
        list->last = prev;

    if (prev)
        prev->next = next;
    if (next)
        next->prev = prev;

    item->prev = item->next = NULL;
    list->count--;
}


/*

=back

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
