#! ./parrot-nqp

pir::load_bytecode("compilers/opsc/opsc.pbc");
pir::load_bytecode("nqp-settings.pbc");

plan(6);

my $trans := Ops::Trans::C.new();

my @files := <
    src/ops/debug.ops
    src/ops/sys.ops
>;

my $f := Ops::File.new(|@files);
my $emitter := Ops::Emitter.new(
    :ops_file($f), :trans($trans), :script('ops2c'),
    :flags(
        hash( dir => 'tmp/', core => 1 )
    ),
);

ok( $emitter, "Emitter created");
ok( $emitter<include> eq 'parrot/oplib/core_ops.h', 'Include is correct');
say('# ' ~ $emitter<include>);
ok( $emitter<header> ~~ /^tmp/, 'header file in tmp');
say('# ' ~ $emitter<header>);

#$emitter.print_c_header_file();

my $fh := pir::new__Ps('StringHandle');
$fh.open('header.h', 'w');
$emitter.emit_c_header_file($fh);

$fh.close();
my $header := $fh.readall();

ok($header ~~ /define \s PARROT_OPLIB_CORE_OPS_H_GUARD/, 'Guard generated');
ok($header ~~ /endif/, 'Close guard generated');
ok($header ~~ /DO \s NOT \s EDIT \s THIS \s FILE/, 'Preamble generated');

# vim: expandtab shiftwidth=4 ft=perl6:
