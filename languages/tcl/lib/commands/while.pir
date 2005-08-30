###
# [while]

.namespace [ "Tcl" ]

.sub "&while"
  .param pmc argv :slurpy
  .local int argc
  argc = argv

  if argc != 2 goto bad_args

  .local pmc    cond_p
  cond_p = argv[0]
  .local string body_p
  body_p = argv[1]

  .local pmc retval, parsed_code
  .local int return_type

  .local pmc parse
  .local pmc expression_p
  .local pmc expression_i

  parse = find_global "_Tcl", "parse"
  expression_p = find_global "_Tcl", "__expression_parse"
  expression_i = find_global "_Tcl", "__expression_interpret"

  $S0 = body_p
  parsed_code = parse($S0)
  register parsed_code

while_loop:
  $S0 = cond_p
  (return_type,retval) = expression_p($S0)
  if return_type == TCL_ERROR goto done_done
  (return_type,retval) = expression_i(retval)
  if return_type == TCL_ERROR goto done_done
  unless retval goto done
  (return_type,retval) = parsed_code."interpret"()
  if return_type == TCL_BREAK goto done
  if return_type == TCL_RETURN goto done

  goto while_loop

done:
  if return_type == TCL_RETURN goto done_cleaned
  if return_type == TCL_ERROR  goto done_cleaned
  retval = ""
  return_type = TCL_OK
  goto done_done

done_cleaned:
  retval = ""

done_done:
  # while always returns "", regardless of the code it may have executed
  # XXX - (unless there's an error)

  .return(return_type,retval)

bad_args:
  .return (TCL_ERROR, "wrong # args: should be \"while test command\"")

.end
