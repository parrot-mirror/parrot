package Parrot::Test;

use strict;
use vars qw(@EXPORT @ISA $TEST_PROG_ARGS);
use Parrot::Config;

# 5.005_03 Env.pm doesn't make its arguments immune from use strict 'vars';
use Env qw($TEST_PROG_ARGS);

require Exporter;
require Test::Builder;
require Test::More;
my $Builder = Test::Builder->new;

@EXPORT = ( qw(output_is   output_like   output_isnt),
	    qw(pir_output_is   pir_output_like   pir_output_isnt),
            qw(c_output_is c_output_like c_output_isnt),
            qw(skip) );
@ISA = qw(Exporter);

sub import {
  my( $class, $plan, @args ) = @_;

  Test::Builder->plan( $plan, @args );

  __PACKAGE__->export_to_level( 2, __PACKAGE__ );
}

# this kludge is an hopefully portable way of having
# redirections ( tested on Linux and Win2k )
sub _run_command {
  my( $command, %redir ) = @_;

  foreach (keys %redir) {
    /^STD(OUT|ERR)$/ or die "I don't know how to redirect '$_' yet! ";
  }
  foreach (values %redir) {
    $_ = 'NUL:' if $^O eq 'MSWin32' and $_ eq '/dev/null';
  }

  my $out = $redir{'STDOUT'} || '';
  my $err = $redir{'STDERR'} || '';

  if ( $out and $err and $out eq $err ) {
    $err = "&STDOUT";
  }

  local *OLDOUT if $out;
  local *OLDERR if $err;

  # Save the old filehandles; we must not let them get closed.
  open  OLDOUT, ">&STDOUT" or die "Can't save     stdout" if $out;
  open  OLDERR, ">&STDERR" or die "Can't save     stderr" if $err;

  open  STDOUT, ">$out"    or die "Can't redirect stdout" if $out;
  open  STDERR, ">$err"    or die "Can't redirect stderr" if $err;

  if (defined $ENV{VALGRIND}) {
    $command = "$ENV{VALGRIND} $command";
  }

  system $command;
  my $exit_code = $? >> 8;

  close STDOUT             or die "Can't close    stdout" if $out;
  close STDERR             or die "Can't close    stderr" if $err;

  open  STDOUT, ">&OLDOUT" or die "Can't restore  stdout" if $out;
  open  STDERR, ">&OLDERR" or die "Can't restore  stderr" if $err;

  return $exit_code;
}


sub per_test {
  my ($ext,$count) = @_;
  my $t = $0;
  $t =~ s/\.t$/_$count$ext/;
  return $t;
}

sub generate_pbc_for {
    my ($assembly,$directory,$count, $as_f) = @_;
    local( *ASSEMBLY );
    open ASSEMBLY, "> $as_f" or die "Unable to open '$as_f'";
    binmode ASSEMBLY;
    print ASSEMBLY $assembly;
    close ASSEMBLY;
}

# Map the Parrot::Test function to a Test::Builder method.
my %Test_Map = ( output_is   => 'is_eq',
                 output_isnt => 'isnt_eq',
                 output_like => 'like',
		 pir_output_is   => 'is_eq',
                 pir_output_isnt => 'isnt_eq',
                 pir_output_like => 'like'
               );

my $count = 0;

*skip = \&Test::More::skip;

sub generate_functions {
  my ($package, $pbc_generator, $directory) = @_;

  sub slurp_file {
    open SLURP, "< $_[0]" or die "open '$_[0]': $!";
    local $/ = undef;
    my $file = <SLURP> . '';
    $file =~ s/\cM\cJ/\n/g;
    close SLURP;
    return $file;
  }

  my $PARROT = ${directory} . 'parrot' . $PConfig{exe};


  foreach my $func ( keys %Test_Map ) {
    no strict 'refs';

    *{$package.'::'.$func} = sub ($$;$) {
	my( $assembly, $output, $desc ) = @_;

	$count = $Builder->current_test + 1;

	#set up default description
	(undef, my $file, my $line) = caller;
	unless ($desc) {
	    $desc = "($file line $line)";
	}

	$output =~ s/\cM\cJ/\n/g;

	#generate pbc for this test (may be overriden)
	my $out_f = per_test('.out',$count);
	my $as_f = per_test('.pasm',$count);

	if ($assembly =~ /^##PIR##/ || $func =~ /^pir_/) {
	    $as_f = per_test('.imc',$count);
	}

	$TEST_PROG_ARGS = $ENV{TEST_PROG_ARGS} || '';
	my $args = $TEST_PROG_ARGS;

	my $run_pbc = 0;
	if ($args =~ s/--run-pbc//) {
	    # native tests with --run-pbc don't make sense
	    if ($as_f =~ /native_pbc/) {
		return $Builder->ok(1, $desc);
	    }
	    my $pbc_f = per_test('.pbc', $count);
	    $run_pbc = 1;
	    $args = "$args -o $pbc_f -r -r";
	}

	# native tests are just run
	if ($as_f =~ /native_pbc/) {
	    $as_f = per_test('.pbc',$count);
	    $run_pbc = 0;
	}
	else {
	    $pbc_generator->( $assembly, $directory, $count, $as_f );
	}

        my $cmd;
        my $exit_code = 0;
	my $pass = 0;

	$cmd = "$PARROT ${args} $as_f";
	$exit_code = _run_command($cmd, STDOUT => $out_f, STDERR => $out_f);

	my $meth = $Test_Map{$func};
	unless ($pass) {
	    $pass = $Builder->$meth( slurp_file($out_f), $output, $desc );
	    $Builder->diag("'$cmd' failed with exit code $exit_code")
	      if $exit_code and not $pass;
        }

	unless($ENV{POSTMORTEM}) {
	    unlink $out_f;
	}

	return $pass;
    }
  }

  my %C_Test_Map = ( c_output_is   => 'is_eq',
                     c_output_isnt => 'isnt_eq',
                     c_output_like => 'like'
                   );

  foreach my $func ( keys %C_Test_Map ) {
    no strict 'refs';

    *{$package.'::'.$func} = sub ($$;$ ) {
      my( $source, $output, $desc ) = @_;

      $count = $Builder->current_test + 1;

      $output =~ s/\cM\cJ/\n/g;
      local( *SOURCE );
      my $source_f = per_test('.c',$count);
      my $obj_f = per_test($PConfig{o},$count);
      my $exe_f = per_test($PConfig{exe},$count);
      $exe_f =~ s@[\\/:]@$PConfig{slash}@g;
      my $out_f = per_test('.out',$count);
      my $build_f = per_test('.build',$count);

      open SOURCE, "> $source_f" or die "Unable to open '$source_f'";
      binmode SOURCE;
      print SOURCE "/* DO NOT EDIT - Autogenerated test file */\n";
      print SOURCE $source;
      close SOURCE;

      my $libparrot = $PConfig{blib_lib_libparrot_a};
      $libparrot =~ s/\$\(A\)/$PConfig{a}/;

      my ($cmd, $exit_code);
      $cmd = "$PConfig{cc} $PConfig{ccflags} $PConfig{cc_debug} -I./include -c " .
             "$PConfig{cc_o_out}$obj_f $source_f";
      $exit_code = _run_command($cmd, 'STDOUT' => $build_f, 'STDERR' => $build_f);
      $Builder->diag("'$cmd' failed with exit code $exit_code") if $exit_code;

      if (! -e $obj_f) {
	$Builder->diag("Failed to build '$obj_f': " . slurp_file($build_f));
	unlink $build_f;
	$Builder->ok(0,$desc);
	return 0;
      }

      $cmd = "$PConfig{link} $PConfig{linkflags} $PConfig{ld_debug} $obj_f " .
             "$PConfig{ld_out}$exe_f $libparrot $PConfig{libs}";
      $exit_code = _run_command($cmd, 'STDOUT' => $build_f, 'STDERR' => $build_f);
      $Builder->diag("'$cmd' failed with exit code $exit_code") if $exit_code;


      if (! -e $exe_f) {
	$Builder->diag("Failed to build '$exe_f': " . slurp_file($build_f));
	unlink $build_f;
	$Builder->ok(0,$desc);
	return 0;
      }

      $cmd       = ".$PConfig{slash}$exe_f";
      $exit_code = _run_command($cmd, 'STDOUT' => $out_f, 'STDERR' => $out_f);

      my $meth = $C_Test_Map{$func};
      my $pass = $Builder->$meth( slurp_file($out_f), $output, $desc );
      $Builder->diag("'$cmd' failed with exit code $exit_code")
        if $exit_code and not $pass;

      unless($ENV{POSTMORTEM}) {
        unlink $out_f;
	unlink $build_f;
	unlink $exe_f;
	unlink $obj_f;
      }
      return $pass;
    }
  }
}

Parrot::Test::generate_functions(__PACKAGE__,\&generate_pbc_for,
                                 $^O eq 'MSWin32' ? '.\\' : "./");

1;
