/*
Copyright (C) 2010, Parrot Foundation.
$Id$

=head1 NAME

src/gc/list.h - Linked lists of allocated objects.

=head1 DESCRIPTION

Implementation of double linked lists used by various GC implementations.

*/

#ifndef PARROT_GC_LIST_H_GUARD
#define PARROT_GC_LIST_H_GUARD

/* Allocatable objects has headers to use in linked lists */
typedef struct List_Item_Header {
    struct List_Item_Header *prev;
    struct List_Item_Header *next;

#ifndef NDEBUG
    struct Linked_List *owner;
#endif
} List_Item_Header;

/* Double-linked list. */
/* N.B. List doesn't _own_ items */
typedef struct Linked_List {
    struct List_Item_Header *first;
    struct List_Item_Header *last;

    /* Cache object count in list. We use it very often */
    size_t count;
} Linked_List;

/* Such headers allocated in front of real objects. */
/* There is helper macros to convert to/from real objects */
#define Obj2LLH(p) ((List_Item_Header *)((char*)(p) - sizeof (List_Item_Header)))
#define LLH2Obj_typed(p, type) ((type*)((char*)(p) + sizeof (List_Item_Header)))
#define LLH2Obj(p) LLH2Obj_typed(p, void)

#ifdef NDEBUG
#  define SET_LIST_OWNER(l, i)
#else
#  define SET_LIST_OWNER(l, i) (i)->owner = (l);
#endif

#define LIST_APPEND(l, i)                   \
do {                                        \
    List_Item_Header *_item = (i);          \
    Linked_List      *_list = (l);          \
    (_item)->prev = (_item)->next = NULL;   \
                                            \
    if (_list->last) {                      \
        _item->prev = _list->last;          \
        _list->last->next = _item;          \
    }                                       \
                                            \
    _list->last = _item;                    \
                                            \
    if (!_list->first)                      \
        _list->first = _item;               \
                                            \
    SET_LIST_OWNER(_list, _item)            \
    _list->count++;                         \
} while (0);

#define LIST_REMOVE(l, i)                   \
do {                                        \
    List_Item_Header *_item = (i);          \
    Linked_List      *_list = (l);          \
    List_Item_Header *next = _item->next;   \
    List_Item_Header *prev = _item->prev;   \
                                            \
    PARROT_ASSERT(_list == _item->owner);   \
                                            \
    /* First _item */                       \
    if (_list->first == _item)              \
        _list->first = next;                \
                                            \
    if (_list->last == _item)               \
        _list->last = prev;                 \
                                            \
    if (prev)                               \
        prev->next = next;                  \
    if (next)                               \
        next->prev = prev;                  \
                                            \
    _list->count--;                         \
} while (0)


/* HEADERIZER BEGIN: src/list.c */
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */

PARROT_EXPORT
void Parrot_list_append(SHIM_INTERP,
    ARGMOD(Linked_List *list),
    ARGMOD(List_Item_Header *item))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*list)
        FUNC_MODIFIES(*item);

PARROT_EXPORT
INTVAL Parrot_list_check(SHIM_INTERP, ARGIN(Linked_List *list))
        __attribute__nonnull__(2);

PARROT_EXPORT
INTVAL Parrot_list_contains(SHIM_INTERP,
    ARGIN(Linked_List *list),
    ARGIN(List_Item_Header *item))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3);

PARROT_EXPORT
void Parrot_list_destroy(SHIM_INTERP, ARGMOD(Linked_List* list))
        __attribute__nonnull__(2)
        FUNC_MODIFIES(* list);

PARROT_EXPORT
PARROT_CANNOT_RETURN_NULL
struct Linked_List* Parrot_list_new(SHIM_INTERP);

PARROT_EXPORT
List_Item_Header* Parrot_list_pop(PARROT_INTERP, ARGIN(Linked_List *list))
        __attribute__nonnull__(1)
        __attribute__nonnull__(2);

PARROT_EXPORT
List_Item_Header* Parrot_list_remove(SHIM_INTERP,
    ARGMOD(Linked_List *list),
    ARGMOD(List_Item_Header *item))
        __attribute__nonnull__(2)
        __attribute__nonnull__(3)
        FUNC_MODIFIES(*list)
        FUNC_MODIFIES(*item);

#define ASSERT_ARGS_Parrot_list_append __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(list) \
    , PARROT_ASSERT_ARG(item))
#define ASSERT_ARGS_Parrot_list_check __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(list))
#define ASSERT_ARGS_Parrot_list_contains __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(list) \
    , PARROT_ASSERT_ARG(item))
#define ASSERT_ARGS_Parrot_list_destroy __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(list))
#define ASSERT_ARGS_Parrot_list_new __attribute__unused__ int _ASSERT_ARGS_CHECK = (0)
#define ASSERT_ARGS_Parrot_list_pop __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(interp) \
    , PARROT_ASSERT_ARG(list))
#define ASSERT_ARGS_Parrot_list_remove __attribute__unused__ int _ASSERT_ARGS_CHECK = (\
       PARROT_ASSERT_ARG(list) \
    , PARROT_ASSERT_ARG(item))
/* Don't modify between HEADERIZER BEGIN / HEADERIZER END.  Your changes will be lost. */
/* HEADERIZER END: src/list.c */

#endif /* PARROT_GC_LIST_H_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
