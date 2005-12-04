/* $id $
 *  Copyright: 2005 The Perl Foundation.  All Rights Reserved.
 *
 * DO NOT EDIT THIS FILE DIRECTLY!
 * please update the charset/gen_tables.pl script instead.
 *
 * Created by gen_tables.pl jrieks 
 *  Overview:
 *     This file contains various charset tables.
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */

#include "tables.h"
const PARROT_CCLASS_FLAGS Parrot_ascii_typetable[256] = {
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 0-7 */
0x0200, 0x0320, 0x1220, 0x0220, 0x1220, 0x1220, 0x0200, 0x0200, /* 8-15 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 16-23 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 24-31 */
0x0160, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 32-39 */
0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 40-47 */
0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, /* 48-55 */
0x28d8, 0x28d8, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 56-63 */
0x04c0, 0x28d5, 0x28d5, 0x28d5, 0x28d5, 0x28d5, 0x28d5, 0x28c5, /* 64-71 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, /* 72-79 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, /* 80-87 */
0x28c5, 0x28c5, 0x28c5, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x24c0, /* 88-95 */
0x04c0, 0x28d6, 0x28d6, 0x28d6, 0x28d6, 0x28d6, 0x28d6, 0x28c6, /* 96-103 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 104-111 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 112-119 */
0x28c6, 0x28c6, 0x28c6, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x0200, /* 120-127 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x1020, 0x0000, 0x0000, /* 128-135 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 136-143 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 144-151 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 152-159 */
0x0020, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 160-167 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 168-175 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 176-183 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 184-191 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 192-199 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 200-207 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 208-215 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 216-223 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 224-231 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 232-239 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 240-247 */
0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, /* 248-255 */
};
const PARROT_CCLASS_FLAGS Parrot_iso_8859_1_typetable[256] = {
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 0-7 */
0x0200, 0x0320, 0x1220, 0x0220, 0x1220, 0x1220, 0x0200, 0x0200, /* 8-15 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 16-23 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 24-31 */
0x0160, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 32-39 */
0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 40-47 */
0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, 0x28d8, /* 48-55 */
0x28d8, 0x28d8, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 56-63 */
0x04c0, 0x28d5, 0x28d5, 0x28d5, 0x28d5, 0x28d5, 0x28d5, 0x28c5, /* 64-71 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, /* 72-79 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, /* 80-87 */
0x28c5, 0x28c5, 0x28c5, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x24c0, /* 88-95 */
0x04c0, 0x28d6, 0x28d6, 0x28d6, 0x28d6, 0x28d6, 0x28d6, 0x28c6, /* 96-103 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 104-111 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 112-119 */
0x28c6, 0x28c6, 0x28c6, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x0200, /* 120-127 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x1220, 0x0200, 0x0200, /* 128-135 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 136-143 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 144-151 */
0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, 0x0200, /* 152-159 */
0x04e0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 160-167 */
0x04c0, 0x04c0, 0x28c4, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 168-175 */
0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x28c6, 0x04c0, 0x04c0, /* 176-183 */
0x04c0, 0x04c0, 0x28c4, 0x04c0, 0x04c0, 0x04c0, 0x04c0, 0x04c0, /* 184-191 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, /* 192-199 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, /* 200-207 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x04c0, /* 208-215 */
0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c5, 0x28c6, /* 216-223 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 224-231 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 232-239 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x04c0, /* 240-247 */
0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, 0x28c6, /* 248-255 */
};
