/* $Id *
 * Copyright (C) 2008 The Perl Foundation
 */
#ifndef PARROT_COMPILERS_NCIGEN_K_GUARD
#define PARROT_COMPILERS_NCIGEN_K_GUARD

extern const char sqlite3_version[];
const char *sqlite3_libversion(void);
int sqlite3_libversion_number(void);
int sqlite3_threadsafe(void);
typedef struct sqlite3 sqlite3;
typedef long long int sqlite_int64;
typedef unsigned long long int sqlite_uint64;
typedef sqlite_int64 sqlite3_int64;
typedef sqlite_uint64 sqlite3_uint64;
int sqlite3_close(sqlite3 *);
typedef int (*sqlite3_callback)(void*, int, char**, char**);
int sqlite3_exec(sqlite3*, const char *sql, int (*callback)(void*, int, char**, char**), void *, char **errmsg);
typedef struct sqlite3_mutex sqlite3_mutex;
int sqlite3_extended_result_codes(sqlite3*, int onoff);
sqlite3_int64 sqlite3_last_insert_rowid(sqlite3*);
int sqlite3_changes(sqlite3*);
int sqlite3_total_changes(sqlite3*);
void sqlite3_interrupt(sqlite3*);
int sqlite3_complete(const char *sql);
int sqlite3_complete16(const void *sql);
int sqlite3_busy_handler(sqlite3*, int (*)(void*, int), void*);
int sqlite3_busy_timeout(sqlite3*, int ms);
int sqlite3_get_table(sqlite3*, const char *sql, char ***pResult, int *nrow, int *ncolumn, char **errmsg);
void sqlite3_free_table(char **result);
char *sqlite3_vmprintf(const char*, va_list);
void *sqlite3_malloc(int);
void *sqlite3_realloc(void*, int);
void sqlite3_free(void*);
sqlite3_int64 sqlite3_memory_used(void);
sqlite3_int64 sqlite3_memory_highwater(int resetFlag);
void sqlite3_randomness(int N, void *P);
int sqlite3_set_authorizer(sqlite3*, int (*xAuth)(void*, int, const char*, const char*, const char*, const char*), void *pUserData);
void *sqlite3_trace(sqlite3*, void (*xTrace)(void*, const char*), void*);
void *sqlite3_profile(sqlite3*, void (*xProfile)(void*, const char*, sqlite3_uint64), void*);
void sqlite3_progress_handler(sqlite3*, int, int (*)(void*), void*);
int sqlite3_open(const char *filename, sqlite3 **ppDb);
int sqlite3_open16(const void *filename, sqlite3 **ppDb);
int sqlite3_open_v2(const char *filename, sqlite3 **ppDb, int flags, const char *zVfs);
int sqlite3_errcode(sqlite3 *db);
const char *sqlite3_errmsg(sqlite3*);
const void *sqlite3_errmsg16(sqlite3*);
typedef struct sqlite3_stmt sqlite3_stmt;
int sqlite3_limit(sqlite3*, int id, int newVal);
int sqlite3_prepare(sqlite3 *db, const char *zSql, int nByte, sqlite3_stmt **ppStmt, const char **pzTail);
int sqlite3_prepare_v2(sqlite3 *db, const char *zSql, int nByte, sqlite3_stmt **ppStmt, const char **pzTail);
int sqlite3_prepare16(sqlite3 *db, const void *zSql, int nByte, sqlite3_stmt **ppStmt, const void **pzTail);
int sqlite3_prepare16_v2(sqlite3 *db, const void *zSql, int nByte, sqlite3_stmt **ppStmt, const void **pzTail);

#endif /* PARROT_COMPILERS_NCIGEN_K_GUARD */

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
