/* packfile.h
*
* $Id$
*/

#include <parrot/parrot.h>


/*
** Structure Definitions:
*/

typedef struct {
    IV                    dummy;
} PackFile_FixupTable;


typedef struct {
    IV     flags;
    IV     encoding;
    IV     type;
    IV     size;
    char * data;
} PackFile_Constant;


typedef struct {
    IV                    const_count;
    PackFile_Constant **  constants;
} PackFile_ConstTable;


typedef struct {
    IV                    magic;
    PackFile_FixupTable * fixup_table;
    PackFile_ConstTable * const_table;
    IV                    byte_code_size;
    char *                byte_code;
} PackFile;


/*
** PackFile Functions:
*/

PackFile *
PackFile_new(void);

void
PackFile_DELETE(PackFile * self);

void
PackFile_clear(PackFile * self);

IV
PackFile_get_magic(PackFile * self);

void 
PackFile_set_magic(PackFile * self, IV magic);

IV
PackFile_get_byte_code_size(PackFile * self);

char *
PackFile_get_byte_code(PackFile * self);

void
PackFile_set_byte_code(PackFile * self, IV byte_code_size, char * byte_code);

IV
PackFile_unpack(PackFile * self, char * packed, IV packed_size);

IV
PackFile_pack_size(PackFile * self);

void
PackFile_pack(PackFile * self, char * packed);

void
PackFile_dump(PackFile * self);


/*
** PackFile_FixupTable Functions:
*/

PackFile_FixupTable *
PackFile_FixupTable_new(void);

void
PackFile_FixupTable_DELETE(PackFile_FixupTable * self);

void
PackFile_FixupTable_clear(PackFile_FixupTable * self);

IV
PackFile_FixupTable_unpack(PackFile_FixupTable * self, char * packed, IV packed_size);

IV
PackFile_FixupTable_pack_size(PackFile_FixupTable * self);

void
PackFile_FixupTable_pack(PackFile_FixupTable * self, char * packed);

void
PackFile_FixupTable_dump(PackFile_FixupTable * self);


/*
** PackFile_ConstTable Functions:
*/

PackFile_ConstTable *
PackFile_ConstTable_new(void);

void
PackFile_ConstTable_DELETE(PackFile_ConstTable * self);

void
PackFile_ConstTable_clear(PackFile_ConstTable * self);

IV
PackFile_ConstTable_get_const_count(PackFile_ConstTable * self);

void
PackFile_ConstTable_push_constant(PackFile_ConstTable * self, PackFile_Constant * constant);

PackFile_Constant *
PackFile_ConstTable_constant(PackFile_ConstTable * self, IV index);

IV
PackFile_ConstTable_unpack(PackFile_ConstTable * self, char * packed, IV packed_size);

IV
PackFile_ConstTable_pack_size(PackFile_ConstTable * self);

void
PackFile_ConstTable_pack(PackFile_ConstTable * self, char * packed);

void
PackFile_ConstTable_dump(PackFile_ConstTable * self);


/*
** PackFile_Constant Functions:
*/

PackFile_Constant *
PackFile_Constant_new(void);

void
PackFile_Constant_DELETE(PackFile_Constant * self);

void
PackFile_Constant_clear(PackFile_Constant * self);

IV
PackFile_Constant_get_flags(PackFile_Constant * self);

void
PackFile_Constant_set_flags(PackFile_Constant * self, IV flags);

IV
PackFile_Constant_get_encoding(PackFile_Constant * self);

void
PackFile_Constant_set_encoding(PackFile_Constant * self, IV encoding);

IV
PackFile_Constant_get_type(PackFile_Constant * self);

void
PackFile_Constant_set_type(PackFile_Constant * self, IV type);

IV
PackFile_Constant_get_size(PackFile_Constant * self);

char *
PackFile_Constant_get_data(PackFile_Constant * self);

void
PackFile_Constant_set_data(PackFile_Constant * self, IV size, char * data);

IV
PackFile_Constant_unpack(PackFile_Constant * self, char * packed, IV packed_size);

IV
PackFile_Constant_pack_size(PackFile_Constant * self);

void
PackFile_Constant_pack(PackFile_Constant * self, char * packed);

void
PackFile_Constant_dump(PackFile_Constant * self);

