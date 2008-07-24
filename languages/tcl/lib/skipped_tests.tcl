# skipped_tests - these are all the tests that the partcl implementation
# not only cannot pass, but cannot compile, or causes a parrot segfault, etc.
# must use exact test names.
#
# todo_tests - these are the tests that are known to fail because they
# require a feature we haven't implemented yet. Can use globs to specify
# a range of skippable tests.
#
# stored as a dictionary, with the reason as a key, and the list of tests
# that require the feature (or cause the listed error) as values.

set todo_tests [dict create \
  {list to string improvements} {
    list-1.1[23] list-1.26
  } {parsing errors} {
    list-1.1[56]
  } {[trace]} {
    append-7.[12345]
    appendComp-7.[123456789]
    if-10.6
    lset-1.3 lset-5.[12]
  } {stacktrace support} {
    apply-2.[2345] apply-5.1
    if-5.3    if-6.4
  } {tcltest: need better [testevalex]} {
    lset-2.2 lset-7.[12] lset-10.3 lset-13.[012] lset-14.[12]
  } {[apply]} {
    apply-[4678].*
  }
]

set skip_tests [dict create \
  {[binary]} {
    string-5.14 string-5.15 string-5.16 string-12.21
    stringComp-5.14 stringComp-5.15 stringComp-5.16 stringComp-9.7
  } {[exec]} {
    subst-5.8 subst-5.9 subst-5.10
  } {[subst]} {
    parse-18.9 parse-18.12
  } {[trace]} {
  } {stacktrace support} {
    basic-46.1
    cmdMZ-return-2.10 cmdMZ-3.5 cmdMZ-5.7
    dict-14.12 dict-17.13
    error-1.3 error-2.3 error-2.6 error-4.2 error-4.3 error-4.4
    eval-2.5
    iocmd-12.6
    incr-2.30 incr-2.31
    incr-old-2.4 incr-old-2.5
    misc-1.2
    namespace-8.5 namespace-8.6 namespace-25.6 namespace-25.7 namespace-25.8
    namespace-47.2 namespace-47.4 namespace-47.6 namespace-46.5
    parse-9.1 parse-9.2 parse-10.14
    parseOld-10.14
    proc-old-5.13 proc-old-5.16 proc-old-7.2  proc-old-7.11 proc-old-7.12 
    proc-old-7.13 proc-old-7.14
    set-2.1 set-4.1
    switch-4.1 switch-4.5
    while-4.3
    while-old-4.6
  } {http://code.google.com/p/partcl/issues/detail?id=2} {
    subst-5.7
  } {[interp]} {
    basic-11.1 basic-12.1 basic-12.2 basic-13.1 basic-13.2 basic-24.1
    basic-1.1 basic-10.1 basic-36.1          
    namespace-8.7
  } {[file]} {
    cmdAH-2.2 cmdAH-2.3 cmdAH-2.4 cmdAH-2.5 cmdAH-2.6 cmdAH-2.6.1 cmdAH-2.6.2
  } BOOM {
    format-3.1 format-3.2
    namespace-old-2.5 namespace-old-2.6 namespace-old-2.7 namespace-old-4.4
    namespace-old-7.7
  } {[expr wide()]} {
    dict-11.1 dict-11.2 dict-11.3 dict-11.4 dict-11.5 dict-11.6 dict-11.7
    expr-23.24 expr-23.25 expr-23.26 expr-23.27 expr-23.28 expr-23.29
    expr-23.30 expr-23.31 expr-23.32 expr-23.33 expr-24.3 expr-24.4 expr-24.7
    expr-24.8 expr-31.10 expr-31.14
    expr-old-34.13 expr-old-34.14
    lindex-3.7
  } {[expr isqrt()]} {
    expr-47.1 expr-47.2 expr-47.4 expr-47.5 expr-47.6 expr-47.7 expr-47.8
    expr-47.9 expr-47.10 expr-47.11 expr-47.12
  } {[expr s?rand()]} {
    expr-old-32.51 expr-old-32.52 expr-old-32.53 expr-old-32.48 expr-old-32.49
    expr-old-32.50 expr-old-32.45
  } {[namespace code]} {
    namespace-22.1 namespace-22.2 namespace-22.3 namespace-22.4 namespace-22.5 
    namespace-22.6 
  } {[namespace delete]} {
    namespace-14.1
  } {[namespace export]} {
    namespace-11.1 namespace-26.6
  } {[namespace inscope]} {
    namespace-29.1 namespace-29.2 namespace-29.3 namespace-29.4 namespace-29.5
    namespace-29.6
  } {[namespace import]} {
    namespace-8.1 namespace-8.4 namespace-9.1 namespace-9.2 namespace-9.3
    namespace-9.4 namespace-9.5 namespace-9.6 namespace-9.7 namespace-11.2
    namespace-11.3 namespace-12.1 namespace-26.4 namespace-26.5 namespace-26.7
    namespace-28.2 namespace-28.3
  } {[namespace origin]} {
    namespace-30.1 namespace-30.2 namespace-30.3 namespace-30.4 namespace-30.5
  } {[namespace forget]} {
    namespace-10.1 namespace-10.2 namespace-10.3 namespace-13.1 namespace-27.1
    namespace-27.2 namespace-27.3
  } {nested dictionaries} {
    dict-3.5 dict-3.6 dict-3.7 dict-3.8 dict-3.9 dict-3.10 dict-9.3 dict-9.4
    dict-9.5 dict-15.3 dict-15.5 dict-16.4 dict-21.16
  } {support for the variable named ""} {
    var-6.3 var-7.12 var-12.1
  } {Cannot get character past end of string} {
    format-8.17 format-8.18
  } {Cannot get character of empty string} {
    regexp-6.9 regexp-15.6 regexp-21.7
    regexpComp-6.9 regexpComp-15.6 regexpComp-21.7
  } {Cannot take substr outside string} {
    namespace-14.9 namespace-14.12
  } {[read]} {
    iocmd-4.1 iocmd-4.2 iocmd-4.3 iocmd-4.4 iocmd-4.5 iocmd-4.6 iocmd-4.7
    iocmd-4.8 iocmd-4.9 iocmd-4.10 iocmd-4.11 iocmd-4.12
  } {[seek]} {
    iocmd-5.1 iocmd-5.2 iocmd-5.3 iocmd-5.4 iocmd-12.4
  } {[tell]} {
    iocmd-6.1 iocmd-6.2 iocmd-6.3 
  } {[fblocked]} {
    iocmd-10.1 iocmd-10.2 iocmd-10.3 iocmd-10.4 iocmd-10.5
  } {Inf support} {
    compExpr-old-11.13a
    expr-11.13b expr-22.2 expr-22.4 expr-22.6 expr-22.8 expr-30.3 expr-30.4
    expr-41.1 expr-45.7
    expr-old-26.10b expr-old-34.11 expr-old-34.12b expr-old-34.11
    expr-old-34.10
    scan-14.1 scan-14.2 
  } {NaN support} {
    expr-22.1 expr-22.3  expr-22.5 expr-22.7 expr-22.9 expr-45.8 expr-45.9
    expr-47.3
    expr-old-36.7
  } {[testgetint]} {
    get-1.1 get-1.2 get-1.3 get-1.4 get-1.5 get-1.6 get-1.7 get-1.8 get-1.9
    get-1.10 get-1.11 get-1.12 get-1.13 get-1.14
  } {[testtranslatefilename]} {
    filename-10.1 filename-10.2 filename-10.3 filename-10.3.1 filename-10.6
    filename-10.7 filename-10.8 filename-10.9 filename-10.10 filename-10.17
    filename-10.18 filename-10.19 filename-10.20 filename-10.21 filename-10.22
    filename-10.23 filename-10.24 
  } {[testwordend]} {
    parseOld-14.1 parseOld-14.2 parseOld-14.3 parseOld-14.4 parseOld-14.5 
    parseOld-14.6 parseOld-14.7 parseOld-14.8 parseOld-14.9 parseOld-14.10
    parseOld-14.11 parseOld-14.12 parseOld-14.13 parseOld-14.14 
    parseOld-14.15 parseOld-14.16 parseOld-14.17 parseOld-14.18 
    parseOld-14.19 parseOld-14.20 parseOld-14.21
  } {[testdel]} {
    rename-4.1 rename-4.2 rename-4.3 rename-4.4 rename-4.5 
  } {[testchmod]} {
    cmdAH-18.3
  } {[testcmdtoken]} {
    basic-20.1 basic-20.2 basic-20.3
  } {[testcreatecommand]} {
    basic-14.1 basic-14.2
  } {[testexprstring]} {
    expr-old-38.2
  } {[testexprlong]} {
    expr-old-37.1 expr-old-37.2 expr-old-37.3 expr-old-37.4 expr-old-37.5
    expr-old-37.6 expr-old-37.8 expr-old-37.9 expr-old-37.11 expr-old-37.12
    expr-old-37.14 expr-old-37.15
  } {[testexprdouble]} {
    expr-old-37.17 expr-old-37.18 expr-old-37.19 expr-old-37.20 expr-old-37.21
    expr-old-37.22 expr-old-37.22 expr-old-37.23 expr-old-37.24 expr-old-37.25
  } {[testexprdoubleobj]} {
    expr-39.17 expr-39.19 expr-39.20 expr-39.21 expr-39.22 expr-39.23
    expr-39.24 expr-39.25 
  } {[testexprlongobj]} {
    expr-39.1 expr-39.2 expr-39.3 expr-39.4 expr-39.5 expr-39.6 expr-39.8
    expr-39.9 expr-39.11 expr-39.12 expr-39.14 expr-39.15
  } {[testevalobjv]} {
    parse-8.1 parse-8.5 parse-8.9
  } {[testparser]} {
    parse-1.1 parse-1.2 parse-1.3 parse-1.4 parse-1.5 parse-1.6 parse-1.7
    parse-1.8 parse-2.1 parse-2.2 parse-2.3 parse-2.4 parse-2.5 parse-3.1
    parse-3.2 parse-3.3 parse-3.4 parse-3.5 parse-3.6 parse-3.7 parse-4.1
    parse-4.2 parse-4.3 parse-4.4 parse-4.5 parse-4.6 parse-5.1 parse-5.2
    parse-5.3 parse-5.4 parse-5.5 parse-5.6 parse-5.7 parse-5.8 parse-5.9
    parse-5.10 parse-5.11 parse-5.13 parse-5.16 parse-5.18 parse-5.20
    parse-5.22 parse-5.23 parse-5.24 parse-5.25 parse-5.26 parse-5.27
    parse-6.1 parse-6.2 parse-6.3 parse-6.4 parse-6.5 parse-6.6 parse-6.7
    parse-6.11 parse-6.12 parse-6.13 parse-6.14 parse-6.15 parse-6.16
    parse-6.17 parse-6.18 parse-7.1 parse-12.6 parse-12.7 parse-12.8
    parse-12.11 parse-12.12 parse-12.13 parse-12.14 parse-12.18 parse-12.20
    parse-12.21 parse-12.22 parse-12.23 parse-12.25 parse-14.1 parse-14.2
    parse-14.3 parse-14.4 parse-14.5 parse-14.6 parse-14.7 parse-14.8
    parse-14.9 parse-14.10 parse-14.11 parse-14.12 parse-15.1 parse-15.2
    parse-15.3 parse-15.4
  } {[testparsevar]} {
    parse-13.1 parse-13.2 parse-13.3 parse-13.4 parse-13.5
  } {[testparsevarname]} {
    parse-12.1 parse-12.2 parse-12.3 parse-12.4 parse-12.5 parse-12.9
    parse-12.10 parse-12.15 parse-12.16 parse-12.17 parse-12.19 parse-12.24
  } {[testupvar]} {
    upvar-9.1 upvar-9.2 upvar-9.3 upvar-9.4 upvar-9.5 upvar-9.6 upvar-9.7 
    var-3.3 var-3.4 var-3.4 
  } {[testgetvarfullname]} {
    var-4.1 var-4.2 var-4.3
  } {[testsetnoerr]} {
    var-9.1 var-9.2 var-9.3 var-9.4 var-9.5 var-9.6 var-9.7 var-9.8 var-9.9
    var-9.1 var-9.11 var-9.12
  } {[testdoubleobj]} {
    execute-3.2 execute-3.8 execute-3.14 execute-3.20 execute-3.26 execute-3.32
    execute-3.38 execute-3.44 execute-3.50 execute-3.56 execute-3.63 
    execute-3.64 execute-3.73
  } {[testintobj]} {
    execute-3.1 execute-3.3 execute-3.7 execute-3.9 execute-3.13 execute-3.15
    execute-3.19 execute-3.21 execute-3.25 execute-3.27 execute-3.31 
    execute-3.33 execute-3.37 execute-3.39 execute-3.43 execute-3.45
    execute-3.49 execute-3.51 execute-3.55 execute-3.57 execute-3.61
    execute-3.62 execute-3.65 execute-3.66 execute-3.72 execute-3.74
  } {[testdstring]} {
    util-8.2 util-8.3 util-8.4 util-8.5 util-8.6
  } {[teststringobj]} {
    execute-3.4 execute-3.5 execute-3.6 execute-3.10 execute-3.11 execute-3.12
    execute-3.16 execute-3.17 execute-3.18 execute-3.22 execute-3.23
    execute-3.24 execute-3.28 execute-3.29 execute-3.30 execute-3.34
    execute-3.35 execute-3.36 execute-3.40 execute-3.41 execute-3.42
    execute-3.46 execute-3.47 execute-3.48 execute-3.52 execute-3.53
    execute-3.54 execute-3.58 execute-3.59 execute-3.60 execute-3.67
    execute-3.68 execute-3.69 execute-3.70 execute-3.71 execute-3.75
    execute-3.76 execute-3.77
  } {mathfunc} {
    compExpr-5.3 compExpr-5.4
    compExpr-old-15.7 compExpr-old-15.8 compExpr-old-15.9 compExpr-old-15.10
    compExpr-old-15.11
    expr-15.7 expr-15.8 expr-15.9 expr-15.10 expr-15.11 expr-15.12 expr=15.13
    expr=15.14 expr-15.15 expr-15.16
    expr-old-32.43 expr-old-32.44
  } {bigint} {
    expr-23.36 expr-23.37 expr-23.38 expr-23.39 expr-23.41 expr-23.42
    expr-23.43 expr-23.44 expr-23.47 expr-23.48 expr-24.10
    expr-old-32.39 expr-old-32.40 expr-old-36.11 expr-old-36.14 expr-old-34.15
    expr-old-34.16
  } {[bytestring]} {
    parseOld-7.12 parseOld-7.13 parseOld-7.14 
  } ]

# Tests after which there is code (in or out of a test) which causes either
# a fatal harness error, or after which all tests fail/skip. Allows us to
# count passing tests that would otherwise be lost by the harness, as well
# as speed up processing by ignoring chunks of failing tests.
#
# stored as an array of test name -> reason pairs.

array set abort_after {
  assocd-1.1           {}
  async-1.1            {}
  autoMkindex-1.1      {}
  basic-47.1           {need interp before these can work}
  case-1.1             {}
  cmdAH-31.13          {invalid command name "cd"}
  cmdinfo-1.1          {}
  cmdMZ-5.7            {invalid command name "cleanupTests"}
  dcall-1.1            {}
  dstring-1.1          {}
  encoding-1.1         {}
  env-1.3              {can't read "env(test)" no such element in array}
  event-1.1            {invalid command name "update"}
  fCmd-1.1             {}
  filename-11.13       {invalid command name "cd"}
  indexObj-1.1         {}
  init-1.1             {}
  iocmd-12.8           {invalid command name "close"}
  iogt-1.1             {}
  ioUtil-2.8           {invalid command name "cd"}
  link-1.1             {}
  macOSXFCmd-1.1       {}
  mathop-1.1           {}
  misc-1.1             {}
  msgcat-0.0           {}
  obj-1.1              {}
  opt-1.1              {don't have the opt package available}
  package-1.6          {}
  pkgconfig-1.1        {}
  pkgMkIndex-4.2       {invalid command name "pkg_mkIndex"}
  parse-19.4           {invalid command name "cleanupTests"}
  reg-0.1              {invalid command name "doing"}
  registry-1.1         {}
  safe-1.1             {}
  source-7.6           {invalid command name "cleanupTests"}
  Tcl_Main-1.1         {}
  thread-1.1           {}
  timer-1.1            {}
  tcltest-1.1          {}
  unixFile-1.1         {}
  unknown-1.1          {}
  unload-1.1           {}
  utf-1.1              {}
  unixInit-1.1         {}
  winpipe-1.1          {}
  winNotify-1.1        {}
  winTime-1.1          {}
}
