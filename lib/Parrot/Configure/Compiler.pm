# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

Parrot::Configure::Compiler - C-Related methods for configuration

=head1 DESCRIPTION

The Parrot::Configure::Compiler module provides methods inherited by
Parrot::Configure which prepare and/or run C programs during
compilation.

=head2 Methods

=over 4

=cut

package Parrot::Configure::Compiler;

use strict;
use warnings;

use base qw( Exporter );

use Carp;
use File::Spec;
use lib ("lib");
use Parrot::Configure::Utils qw(
    prompt copy_if_diff move_if_diff integrate
    capture_output check_progs _slurp
    _run_command _build_compile_command
    move_if_diff
);

=item C<cc_gen()>

    $conf->cc_gen($source)

Generates F<test_$$.c> from the specified source file.

=cut

sub cc_gen {
    my $conf   = shift;
    my $source = shift;

    $conf->genfile( $source, "test_$$.c" );
}

=item C<cc_build()>

    $conf->cc_build($cc_args, $link_args)

These items are used from current config settings:

  $cc, $ccflags, $ldout, $o, $link, $linkflags, $cc_exe_out, $exe, $libs

Calls the compiler and linker on F<test_$$.c>.

=cut

sub cc_build {
    my $conf = shift;
    my ( $cc_args, $link_args ) = @_;

    $cc_args   = '' unless defined $cc_args;
    $link_args = '' unless defined $link_args;

    my $verbose = $conf->options->get('verbose');

    my ( $cc, $ccflags, $ldout, $o, $link, $linkflags, $cc_exe_out, $exe, $libs ) =
        $conf->data->get(qw(cc ccflags ld_out o link linkflags cc_exe_out exe libs));

    # unique test file name for parallel builds
    my $test            = 'test_' . $$;
    my $compile_command = _build_compile_command( $cc, $ccflags, $cc_args );
    my $compile_result  = _run_command( $compile_command, "$test.cco", "$test.cco", $verbose );

    if ($compile_result) {
        confess "C compiler failed (see $test.cco)";
        return $compile_result;
    }

    my $link_result =
        _run_command( "$link $linkflags $test$o $link_args ${cc_exe_out}${test}${exe}  $libs",
        "$test.ldo", "$test.ldo", $verbose )
        and confess "Linker failed (see $test.ldo)";
    if ($link_result) {
        return $link_result;
    }
}

=item C<cc_run()>

    $conf->cc_run();

Calls the F<test> (or F<test.exe>) executable. Any output is directed to
F<test.out>.

=cut

sub cc_run {
    my $conf = shift;
    my $exe      = $conf->data->get('exe');
    my $slash    = $conf->data->get('slash');
    my $verbose  = $conf->options->get('verbose');
    my $test     = 'test_' . $$;
    my $test_exe = ".${slash}${test}${exe}";

    my $run_error;
    if ( defined( $_[0] ) && length( $_[0] ) ) {
        local $" = ' ';
        $run_error = _run_command( "$test_exe @_", "./$test.out", undef, $verbose );
    }
    else {
        $run_error = _run_command( $test_exe, "./$test.out", undef, $verbose );
    }

    my $output = _slurp("./$test.out");

    return $output;
}

=item C<cc_run_capture()>

    $conf->cc_run_capture();

Same as C<cc_run()> except that warnings and errors are also directed to
F<test.out>.

=cut

sub cc_run_capture {
    my $conf    = shift;
    my $exe     = $conf->data->get('exe');
    my $slash   = $conf->data->get('slash');
    my $verbose = $conf->options->get('verbose');
    my $test    = 'test_' . $$;

    if ( defined( $_[0] ) && length( $_[0] ) ) {
        local $" = ' ';
        _run_command( ".${slash}$test${exe} @_", "./$test.out", "./$test.out", $verbose );
    }
    else {
        _run_command( ".${slash}$test${exe}", "./$test.out", "./$test.out", $verbose );
    }

    my $output = _slurp("./$test.out");

    return $output;
}

=item C<cc_clean()>

    $conf->cc_clean();

Cleans up all files in the root folder that match the glob F<test.*>.

=cut

sub cc_clean {    ## no critic Subroutines::RequireFinalReturn
    my $conf = shift;
    unlink map "test_${$}$_", qw( .c .cco .ldo .out ),
        $conf->data->get(qw( o exe )),
        # MSVC
        qw( .exe.manifest .ilk .pdb );
}

=item C<genfile()>

    $conf->genfile($source, $target, %options);

Takes the specified source file, replacing entries like C<@FOO@> with
C<FOO>'s value from the configuration system's data, and writes the results
to specified target file.

Respects the following options when manipulating files (Note: most of the
replacement syntax assumes the source text is on a single line.)

=over 4

=item makefile

If set to a true value, this flag sets (unless overridden) C<comment_type>
to '#', C<replace_slashes> to enabled, and C<conditioned_lines> to enabled.

If the name of the file being generated ends in C<Makefile>, this option
defaults to true.

=item conditioned_lines #+(): #-():

If conditioned_lines is true, then lines in the file that begin with
C<#+(expr):> are skipped if the expr condition is false.
Lines that begin with C<#-(var):> are skipped if the expr condition is true.
For legacy the old syntax #CONDITIONED_LINE(var): and
#INVERSE_CONDITIONED_LINE(var): is also supported.

A condition expr may be a single keyword, which is true if a config key is true
or equal to the platform name  (case-sensitive),
or a logical combination of AND, OR and NOT in case-insensitive LISP syntax
  like (AND var1 var2...) or (OR var1 var2...) or (NOT var1...)
  as in the common lisp reader, 'OR' being the default for multiple keys.
Multiple keys are space seperated.

Keys may also consist of key=value pairs, where the key is checked for
equalness to the value. Note that values may contain no spaces here.
TODO: support quotes in values

  #+(var1 var2...) defaults to #+(or var1 var2...)
  #-(var1 var2...) defaults to #-(or var1 var2...)

For instance:

  #+(win32): $(SRC_DIR)/atomic/gcc_x86$(O)

will be processed if the platform is win32.

  #-(win32 cygwin): $(SRC_DIR)/atomic/gcc_x86$(O)

will be skipped if the platform is win32 or cygwin.

  #+(and win32 glut (not cygwin)):

will be used on win32 and if glut is defined, but not on cygwin.

=item comment_type

This option takes has two possible values, C<#> or C</*>. If present and
set to one of these two values, the generated file will contain a
generated header that is commented out appropriately.

=item ignore_pattern

A regular expression. Any lines in the file matching this expression are
ignored when determining if the target file has changed (and should therefore
be overwritten with a new copy).

=item feature_file

When feature_file is set to a true value, a lines beginning with C<#perl>
forces the remaining lines of the file to be evaluated as perl code. Before
this evaluation occurs, any substitution of @@ values is performed on the
original text.

=item replace_slashes

If set to a true value, this causes any C</>s in the file to automatically
be replaced with an architecture appropriate slash. C</> or C<\>. This is
a very helpful option when writing Makefiles.

=item expand_gmake_syntax

If set to a true value, then certain types of I<gmake> syntax will be expanded
into their full equivalents. For example:

 $(wildcard PATTERN)

Will be replaced B<at config time> with the list of files that match this
pattern. Note! Be very careful when determining whether or not to disable
this expansion during config time and letting I<gmake> evaluate these: the
config system itself may change state of the filesystem, causing the
directives to expand differently depending on when they're run. Another
potential issue to consider there is that most makefiles, while generated
from the root directory, are B<run> from a subdirectory. So relative path names
become an issue.

The I<gmake> replacements are done repeatedly on a single line, so nested
syntax works ok.

=over 4

=item addprefix

=item basename

=item wildcard

=item notdir

=back

=back

=back

=cut

sub genfile {
    my $conf = shift;
    my ( $source, $target, %options ) = @_;

    my $calling_sub = (caller(1))[3] || q{};
    if ( $calling_sub !~ /cc_gen$/ ) {
        $conf->append_configure_log($target);
    }

    open my $in,  '<', $source       or die "Can't open $source: $!";
    open my $out, '>', "$target.tmp" or die "Can't open $target.tmp: $!";

    if ( !exists $options{makefile} && $target =~ m/makefile$/i ) {
        $options{makefile} = 1;
    }

    if ( $options{makefile} ) {
        exists $options{comment_type}      or $options{comment_type}      = '#';
        exists $options{replace_slashes}   or $options{replace_slashes}   = 1;
        exists $options{conditioned_lines} or $options{conditioned_lines} = 1;
    }

    if ( $options{comment_type} ) {
        my @comment = ( 'ex: set ro ft=c:',
            'DO NOT EDIT THIS FILE',
            'Generated by ' . __PACKAGE__ . " from $source" );

        if ( $options{comment_type} eq '#' ) {
            foreach my $line (@comment) {
                $line = "# $line\n";
            }
        }
        elsif ( $options{comment_type} eq '/*' ) {
            foreach my $line (@comment) {
                $line = " * $line\n";
            }
            $comment[0]  =~ s{^}{/*\n};     # '/*'
            $comment[-1] =~ s{$}{\n */};    # ' */'
        }
        else {
            die "Unknown comment type '$options{comment_type}'";
        }
        print {$out} @comment, "\n"; # extra newline after header
    }

    # this loop can not be implemented as a foreach loop as the body
    # is dependent on <IN> being evaluated lazily

    while ( my $line = <$in> ) {

        # everything after the line starting with #perl is eval'ed
        if ( $line =~ /^#perl/ && $options{feature_file} ) {

            # OUT was/is used at the output filehandle in eval'ed scripts
            # e.g. feature.pl or feature_h.in
            no warnings 'once';
            local *OUT = $out;
            use warnings;
            my $text = do { local $/; <$in> };

            # interpolate @foo@ values
            $text =~ s{ \@ (\w+) \@ }{\$conf->data->get("$1")}gx;
            eval $text;
            die $@ if $@;
            last;
        }
        if ( $options{conditioned_lines} ) {
	    # allow multiple keys and nested parens here
            if ( $line =~ m/^#([-+])\((.+)\):(.*)/s ) {
		my $truth = cond_eval($conf, $2);
		next if ($1 eq '-') and $truth;
		next if ($1 eq '+') and not $truth;
                $line = $3;
	    }
	    # but here not (legacy)
	    elsif ( $line =~ m/^#CONDITIONED_LINE\(([^)]+)\):(.*)/s ) {
                next unless cond_eval($conf, $1);
                $line = $2;
            }
            elsif ( $line =~ m/^#INVERSE_CONDITIONED_LINE\(([^)]+)\):(.*)/s ) {
                next if cond_eval($conf, $1);
                $line = $2;
            }
        }

        # interpolate gmake-ish expansions..
        if ( $options{expand_gmake_syntax} ) {
            my $any_gmake;
        GMAKES:
            $any_gmake = 0;

            if (
                $line =~ s{\$ \( wildcard \s+ ([^)]+) \)}{
                join (' ', glob $1)
            }egx
                )
            {
                $any_gmake++;
            }

            if (
                $line =~ s{\$ \( notdir \s+ ([^)]+) \)}{
                join (' ',
                    map { (File::Spec->splitpath($_))[2] }
                        split(' ', $1)
                )
            }egx
                )
            {
                $any_gmake++;
            }

            # documented as removing any .-based suffix
            if (
                $line =~ s{\$ \( basename \s+ ([^)]+) \)}{
                join (' ',
                    map {
                        my @split = File::Spec->splitpath($_);
                        $split[2] =~ s/\.[^.]*$//;
                        File::Spec->catpath(@split);
                    } split(' ', $1)
                )
            }egx
                )
            {
                $any_gmake++;
            }

            if (
                $line =~ s{\$ \( addprefix \s+ ([^,]+) \s* , \s* ([^)]+) \)}{
                my ($prefix,$list) = ($1, $2);
                join (' ',
                    map { $_ = $prefix . $_ }
                        split(' ', $list)
                )
            }egx
                )
            {
                $any_gmake++;
            }

            # we might have only gotten the innermost expression. try again.
            goto GMAKES if $any_gmake;
        }

        # interpolate @foo@ values
        $line =~ s{ \@ (\w+) \@ }{
            if(defined(my $val=$conf->data->get($1))) {
                #use Data::Dumper;warn Dumper("val for $1 is ",$val);
                $val;
            }
            else {
                warn "value for '$1' in $source is undef";
                '';
            }
        }egx;

        if ( $options{replace_slashes} ) {
            if ( $line =~ m{/$} ) {
                die "$source:$.: line ends in a slash\n";
            }
            $line =~ s{(/+)}{
                my $len = length $1;
                my $slash = $conf->data->get('slash');
                '/' x ($len/2) . ($len%2 ? $slash : '');
            }eg;

            # replace \* with \\*, so make will not eat the \
            $line =~ s{(\\\*)}{\\$1}g;
        }

        print $out $line;
    }

    close($in)  or die "Can't close $source: $!";
    close($out) or die "Can't close $target: $!";

    move_if_diff( "$target.tmp", $target, $options{ignore_pattern} );
}

# Return the next subexpression from the expression in $_[0] and
# remove it from the input expression.
# E.g. "and (not win32) has_glut"
#      => and => (not win32) => has_glut
sub next_expr {
    my $s = $_[0];
    return "" unless $s;
    if ($s =~ /^\((.+)\)\s*(.*)/) { # longest match to matching closing paren
	$_[0] = $2 ? $2 : "";	    # modify the 2nd arg
	#print "** \"$s\" => (\"$1\",\"$_[0]\")\n";
	return $1;
    } else {
	$s =~ s/^\s+//;    		# left-trim to make it more robust
	$s =~ m/^([^ \(]+)\s*(.*)?/;    # shortest match to next whitespace or open paren
	$_[0] = $2 ? $2 : "";		# modify the 2nd arg
	#print "** \"$s\" => (\"$1\",\"$_[0]\")\n";
	return $1;
    }
}

# Recursively evaluate AND, OR, NOT for multiple keys as LISP expressions.
# Checks the logical truth of the hash value: exists and not empty.
# Also check the platform name if the hash key does not exist.
# Also check for key=value, like #+(ld=gcc)
sub cond_eval {
    my $conf = $_[0];
    my $expr = $_[1];
    my $key = $expr;
    my @count = split /\s+/, $expr;
    if (@count > 1) { # multiple keys: recurse into
	my $truth;
	my $op = next_expr($expr);
	if ($op =~ /^(or|and|not)$/i) {
	    $op  = lc($op);
	    $key = next_expr($expr);
	} else {
            $key = $op;
	    $op  = 'or';
	}
	while ($key) {
	    last if $truth and ($op eq 'or'); # logical shortcut on OR and already $truth
	    $truth = cond_eval($conf, $key);
	    if    ($op eq 'not') { $truth = $truth ? 0 : 1; }
	    elsif ($op eq 'and') { last unless $truth; } # skip on early fail
	    $key = next_expr($expr);
	}
	return $truth;
    }
    if ($key =~ /^(\w+)=(.+)$/) {
      return $conf->data->get($1) eq $2;
    } else {
      return exists($conf->data->{c}->{$key})
        ? $conf->data()->get($key)
	: $key eq $^O;
  }
}

sub append_configure_log {
    my $conf = shift;
    my $target = shift;
    if ( $conf->{active_configuration} ) {
        my $generated_log = 'MANIFEST.configure.generated';
        open my $GEN, '>>', $generated_log
            or die "Can't open $generated_log for appending: $!";
        print $GEN "$target\n";
        close $GEN or die "Can't close $generated_log after appending: $!";
    }
}

=head1 SEE ALSO

=over 4

=item F<docs/configuration.pod>

=back

=cut

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
