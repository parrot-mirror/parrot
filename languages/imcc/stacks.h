
/* Stack declarations. Stolen from rxstacks.h */

#define STACK_CHUNK_DEPTH 256

typedef struct IMCStack_entry_t {
   int value;
} *IMCStack_Entry;

typedef struct IMCStack_chunk_t {
    int used;
    struct IMCStack_chunk_t *next;
    struct IMCStack_chunk_t *prev;
    struct IMCStack_entry_t entry[STACK_CHUNK_DEPTH];
} *IMCStack_Chunk;

typedef IMCStack_Chunk IMCStack;
IMCStack imcstack_new();
int imcstack_depth(IMCStack);
void imcstack_push(IMCStack, int);
int imcstack_pop(IMCStack);

