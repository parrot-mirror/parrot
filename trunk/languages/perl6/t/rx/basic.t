#!perl
use strict;
use P6C::TestCompiler tests => 6;
use Test::More qw(skip);

##############################
output_is(<<'CODE', <<'OUT', "Simple atoms.");
sub main() {
    my $s = "hello";
    my $t = "ell";
    print "ok 2\n" if $s =~ /{ print "ok 1\n" }/;
    print "ok 3\n" if $s =~ /hell/;
    print "ok 4\n" if $s =~ /$t/;
    print "ok 5\n" if $s =~ /\0154/; # == 'l'
    print "ok 6\n" if $s =~ /\0154\0154/;
    print "ok 7\n" if $s =~ /\x6c\x6C/;
    print "ok 8\n" if $s =~ /./;
    print "ok 9\n" if $s =~ /<[asdfl]>/;
}
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
ok 7
ok 8
ok 9
OUT

##############################
output_is(<<'CODE', <<'OUT', "Alternation.");
sub main() {
    my $s = 'aaacacaaba';
    print "ok 1\n" if $s =~ /aaa | ac | a/;
    print "ok 2\n" if $s =~ /^ [aaaa | ac | b |]/;
    print "ok 3\n" if $s =~ /^ [[aaaa |] | ac | b]/;
    print "ok 4\n" if $s =~ /^ [[aaaa |] ac | b |]/;
    print "ok 5\n" if $s =~ /^ [[[[[aaaa | aaa] | b] | c] | d] | e]/;
    print "ok 6\n" if $s =~ /^ [e | [d | [c | [b | [aaaa | aaa]]]]]/;
    print "ok 7\n" if $s =~ /[[[[[aaaa | a] | b] | c] | d] | e]$/;
    print "ok 8\n" if $s =~ /[e | [d | [c | [b | [aaaa | a]]]]]$/;
}
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
ok 7
ok 8
OUT

##############################
output_is(<<'CODE', <<'OUT', "Greedy repetition.");
sub main() {
    my $s = 'accaacaacaaba';
    print "ok 1\n" if $s =~ /aca*/;
    print "ok 2\n" if $s =~ /aca+/;
    print "ok 3\n" if $s =~ /aca?/;
    print "ok 4\n" if $s =~ /aca<2>/;
    print "ok 5\n" if $s =~ /aca<0,2>/;
    print "ok 6\n" if $s =~ /aca<2,1000>/;
    my ($n, $m) = (2, 34);
    print "ok 7\n" if $s =~ /aca<2,$m>/;
    print "ok 8\n" if $s !~ /aca<3,$m>/;
    print "ok 9\n" if $s =~ /abb?/;
    print "ok 10\n" if $s !~ /abb+/;
    print "ok 11\n" if $s =~ /abb*/;
}
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
ok 7
ok 8
ok 9
ok 10
ok 11
OUT

##############################
output_is(<<'CODE', <<'OUT', "Frugal repetition.");
sub main() {
    my $s = 'accaacaacaaba';
    print "ok 1\n" if $s =~ /aca*?/;
    print "ok 2\n" if $s =~ /aca+?/;
    print "ok 3\n" if $s =~ /aca??/;
    print "ok 4\n" if $s =~ /aca<2>?/;
    print "ok 5\n" if $s =~ /aca<0,2>?/;
    print "ok 6\n" if $s =~ /aca<2,1000>?/;
# XXX: frugal variable quantifiers not done yet.
#     my ($n, $m) = (2, 34);
#     print "ok 7\n" if $s =~ /aca<2,$m>?/;
#     print "ok 8\n" if $s !~ /aca<3,$m>?/;
    print "ok 9\n" if $s =~ /abb??/;
    print "ok 10\n" if $s !~ /abb+?/;
    print "ok 11\n" if $s =~ /abb*?/;
}
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
ok 9
ok 10
ok 11
OUT

##############################
output_is(<<'CODE', <<'OUT', "Interp array.");
sub main() {
    my @a = ('aaa', 'ac', 'a');
    my $s = 'aaacacaaba';
    print "ok 1\n" if $s =~ /@a/;
    print "ok 2\n" if $s =~ /@a @a/;
    print "ok 3\n" if $s =~ /@a @a @a @a/;
    print "ok 4\n" if $s =~ /@a @a @a @a @a @a/;
    print "ok 5\n" if $s !~ /@a @a @a @a @a @a @a/;
    print "ok 6\n" if $s =~ /@a a @a ac/;
}
CODE
ok 1
ok 2
ok 3
ok 4
ok 5
ok 6
OUT

##############################
output_is(<<'CODE', <<'OUT', "Anonymous rules.");
sub main() {
    my $s = " 12 112213455898898992020 ";
    my $r = rule { @_[0]<2> };
    my $r2 = rx / 89+9 /;
    print "ok 1\n" if $s =~ /<$r2>/;
    print "ok 2\n" if $s =~ /<$r(1)><$r(2)>/;
    print "ok 3\n" if $s =~ /<$r(2)> .* <$r2>/;
}
CODE
ok 1
ok 2
ok 3
OUT
