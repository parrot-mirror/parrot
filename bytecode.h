
/* bytecode.h
 *
 * Bytecode functions header
 *
 */

#if !defined(PARROT_BYTECODE_H_GUARD)
#define PARROT_BYTECODE_H_GUARD

void* init_bytecode(void* program_code);

VAR_SCOPE STRING** Parrot_string_constants;

#endif
