#! ./parrot-nqp

pir::load_bytecode("opsc.pbc");

my @args := get_args();
my $core := 0;
my @files;
my $i := 0;
my $emit_lines := 1;

if (pir::elements(@args) == 1) {
    say("usage:
ops2c --core
ops2c --dynamic path/to/dynops.ops");
    pir::exit(0);
}

while ($i lt pir::elements(@args)) {
    if (@args[$i] eq '--core') {

        @files := <
            src/ops/core.ops
            src/ops/bit.ops
            src/ops/cmp.ops
            src/ops/debug.ops
            src/ops/io.ops
            src/ops/math.ops
            src/ops/object.ops
            src/ops/pmc.ops
            src/ops/set.ops
            src/ops/string.ops
            src/ops/sys.ops
            src/ops/var.ops
            src/ops/experimental.ops
        >;
        $core := 1;
    }
    elsif (@args[$i] eq '--dynamic') {
        $core := 0;
        $i++;
        @files.push( @args[$i] );
    }
    elsif (@args[$i] eq '--no-lines') {
        #TODO: figure out how to generate line numbers
        # $emit_lines is currently ignored
        $emit_lines := 0;
    }
    $i++;
}


my $trans := Ops::Trans::C.new();

my $start_time := pir::time__N();
my $f;

if $core {
    my $lib := Ops::OpLib.new(
        :num_file('src/ops/ops.num'),
        :skip_file('src/ops/ops.skip'),
    );
    $f := Ops::File.new(|@files, :oplib($lib), :core(1));
}
else {
    $f := Ops::File.new(|@files, :core(0));
}

my $end_time := pir::time__N();
say('# Ops parsed ' ~ ($end_time - $start_time));
my $emitter := Ops::Emitter.new(
    :ops_file($f), :trans($trans),
    :script('ops2c.nqp'), :file(@files[0]),
    :flags( hash( core => $core )
    ),
);

$emitter.print_c_header_file();
$emitter.print_c_source_file();

sub get_args() {
    my $interp := pir::getinterp__P();
    $interp[2];
}


# vim: expandtab shiftwidth=4 ft=perl6:
