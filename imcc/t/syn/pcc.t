#!perl
use strict;
use TestCompiler tests => 8;

##############################
# Parrot Calling Conventions

output_is(<<'CODE', <<'OUT', "basic syntax - invokecc, constants");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    .const int y = 20
    .pcc_begin prototyped
    .arg 10
    .arg y
    .pcc_call sub
    ret:
    .pcc_end
    end
.end
.pcc_sub _sub prototyped
    .param int a
    .param int b
    print a
    print "\n"
    print b
    print "\n"
    end
.end
CODE
10
20
OUT

##############################
# tail recursion - caller saves - parrot calling convention
output_is(<<'CODE', <<'OUT', "tail recursive sub");
.sub _main
    .local int count
    count = 5
    .local int product
    product = 1
    .local Sub sub
    .local Continuation cc
    newsub sub, .Sub, _fact
    newsub cc, .Continuation, ret
   .pcc_begin prototyped
   .arg product
   .arg count
   .pcc_call sub, cc
 ret:
   .local int result
    .result result
    .pcc_end
    print result
    print "\n"
    end
.end

.pcc_sub _fact prototyped
   .param int product
   .param int count
   if count <= 1 goto fin
   product = product * count
   dec count
   invoke
fin:
   invoke P1
.end

CODE
120
OUT

output_is(<<'CODE', <<'OUT', "proto call, proto sub, invokecc, P param");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    $P0 = new PerlUndef
    $P0 = "ok 1\n"
    $P1 = new PerlUndef
    $P1 = "ok 2\n"
    .pcc_begin prototyped
    .arg $P0
    .arg $P1
    .pcc_call sub
    ret:
    .pcc_end
    print "back\n"
    end
.end
.pcc_sub _sub prototyped
    .param PerlUndef a
    .param PerlUndef b
    print a
    print b
    invoke P1
.end
CODE
ok 1
ok 2
back
OUT
output_is(<<'CODE', <<'OUT', "proto call, un proto sub, invokecc, P param");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    $P0 = new PerlUndef
    $P0 = "ok 1\n"
    $P1 = new PerlUndef
    $P1 = "ok 2\n"
    .pcc_begin prototyped
    .arg $P0
    .arg $P1
    .pcc_call sub
    ret:
    .pcc_end
    print "back\n"
    end
.end
.pcc_sub _sub
    .param PerlUndef a
    .param PerlUndef b
    print a
    print b
    invoke P1
.end
CODE
ok 1
ok 2
back
OUT

output_is(<<'CODE', <<'OUT', "proto call, proto sub, invokecc, S param");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    $S0 = "ok 1\n"
    $S1 = "ok 2\n"
    .pcc_begin prototyped
    .arg $S0
    .arg $S1
    .pcc_call sub
    ret:
    .pcc_end
    print "back\n"
    end
.end
.pcc_sub _sub prototyped
    .param string a
    .param string b
    print a
    print b
    invoke P1
.end
CODE
ok 1
ok 2
back
OUT

output_is(<<'CODE', <<'OUT', "proto call, nonproto sub, invokecc, S param");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    $S0 = "ok 1\n"
    $S1 = "ok 2\n"
    .pcc_begin non_prototyped
    .arg $S0
    .arg $S1
    .pcc_call sub
    ret:
    .pcc_end
    print "back\n"
    end
.end
.pcc_sub _sub non_prototyped
    .param string a
    .param string b
    print a
    print b
    invoke P1
.end
CODE
ok 1
ok 2
back
OUT

output_is(<<'CODE', <<'OUT', "proto call, unproto sub, invokecc, S param");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    $S0 = "ok 1\n"
    $S1 = "ok 2\n"
    .pcc_begin prototyped
    .arg $S0
    .arg $S1
    .pcc_call sub
    ret:
    .pcc_end
    print "back\n"
    end
.end
.pcc_sub _sub
    .param string a
    .param string b
    print a
    print b
    invoke P1
.end
CODE
ok 1
ok 2
back
OUT

output_is(<<'CODE', <<'OUT', "non_proto call, unproto sub, invokecc, S param");
.sub _main
    .local Sub sub
    newsub sub, .Sub, _sub
    $S0 = "ok 1\n"
    $S1 = "ok 2\n"
    .pcc_begin non_prototyped
    .arg $S0
    .arg $S1
    .pcc_call sub
    ret:
    .pcc_end
    print "back\n"
    end
.end
.pcc_sub _sub
    .param string a
    .param string b
    print a
    print b
    invoke P1
.end
CODE
ok 1
ok 2
back
OUT
