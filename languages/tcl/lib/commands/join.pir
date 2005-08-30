###
# [join]

.namespace [ "Tcl" ]

.sub "&join"
  .param pmc argv :slurpy
  .local int argc
  argc = argv

  .local pmc a_list,joiner_pmc
  a_list     = argv[0]
  joiner_pmc = argv[1]

  if argc == 0 goto bad_args
  if argc > 2 goto bad_args

  if argc ==2 goto continue
  joiner_pmc = new String
  joiner_pmc = " "
continue:

  .local pmc retval
  .local int return_type

  .local pmc a_list

  .local pmc __list
  __list = find_global "_Tcl", "__list"
  
  (return_type, retval) = __list(a_list)
  if return_type == TCL_ERROR goto done
  a_list = retval

got_list:
  .local string joiner_str
  joiner_str = joiner_pmc
  .local string rv
  rv = join joiner_str, a_list
  retval = new String
  retval = rv
done:
  .return(return_type,retval)

bad_args:
  .return(TCL_ERROR, "wrong # args: should be \"join list ?joinString?\"")

.end
