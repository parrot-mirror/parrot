#! perl
# Copyright (C) 2001-2006, The Perl Foundation.
# $Id$

=head1 NAME

tools/build/pmc2c.pl - PMC definition to C compiler

=head1 SYNOPSIS

Create F<src/pmc/foo.dump>:

    % perl tools/build/pmc2c.pl --dump src/pmc/foo.pmc ...

Create F<vtable.dump>:

    % perl tools/build/pmc2c.pl --vtable

Print a class tree for the specified PMCs:

    % perl tools/build/pmc2c.pl --tree src/pmc/*.pmc

Create F<src/pmc/foo.c> and C<pmc_foo.h> from F<src/pmc/foo.dump>:

    % perl tools/build/pmc2c.pl -c src/pmc/foo.pmc ...

Create fooX.c and pmc_fooX.h from fooX.dump files, also create libfoo.c
containing the initialization function for all fooX PMCs.

    % perl tools/build/pmc2c.pl --library libfoo -c \
           src/pmc/foo1.pmc src/pmc/foo2.pmc ...

=head1 DESCRIPTION

The job of the PMC compiler is to take .pmc files and create C files
that can be compiled for use with the Parrot interpreter.

=head1 COMMAND-LINE OPTIONS

=over 4

=item C<--debug>

Increase debug level

=item C<--verbose>

Increase verbose level

=item C<--no-lines>

Omit source line info

=item C<--no-body>

Emit an empty body in the dump. This may be useful for debugging.

=item C<--include=/path/to/pmc>

Specify include path where to find PMCs.

=item C<--library=libname>

Specifiy the library name. This will create E<lt>libnameE<gt>.c and
pmc_E<lt>libnameE<gt>.h. The initialization function will be named
after libname and will initialize all PMCs in the library.

=back

=head2 Internals

To see the internal data structures please run:

    % perl tools/build/pmc2c.pl --c --deb --deb sarray.pmc | less

=head2 Compiling PMCs

First, the program determines the names of the .c and .h files from the
basename of the .pmc file (e.g. F<perlint.pmc> -> F<perlint.c> and F<perlint.h>).

Next, the file is searched for C</pmclass \w*/> which attempts to find the
class being declared.

Once the class is found, all of its superclasses are scanned and their
methods added to the methods of the current PMC. PMCs default to
inheriting from 'default'. Only single inheritance is supported.

Once the superclass is determined, it is processed and its method names
are extracted and saved.

Next, each method body is processed with various directives (see below)
getting replaced by their appropriate values.

Finally, the .c and .h files are generated. The appropriate base class
header files are included.

If the C<noinit> flag was used, then no init function is generated.
Otherwise, one is generated which sets up the vtable and enters it into
the C<vtables> array.

The .c file is generated by appending the functions after the various
directives have been replaced.

=head2 PMC File Syntax

The basic syntax of a PMC file is

=over 4

=item 1.

A preamble, consisting of code to be copied directly to the .c file

=item 2.

The C<pmclass> declaration:

    pmclass PMCNAME [flags] {

where C<flags> are:

=over 4

=item C<extends PMCPARENT>

All methods not defined in PMCNAME are inherited from the PMCPARENT class.
If no parent class is defined, methods from F<default.pmc> are used.

=item C<abstract>

This class cannot be instantiated. Abstract classes are shown with lower
case class names in the class tree.

=item C<noinit>

Used with C<abstract>: No C<class_init> code is generated.

=item C<const_too>

Classes with this flag get 2 vtables and 2 enums, one pair with
read/write set methods, and one with read-only set methods.

=item C<need_ext>

The class needs a C<PMC_EXT> structure. For instance, any class using
C<PMC_data> will have C<need_ext>.

=item C<does interface>

The class 'does' the given interfaces (the collection of methods
which the class implements).

The default is "scalar". Other currently used interfaces are:

    array    : container PMC with numerically-keyed elements
    event    : PMC that can be used with event queue
    hash     : container PMC with string-keyed elements
    library  : PMC that corresponds to a dynamic library
    ref      : PMC that references another PMC
    string   : PMC that behaves similarly to the base string type
    boolean  : PMC that does true/false only.
    integer  : PMC that behaves similarly to the base int type
    float    : PMC that behaves similarly to the base number type
    scalar   : (only used by the sample src/dynpmc/foo.pmc)

This is not a canonical list, but merely a snapshot of what's in use.

=item C<dynpmc>

The class is a dynamic class. These have a special C<class_init>
routine suitable for dynamic loading at runtime. See the F<src/dynpmc>
directory for an example.

=item C<group GROUP>

The class is part of a group of interrelated PMCs that should be
compiled together into a single shared library of the given name. Only
valid for dynamic PMCs.

=item C<lib LIB>

The class needs an external library.

=item C<hll HLL>

The High level language this PMC corresponds to.

=item C<maps Type>

The basic parrot PMC type that this PMC correspond to for C<.HLL> usage. For example:

    pmcclass TclInt hll Tcl maps Integer

allows this PMC to automatically be used when autoboxing C<I> registers to PMCs.

Requires the C<hll> flag.

=back

=item 3.

A list of vtable method implementations

=item 4.

The final close C<}>

=back

=head2 Method Body Substitutions

The vtable method bodies can use the following substitutions:

=over 4

=item C<SELF>

Converted to the current PMC object of type C<PMC *>.

=item C<INTERP>

Converted to the interpreter object.

=item C<OtherClass.SELF.method(a,b,c)>

Calls the static vtable method 'method' in C<OtherClass>.

=item C<SELF.method(a,b,c)>

Calls the vtable method 'method' using the static type of C<SELF> (in
other words, calls another method defined in the same file).

=item C<DYNSELF.method(a,b,c)>

Calls the vtable method 'method' using the dynamic type of C<SELF>.

=item C<DYNSELF(a,b,c)>

Same as above, but calls the current method.

=item C<OtherClass.SUPER(a,b,c)>

Calls the overridden implementation of the current method in
C<OtherClass>.

=item C<SUPER(a,b,c)>

Calls the overridden implementation of the current method in the nearest
superclass, using the static type of C<SELF>.

=item C<DYNSUPER(a,b,c)>

As above, but uses the actual dynamic type of C<SELF>.

=back

=head1 AUTHOR

Leopold Toetsch.

Cleaned up by Matt Diephouse.

Many thanks to the author of F<pmc2c.pl>, many useful code pieces got
reused.

=cut

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../..";
use lib "$FindBin::Bin/../../lib";
use Parrot::Vtable;
use Parrot::Pmc2c qw(count_newlines);
use Parrot::Pmc2c::Library;
use Data::Dumper;
use Getopt::Long;

my %opt;

main();

=head1 FUNCTIONS

=head2 my $path = find_file( [$dir1, $dir2], $file, $die_unless_found_flag );

Return the full path to $file (search in the given directories).
Optionally, die with an error message if that file cannot be found.

=cut

sub find_file {
    my ($include, $file, $die_unless_found) = @_;

    if (File::Spec->file_name_is_absolute($file) && -e $file) {
        return $file;
    }

    foreach my $dir ( @$include ) {
        my $path = File::Spec->catfile( $dir, $file );
        return $path if -e $path;
    }

    die "can't find file '$file' in path '", join("', '", @$include), "'"
        if $die_unless_found;

    undef;
}

=head2 dump_default()

Create a .dump file for the default vtable (from which all PMCs inherit).

=cut

sub dump_default {
    my $file    = "$FindBin::Bin/../../vtable.tbl";
    my $default = parse_vtable($file);
    my $dump    = $file;
    $dump =~ s/\.\w+$/\.dump/;

    my $vtd = open_file( ">", $dump );

    my %vtable = (
        flags   => {},
        pre     => '',
        post    => '',
    );
    my %meth_hash;
    my $i = 0;
    foreach my $entry (@$default) {
        $meth_hash{$entry->[1]} = $i++;
        push @{$vtable{methods}},
            {
                parameters  => $entry->[2],
                meth        => $entry->[1],
                type        => $entry->[0],
                section     => $entry->[3],
                mmd         => $entry->[4],
                attr        => $entry->[5]
            };
    }
    $vtable{'has_method'} = \%meth_hash;

    my $Dumper = Data::Dumper->new([\%vtable], ['class']);
    $Dumper->Indent(3);
    print $vtd $Dumper->Dump();
    close $vtd;
}

=head2 my ($balanced, $remaining) = extract_balanced($code);

Remove a balanced {} construct from the beginning of $code.
Return it and the remaining code.

=cut

sub extract_balanced {
    my $code    = shift;
    my $balance = 0;

    $code =~ s/^\s+//;

    # create a copy and remove strings and comments so that
    # unbalanced {} can be used in them in PMCs, being careful to
    # preserve string length.
    local $_ = $code;
    s[
        ( ' (?: \\. | [^'] )* '     # remove ' strings
        | " (?: \\. | [^"] )* "     # remove " strings
        | /\* .*? \*/ )             # remove C comments
    ]
    [ "-" x length $1 ]sexg;

    /^\{/ or die "bad block open: ", substr($code,0,10), "...";

    while (/ (\{) | (\}) /gx) {
        if($1) {
            $balance++;
        } else { # $2
            $balance--;
            return substr($code, 0, pos, ""), $code
                if not $balance;
        }
    }
    die "Badly balanced" if $balance;
}


=head2 my ($pre, $class_name, $flags) = parse_flags(\$code);

Extract a class signature from the code ref and return (a) the
code found before the signature, (b) the name of the class, and
(c) a hash ref containing the flags associated with the class
(such as 'extends' and 'does').

=cut

sub parse_flags {
    my $c = shift;

    $$c =~ s/^(.*?^\s*)pmclass ([\w]*)//ms;
    my ($pre, $classname) = ($1, $2);

    # flags that have values passed with them
    my %has_value = map { $_ => 1 } qw(does extends group lib hll maps);

    my (%flags, $parent_nr);
    # look through the pmc declaration header for flags such as noinit
    while ($$c =~ s/^\s*(\w+)//s) {
        my $flag = $1;
        if ($has_value{$flag}) {
            $$c =~ s/^\s+(\w+)//s
                or die "Parser error: no value for '$flag'";

            $flags{$flag}{$1} =
                $flag eq 'extends' ? ++$parent_nr : 1;
        }
        else {
            $flags{$flag} = 1;
        }
    }

    # setup some defaults
    if ($classname ne 'default') {
        $flags{extends}{default} = 1 unless $flags{extends};
        $flags{does}{scalar}     = 1 unless $flags{does};
    }

    return $pre, $classname, \%flags;
}

=head2 my ($attrs) = parse_method_attrs($attr_string)

Parse a list of method attribute and return an hash ref of them

=cut

sub parse_method_attrs {
    my $flags = shift;
    my %result;
    ++$result{$1} while $flags =~ /:(\w+)/g;
    return \%result;
}

=head2 my ($name, $attributes) = parse_pmc($code);

Parse PMC code and return the class name and a hash ref of attributes.

=cut

sub parse_pmc {
    my $code = shift;

    my $signature_re = qr{
    ^
    (?:                 #blank spaces and comments and spurious semicolons
      [;\n\s]*
      (?:/\*.*?\*/)?    # C-like comments
    )*

    (METHOD\s+)?        #method flag

    (\w+\**)            #type
      \s+
        (\w+)           #method name
      \s*
        \( ([^\(]*) \)  #parameters
    \s*
    ((?::(\w+)\s*)*)    #method attrs
    }sx;

    my ($pre, $classname, $flags)   = parse_flags(\$code);
    my ($classblock, $post)         = extract_balanced($code);

    my $lineno  = 1 + count_newlines($pre);
    $classblock = substr($classblock, 1,-1); # trim out the { }

    my (@methods, %meth_hash, $class_init);

    while ($classblock =~ s/($signature_re)//) {
        $lineno += count_newlines($1);
        my ($flag, $type, $methodname, $parameters) = ($2,$3,$4,$5);
        my $attrs                                   = parse_method_attrs($6);
        my ($methodblock, $rema)                    = extract_balanced($classblock);

        $methodblock = "" if $opt{nobody};
        if ($methodname eq 'class_init') {
            $class_init = {
                meth        => $methodname,
                body        => $methodblock,
                line        => $lineno,
                type        => $type,
                parameters  => $parameters,
                loc         => "vtable",
                attrs       => $attrs,
            };
        }
        else {
            # name => method idx mapping
            $meth_hash{$methodname} = scalar @methods;
            my @mmds = ($methodblock =~ /MMD_(\w+):/g);
            push @methods,
                {
                    meth        => $methodname,
                    body        => $methodblock,
                    line        => $lineno,
                    type        => $type,
                    parameters  => $parameters,
                    loc         => $flag ? "nci" : "vtable",
                    mmds        => [ @mmds ],
                    attrs       => $attrs,
                };
        }
        $classblock = $rema;
        $lineno += count_newlines($methodblock);
    }

    if ($class_init) {
        $meth_hash{'class_init'} = scalar @methods;
        push @methods, $class_init;
    }


    return $classname,
           {
               pre          => $pre,
               flags        => $flags,
               methods      => \@methods,
               post         => $post,
               class        => $classname,
               has_method   => \%meth_hash
           };
}

=head2 gen_parent_list( [$dir1, $dir2], $class, $classes );

Generate an ordered list of parent classes to put in the
I<< $classes->{class}->{parents} >> array, using the given directories
to find parents.

=cut

sub gen_parent_list {
    my ($include, $this, $all) = @_;

    my @todo  = ($this);
    my $class = $all->{$this};

    while (@todo) {
        my $n   = shift @todo;
        my $sub = $all->{$n};
        next if $n eq 'default';

        my %parent_hash = %{$sub->{flags}{extends}};
        my @parents     = sort { $parent_hash{$a} <=> $parent_hash{$b} }
            keys %parent_hash;
        for my $parent (@parents) {
            next if exists $class->{has_parent}{$parent};

            $all->{$parent} = read_dump($include, lc("$parent.pmc"))
                if not $all->{$parent};

            $class->{has_parent}{$parent} = { %{$all->{$parent}{has_method} }};
            push @todo, $parent;
            push @{ $class->{parents} }, $parent;
        }
    }
}

=head2 dump_1_pmc($file);

Returns the class structure from I<$file> for a .dump file.

=cut

sub dump_1_pmc {
    my $file = shift;
    $file =~ s/\.\w+$/.pmc/;

    my $fh = open_file( "<", $file );
    my $contents = do { local $/; <$fh> };
    close $fh;
    return parse_pmc($contents);
}

=head2 gen_super_meths($class, $vtable)

Generate a list of inherited methods for I<$class> by searching the
inheritence tree. The method list is found in I<$vtable>.

=cut

sub gen_super_meths {
    my ($self, $vt, $all) = @_;

    # look through all meths in class and locate the nearest parent
    foreach my $entry (@{ $vt->{methods} } ) {
        my $meth = $entry->{meth};
        next if exists $self->{super}{$meth};
        foreach my $pname (@{ $self->{parents} } ) {
            if (exists ($self->{has_parent}{$pname}{$meth} )) {
                $self->{super}{$meth} = $pname;
                my $n = $self->{has_parent}{$pname}{$meth};
                my $super_mmd = $all->{$pname}{methods}[$n]{mmds};
                if ($super_mmd && scalar @{ $super_mmd }) {
                    ##print "** @{ $super_mmd } **\n";
                    push @{ $self->{super_mmd} },
                        { $pname => $super_mmd,
                          'meth' => $meth};
                }
                last;
            }
        }
        unless (exists $self->{super}{$meth}) {
            # XXX this is a quick hack to get the inheritance
            # ParrotClass isa delegate
            #
            # delegate has everything autogenerated, so these
            # methods aren't seen and not inherited properly
            #
            # the correct way would be to look at
            # $self->implements but when dumping there isn't
            # a $class object
            $self->{super}{$meth} =
                $self->{class} eq 'ParrotObject' ||
                $self->{class} eq 'ParrotClass' ?
                'delegate' :
                'default';
        }
    }
}


=head2 add_defaulted($class_structure, $vtable);

Add methods to the class structure for each method found in the
vtable. This is used to determine all of the 'default' methods
from the F<vtable.dump>.

=cut

sub add_defaulted {
    my ($class, $vt) = @_;

    foreach my $e ( @{$vt->{methods}} ) {
        my $meth = $e->{meth};
        $class->{super}{$meth} = 'default';
    }
}

=head2 dump_is_newer($file);

Return whether the dump of a file is newer than the PMC file.
(If it's not, then the PMC file has changed and the dump has
not been updated.)

=cut

sub dump_is_newer {
    my $file = shift;
    my $pmc = $file;
    $pmc =~ s/\.\w+$/.pmc/;

    ($pmc ne $file) or die "$pmc is the same as the original name";

    my $pmc_dt  = (stat $pmc)[9];
    my $dump_dt = (stat $file)[9];

    return $dump_dt > $pmc_dt;
}

=head2 dump_pmc( [$dir1, $dir2], $file1, $file2, ... );

Create a .dump file for each of the passed files (which can be
found in the given directories). A '*.pmc' glob may also be passed
to emulate a proper shell in the presence of a dumb one.

=cut

sub dump_pmc {
    my ($include, @files) = @_;
    # help these dumb 'shells' that are no shells
    @files = glob $files[0] if $files[0] eq '*.pmc';

    my %all;
    for my $file (@files) {
        my ($class, $res) = dump_1_pmc($file);
        $res->{file} = $file;
        $all{$class} = $res;
    }

    $all{default} = read_dump($include, "default.pmc")
        if not $all{default};

    my $vt = read_dump($include, "vtable.pmc");
    add_defaulted($all{default}, $vt);

    foreach my $name (keys %all) {
        my $file = $all{$name}->{file};
        $file =~ s/\.\w+$/.dump/;

        my $existing = find_file($include, $file);
        if ($existing && -e $existing && dump_is_newer($existing)) {
            if ($file =~ /default\.dump$/) {
                next; # don't overwite default.dump
            }
            else {
                $file = $existing; # XXX: overwrite anything else
            }
        }

        my $class = $all{$name};
        gen_parent_list($include, $name, \%all);
        gen_super_meths($class, $vt, \%all);

        my $Dumper = Data::Dumper->new([$class], ['class']);
        $Dumper->Indent(1);

        my $fh = open_file( ">", $file );
        print $fh $Dumper->Dump;
        close $fh;
    }
}

=head2 read_dump( [$dir1, $dir2], $file );

Read in the class definition found in $file (which is found in one
of the given directories) and recreate the data structure.

=cut

sub read_dump {
    my ($include, $file) = @_;

    $file =~ s/\.\w+$/.dump/;
    $file = find_file($include, $file, 1);

    my $fh = open_file( "<", $file );

    my $class;
    eval do { local $/; <$fh> };
    die $@ if $@;

    close $fh;
    $class;
}


=head2 print_tree( [$dir1, $dir2], 0, $file1, $file2, ... );

Print the inheritence tree for each of the files, using the
given directories to search for all of correct PMCs. The middle
argument is the display depth, which is used for the recursive
definition of this function.

=cut

sub print_tree {
    my ($include,$depth, @files) = @_;

    for my $file (@files) {
        my $class = read_dump($include, $file);

        print "    " x $depth, $class->{class}, "\n";
        print_tree($include, $depth + 1, lc("$_.pmc"))
            for keys %{$class->{flags}{extends}};
    }
}

=head2 gen_c( [$dir1, $dir2], $file1, $file2, ... )

Generate the C source code file for each of the files passed in,
using the directories passed in to search for the PMC dump files.

=cut

sub gen_c {
    my ($include, @files) = @_;
    my %pmcs = map { $_, read_dump($include, $_) } @files;

    Parrot::Pmc2c::Library
        ->new( \%opt, read_dump($include, "vtable.pmc"), %pmcs )
        ->write_all_files;
}

=head2 gen_def( [$dir1, $dir2], \%pmc )

Generate a .def file for symbols to export for dynamic PMCs.
Currently unused, but retained for being a basis for supporting
platforms that need a symbol export list.

sub gen_def {
    my ($include, $pmcs) = @_;

    my ($pmcfilename, $pmcname);
    my %groups;
    foreach $pmcfilename (keys %$pmcs) {
        # Skip for non-dynpmcs.
        next unless $pmcs->{$pmcfilename}->{flags}->{dynpmc};

        # Get copy of name without extension.
        $pmcname = $pmcfilename;
        $pmcname =~ s/\.pmc$//;

        # Locate .h file and add everything it exports to a list.
        my @exports = ();
        my $file = find_file($include, "pmc_$pmcname.h", 1);

        my $fh = open_file( "<", $file );
        while (<$fh>) {
            if (/^(?:extern\s+)?\w+\*?\s+\*?(\w+)\s*\([^)]+\)\s*;/) {
                push @exports, $1;
            }
        }
        close $fh;

        # Locate .c file and add everything it exports to a list.
        $file = find_file($include, "$pmcname.c", 1);

        $fh = open_file( "<", $file );
        while (<$fh>) {
            if (/^(?:extern\s+)?\w+\*?\s+\*?(\w+)\s*\([^)]+\)\s*;/) {
                push @exports, $1;
            }
        }
        close $fh;

        # If it's in a group, put it in group's PMC array.
        if ($pmcs->{$pmcfilename}->{flags}->{group}) {
            for (keys %{$pmcs->{$pmcfilename}->{flags}->{group}}) {
                push @{$groups{$_}}, @exports;
            }
        }

        # Generate .def file for it.
        # XXX JW Needn't generate these for PMCs in a group?
        #        For now, simplifies sutff.
        $file =~ s/\.c$/.def/;
        $fh = open_file( ">", $file );
        print $fh "LIBRARY $pmcname\nEXPORTS\n";
        print $fh "\t$_\n" foreach @exports;
        close $fh;
    }

    # Generate .def file for groups.
    for my $group (keys %groups) {
        # Get filename of where we'll stash the .def file.
        my $deffile = "$group.def";

        # Does the DEF file already exist?
        my $defexists = -e $deffile;

        # Open the file to append to it.
        my $fh = open_file( ">>", $deffile );
        print $fh "LIBRARY $group\nEXPORTS\n\tParrot_lib_${group}_load\n" unless $defexists;
        print $fh "\t$_\n" foreach @{$groups{$group}};
        close $fh;
    }
}

=cut

sub open_file {
    my $direction = shift;
    my $filename = shift;

    my $action =
        ($direction eq "<") ? "Reading" :
        ($direction eq ">>") ? "Appending" : "Writing";

    print "$action $filename\n" if $opt{verbose};
    open my $fh, $direction, $filename or die "$action $filename: $!\n";
    return $fh;
}

#
#   main()
#
# Get and set the correct options and execute the runmode
# specified in @ARGS.
#
sub main {
    my ($default, $dump, $gen_c, $tree, @include);
    # initialization to prevent warnings
    %opt = map { $_ => 0 } qw(nobody nolines debug verbose);

    my %action;

    GetOptions(
        "include=s"     => \@include,

        "vtable"        => \$action{default},
        "dump"          => \$action{dump},
        "c|gen-c"       => \$action{gen_c},
        "tree"          => \$action{tree},

        "no-body"       => \$opt{nobody},
        "no-lines"      => \$opt{nolines},
        "debug+"        => \$opt{debug},
        "verbose+"      => \$opt{verbose},
        "library=s"     => \$opt{library},
    ) or exit(1);
    unshift @include, ".", "$FindBin::Bin/../..", "$FindBin::Bin/../../src/pmc/";

    if ( 0 == grep { $action{$_} } keys %action ) {
        die "No action specified!\n";
    }

    if ($action{default}) {
        dump_default();
        exit;
    }

    # All other actions require files
    if ( !@ARGV ) {
        die "No files specified.\n";
    }

    if ( $action{dump} ) {
        dump_pmc(\@include, @ARGV);
    }

    if ( $action{tree} ) {
        print_tree(\@include, 0, @ARGV);
    }

    if ( $action{gen_c} ) {
        gen_c(\@include, @ARGV);
    }
}

# vim: expandtab shiftwidth=4:
