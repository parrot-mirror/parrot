# RT#40705: Stub 
# help tcltest compile

.HLL '_Tcl', 'tcl_group'
.namespace

.sub 'update'
  .param string retval
  .param pmc    raw_args
  .param pmc    argv

  .return('')
.end

