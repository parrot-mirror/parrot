# Copyright (C) 2007-2008, Parrot Foundation.
# $Id$

package Parrot::Pmc2c::UtilFunctions;
use strict;
use warnings;

use Fatal qw(open close);

use base qw( Exporter );
our @EXPORT_OK = qw( count_newlines return_statement dont_edit dynext_load_code
    c_code_coda slurp spew splat filename escape_filename
    args_from_parameter_list
    passable_args_from_parameter_list
);

=over 4

=item C<passable_args_from_parameter_list( $parms )>

Given I<$parms> like C<const STRING *foo, int bar>, returns C<, foo, bar>.
It's handy for passing into function calls.

=cut

sub passable_args_from_parameter_list {
    my $parameters = shift;

    my ($types,$vars) = args_from_parameter_list( $parameters );

    return @{$vars} ? ', ' . join( ', ', @{$vars} ) : '';
}

=item C<args_from_parameter_list( $parms )>

Returns two arrayrefs of arg types and var names.

=cut

sub args_from_parameter_list {
    my $parameters = shift;

    my @types;
    my @vars;
    my @parms = split /\s*,\s*/, $parameters;

    for my $parm ( @parms ) {
        $parm =~ /^(.+)\s+(\S+)$/ or die qq{Can't parse "$parm"};
        push( @types, $1 );
        push( @vars, $2 );
    }
    return \@types, \@vars;
}


=item C<count_newlines($string)>

Returns the number of newlines (C<\n>) in C<$string>.

=cut

sub count_newlines {
    return scalar $_[0] =~ tr/\n//;
}

sub escape_filename {
    ( my $filename = shift ) =~ s|(\\)|$1$1|g;
    return $filename;
}

=item C<dont_edit($pmcfile)>

Returns the "DO NOT EDIT THIS FILE" warning text. C<$pmcfile> is the name
of the original source F<*.pmc> file.

=cut

sub dont_edit {
    my ($pmcfilename) = @_;

    require Parrot::BuildUtil;
    return Parrot::BuildUtil::generated_file_header( $pmcfilename, 'c' ) . <<"EOC";

/* HEADERIZER HFILE: none */
/* HEADERIZER STOP */

EOC
}

=item C<return_statement($method, $body)>

Generate the C code for a C<return> statement, if the body is empty then
make a cast if needed.

This method is imported by subclasses.

=cut

sub return_statement {
    my ( $method, $body ) = @_;

    my $return_type = $method->return_type;
    if ($body) {
        return "$body;" if $return_type eq 'void';
        return "return $body;";
    }
    else {
        return ''                if $return_type eq 'void';
        return "return PMCNULL;" if $return_type eq 'PMC*';
        return "return ($return_type)0;";
    }
}

=item C<dynext_load_code($library_name, %classes)>

C<$library_name> is the name of the dynamic library to be created.

C<%classes> is a map from the PMC names for which code is to be generated,
to dump info (PMC metadata).

This function is exported.

=cut

sub dynext_load_code {
    my ( $classname, %classes ) = @_;
    my $lc_libname = lc $classname;
    my $cout;

    $cout .= <<"EOC";
/*
 * This load function will be called to do global (once) setup
 * whatever is needed to get this extension running
 */

EOC
    $cout .= <<"EOC";

PARROT_DYNEXT_EXPORT Parrot_PMC Parrot_lib_${lc_libname}_load(PARROT_INTERP); /* don't warn */
PARROT_DYNEXT_EXPORT Parrot_PMC Parrot_lib_${lc_libname}_load(PARROT_INTERP)
{
    Parrot_String whoami;
    Parrot_PMC    pmc;
EOC
    while ( my ( $class, $info ) = each %classes ) {
        next if $info->{flags}{no_init};
        $cout .= <<"EOC";
    Parrot_Int type${class};
EOC
    }
    $cout .= <<"EOC";
    int pass;

    /* create a library PMC */
    pmc = constant_pmc_new(interp, enum_class_ParrotLibrary);

    /* TODO: stuff some info into this PMC's props */

    /* for all PMCs we want to register: */
EOC
    while ( my ( $class, $info ) = each %classes ) {
        my $lhs = $info->{flags}{no_init} ? "" : "type$class = ";
        $cout .= <<"EOC";
    whoami = CONST_STRING_GEN(interp, "$class");
    ${lhs}pmc_register(interp, whoami);
EOC
    }
    $cout .= <<"EOC";

    /* do class_init code */
    for (pass = 0; pass <= 1; ++pass) {
EOC

    my @init_order = flatten_class_hierarchy( \%classes );

    for my $class (@init_order) {
        $cout .= <<"EOC";
        Parrot_${class}_class_init(interp, type$class, pass);
EOC
    }
    $cout .= <<"EOC";
    }
    return pmc;
}

EOC
}

=item C<_flatten_class_hierarchy($classes)>

Flattens and returns the given dynpmc hierarchy into a list where all parents
appear before their children.  Internal use only.

=cut

sub flatten_class_hierarchy {
    my $classes = shift;

    my (@parents, @kids);

    while ( my ( $class, $info ) = each %$classes ) {
        next if $info->{flags}{no_init};

        # assume it's a parent for now
        push @parents, $class;

        my @extends = keys %{ $info->{has_parent} };

    PARENT:
        for my $parent (@extends) {
            next PARENT unless exists $classes->{$parent};

            # this dynpmc extends another dynpmc in this group, so note it
            pop  @parents;
            push @kids, $class;
            last PARENT;
        }
    }

    # if there are no intra-group dependencies, return early
    return @parents unless @kids;

    # keep track of all unprocessed dependencies
    my %parents_in_kids = map { $_ => 1 } @kids;

    while (my $kid = shift @kids) {
        my @kid_parents = keys %{ $classes->{$kid}{has_parent} };

        # can't resolve; put at end of list
        if (grep { exists $parents_in_kids{$_} } @kid_parents) {
            push @kids, $kid;
            next;
        }

        delete $parents_in_kids{$kid};
        push @parents, $kid;
    }

    return @parents;
}

=item C<c_code_coda()>

Returns the Parrot C code coda

=back

=cut

sub c_code_coda {
    <<"EOC";
/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */

EOC
}

sub slurp {
    my ($filename) = @_;
    open my $fh, '<', $filename;
    my $data = do { local $/; <$fh> };
    close $fh;
    return $data;
}

sub spew {
    my ( $filename, $data ) = @_;
    open my $fh, '>', $filename;
    print {$fh} $data;
    close $fh;
}

sub splat {
    my ( $filename, $data ) = @_;
    open my $fh, '>>', $filename;
    print {$fh} $data;
    close $fh;
}

sub filename {
    my ( $filename, $type ) = @_;

    $filename =~ s/(\w+)\.\w+$/pmc_$1.h/ if ( $type eq ".h" );
    $filename =~ s/\.\w+$/.c/            if ( $type eq ".c" );
    $filename =~ s/\.\w+$/.dump/         if ( $type eq ".dump" );
    $filename =~ s/\.\w+$/.pmc/          if ( $type eq ".pmc" );
    return $filename;
}
1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
