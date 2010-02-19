/* ex: set ro ft=c:
 * !!!!!!!   DO NOT EDIT THIS FILE   !!!!!!!
 *
 * This file is generated automatically by tools/build/nativecall.pir
 *
 * Any changes made here will be lost!
 *
 */

/* src/nci/core_thunks.c
 *  Copyright (C) 2010, Parrot Foundation.
 *  SVN Info
 *     $Id$
 *  Overview:
 *     Native Call Interface routines. The code needed to build a
 *     parrot to C call frame is in here
 *  Data Structure and Algorithms:
 *  History:
 *  Notes:
 *  References:
 */


#include "parrot/parrot.h"
#include "pmc/pmc_nci.h"


#ifdef PARROT_IN_EXTENSION
/* external libraries can't have strings statically compiled into parrot */
#  define CONST_STRING(i, s) Parrot_str_new_constant((i), (s))
#else
#  include "core_thunks.str"
#endif

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

/* All our static functions that call in various ways. Yes, terribly
   hackish, but that is just fine */


static void
pcf_d_JOd(PARROT_INTERP, PMC *self)
{
    typedef double(* func_t)(PARROT_INTERP, PMC *, double);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    FLOATVAL return_data;

    PMC * t_1;
    FLOATVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiN", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (double)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "N", return_data);
    


}
static void
pcf_I_JOS(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    STRING * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    


}
static void
pcf_P_JOl(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, long);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    INTVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiI", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    


}
static void
pcf_P_Jt(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, char *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    char *t_1; STRING *ts_1;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "S", &ts_1);
    t_1 = ts_1 ? Parrot_str_to_cstring(interp, ts_1) : (char *)NULL;
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    
if (t_1) Parrot_str_free_cstring(t_1);
}
static void
pcf_S_JOS(PARROT_INTERP, PMC *self)
{
    typedef STRING *(* func_t)(PARROT_INTERP, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    STRING * return_data;

    PMC * t_1;
    STRING * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (STRING *)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "S", return_data);
    


}
static void
pcf_I_JI(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, INTVAL);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    INTVAL t_1;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "I", &t_1);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    

}
static void
pcf_v_JOSP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, STRING *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    STRING * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiSP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3);
    
    



}
static void
pcf_v_JOS(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    STRING * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2);
    
    


}
static void
pcf_P_JOS(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    STRING * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    


}
static void
pcf_I_JOI(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, INTVAL);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    INTVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiI", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    


}
static void
pcf_P_JOP(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    PMC * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiP", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    


}
static void
pcf_P_JOPS(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    PMC * t_2;
    STRING * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiPS", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    



}
static void
pcf_v_JOPSP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, PMC *, STRING *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    PMC * t_2;
    STRING * t_3;
    PMC * t_4;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiPSP", &t_1, &t_2, &t_3, &t_4);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3, t_4);
    
    




}
static void
pcf_v_JPPP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    PMC * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PPP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3);
    
    



}
static void
pcf_v_JPIP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, INTVAL, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    INTVAL t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PIP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3);
    
    



}
static void
pcf_v_JPSP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, STRING *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    STRING * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PSP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3);
    
    



}
static void
pcf_v_JPNP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, FLOATVAL, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    FLOATVAL t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PNP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3);
    
    



}
static void
pcf_v_JPP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    PMC * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PP", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2);
    
    


}
static void
pcf_v_JPI(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, INTVAL);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    INTVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PI", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2);
    
    


}
static void
pcf_v_JPS(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    STRING * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2);
    
    


}
static void
pcf_v_JPN(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, FLOATVAL);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    FLOATVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PN", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2);
    
    


}
static void
pcf_P_JPPP(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    PMC * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PPP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    



}
static void
pcf_P_JPIP(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, INTVAL, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    INTVAL t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PIP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    



}
static void
pcf_P_JPSP(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, STRING *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    STRING * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PSP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    



}
static void
pcf_P_JPNP(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, FLOATVAL, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    FLOATVAL t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PNP", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    



}
static void
pcf_I_JPP(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    PMC * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PP", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    


}
static void
pcf_I_JPS(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    STRING * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    


}
static void
pcf_I_JPN(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, FLOATVAL);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    FLOATVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PN", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    


}
static void
pcf_i_JP(PARROT_INTERP, PMC *self)
{
    typedef int(* func_t)(PARROT_INTERP, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "P", &t_1);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (int)(*fn_pointer)(interp, t_1);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    

}
static void
pcf_v_JP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "P", &t_1);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1);
    
    

}
static void
pcf_i_JPi(PARROT_INTERP, PMC *self)
{
    typedef int(* func_t)(PARROT_INTERP, PMC *, int);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    INTVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PI", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (int)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    


}
static void
pcf_i_JPii(PARROT_INTERP, PMC *self)
{
    typedef int(* func_t)(PARROT_INTERP, PMC *, int, int);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    INTVAL t_2;
    INTVAL t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PII", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (int)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    



}
static void
pcf_i_JPiii(PARROT_INTERP, PMC *self)
{
    typedef int(* func_t)(PARROT_INTERP, PMC *, int, int, int);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    INTVAL t_2;
    INTVAL t_3;
    INTVAL t_4;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PIII", &t_1, &t_2, &t_3, &t_4);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (int)(*fn_pointer)(interp, t_1, t_2, t_3, t_4);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    




}
static void
pcf_i_JPt(PARROT_INTERP, PMC *self)
{
    typedef int(* func_t)(PARROT_INTERP, PMC *, char *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    char *t_2; STRING *ts_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PS", &t_1, &ts_2);
    t_2 = ts_2 ? Parrot_str_to_cstring(interp, ts_2) : (char *)NULL;
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (int)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    

if (t_2) Parrot_str_free_cstring(t_2);
}
static void
pcf_P_JOSSS(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *, STRING *, STRING *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    STRING * t_2;
    STRING * t_3;
    STRING * t_4;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiSSS", &t_1, &t_2, &t_3, &t_4);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1, t_2, t_3, t_4);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    




}
static void
pcf_v_JOSS(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, STRING *, STRING *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    STRING * t_2;
    STRING * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiSS", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2, t_3);
    
    



}
static void
pcf_S_JOI(PARROT_INTERP, PMC *self)
{
    typedef STRING *(* func_t)(PARROT_INTERP, PMC *, INTVAL);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    STRING * return_data;

    PMC * t_1;
    INTVAL t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiI", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (STRING *)(*fn_pointer)(interp, t_1, t_2);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "S", return_data);
    


}
static void
pcf_v_JOb(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, void *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    STRING *t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiS", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, Buffer_bufstart(t_2));
    
    


}
static void
pcf_i_JOPxAT_(PARROT_INTERP, PMC *self)
{
    typedef int(* func_t)(PARROT_INTERP, PMC *, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    PMC * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiPPs", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (int)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    



}
static void
pcf_I_JOPxAT_(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    PMC * t_2;
    PMC * t_3;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiPPs", &t_1, &t_2, &t_3);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2, t_3);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    



}
static void
pcf_I_JOIPxAT_(PARROT_INTERP, PMC *self)
{
    typedef INTVAL(* func_t)(PARROT_INTERP, PMC *, INTVAL, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    INTVAL return_data;

    PMC * t_1;
    INTVAL t_2;
    PMC * t_3;
    PMC * t_4;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiIPPs", &t_1, &t_2, &t_3, &t_4);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (INTVAL)(*fn_pointer)(interp, t_1, t_2, t_3, t_4);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "I", return_data);
    




}
static void
pcf_P_JO(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    PMC * t_1;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "Pi", &t_1);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    

}
static void
pcf_v_JOP(PARROT_INTERP, PMC *self)
{
    typedef void(* func_t)(PARROT_INTERP, PMC *, PMC *);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    void * return_data;

    PMC * t_1;
    PMC * t_2;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "PiP", &t_1, &t_2);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
     (*fn_pointer)(interp, t_1, t_2);
    
    


}
static void
pcf_P_Ji(PARROT_INTERP, PMC *self)
{
    typedef PMC *(* func_t)(PARROT_INTERP, int);
    func_t fn_pointer;
    void *orig_func;
    PMC *ctx         = CURRENT_CONTEXT(interp);
    PMC *call_object = Parrot_pcc_get_signature(interp, ctx);
    PMC * return_data;

    INTVAL t_1;
    Parrot_pcc_fill_params_from_c_args(interp, call_object, "I", &t_1);
    
    GETATTR_NCI_orig_func(interp, self, orig_func);
    fn_pointer = (func_t)D2FPTR(orig_func);
    return_data =  (PMC *)(*fn_pointer)(interp, t_1);
    Parrot_pcc_fill_returns_from_c_args(interp, call_object, "P", return_data);
    

}


 void
Parrot_nci_load_core_thunks(PARROT_INTERP)
{
    PMC        *iglobals;
    PMC        *temp_pmc;

    PMC        *HashPointer   = NULL;

    iglobals = interp->iglobals;
    if (PMC_IS_NULL(iglobals))
        PANIC(interp, "iglobals isn't created yet");

    HashPointer = VTABLE_get_pmc_keyed_int(interp, iglobals,
            IGLOBALS_NCI_FUNCS);
    if (PMC_IS_NULL(HashPointer))
        PANIC(interp, "iglobals.nci_funcs isn't created yet");

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_d_JOd);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "dJOd"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JOS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJOS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JOl);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJOl"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_Jt);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJt"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_S_JOS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "SJOS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JI);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJI"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JOSP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJOSP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JOS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJOS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JOS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJOS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JOI);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJOI"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JOP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJOP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JOPS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJOPS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JOPSP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJOPSP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPPP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPPP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPIP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPIP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPSP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPSP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPNP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPNP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPI);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPI"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JPN);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJPN"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JPPP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJPPP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JPIP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJPIP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JPSP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJPSP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JPNP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJPNP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JPP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJPP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JPS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJPS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JPN);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJPN"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_i_JP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "iJP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_i_JPi);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "iJPi"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_i_JPii);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "iJPii"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_i_JPiii);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "iJPiii"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_i_JPt);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "iJPt"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JOSSS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJOSSS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JOSS);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJOSS"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_S_JOI);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "SJOI"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JOb);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJOb"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_i_JOPxAT_);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "iJOP@"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JOPxAT_);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJOP@"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_I_JOIPxAT_);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "IJOIP@"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_JO);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJO"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_v_JOP);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "vJOP"), temp_pmc);

    temp_pmc = Parrot_pmc_new(interp, enum_class_UnManagedStruct);
    VTABLE_set_pointer(interp, temp_pmc, (void *)pcf_P_Ji);
    VTABLE_set_pmc_keyed_str(interp, HashPointer, CONST_STRING(interp, "PJi"), temp_pmc);

}


/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */

