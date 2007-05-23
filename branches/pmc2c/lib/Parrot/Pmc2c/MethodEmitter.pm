# Copyright (C) 2004-2007, The Perl Foundation.

# $Id: Pmc2c.pm 18426 2007-05-05 14:41:57Z bernhard $

=head1 NAME

Parrot::Pmc2c - PMC to C Code Generation

=head1 SYNOPSIS

    use Parrot::Pmc2c;

=head1 DESCRIPTION

C<Parrot::Pmc2c> is used by F<tools/build/pmc2c.pl> to generate C code from PMC files.

=head2 Functions

=over

=cut

package Parrot::Pmc2c::Method;
use strict;
use warnings;
use Data::Dumper;
use Parrot::Pmc2c::Emitter;
use Parrot::Pmc2c::UtilFunctions
    qw( gen_ret dont_edit count_newlines dynext_load_code c_code_coda );
use Text::Balanced 'extract_bracketed';
use Parrot::Pmc2c::PCCMETHOD;

$SIG{'__WARN__'} = sub { use Carp; warn $_[0]; Carp::confess; };

=item C<body($method, $line, $out_name)>

Returns the C code for the method body. C<$line> is used to accumulate
the number of lines, C<$out_name> is the name of the output file we are
generating.

=cut

sub generate_body {
    my ( $self, $pmc ) = @_;

    my $cout    = "";
    my $pmcname = $pmc->name;
    my $meth    = $self->name;
    my $body    = $self->body;
    $body =~ s/^[ ]{4}//mg;
    my $super = $pmc->{super}{$meth};

    if ( $self->is_vtable ) {
        $body = $self->rewrite_vtable_method( $pmc, $super, $pmc->{super}, $body );
    }
    else {
        $body = $self->rewrite_nci_method( $pmc );
    }
    Parrot::Pmc2c::PCCMETHOD::rewrite_pccinvoke( $self, \$body );

    $cout .= $self->decl( $pmc, 'CFILE' );

    if ( exists $self->{pre_block} ) {
        $cout .= $self->{pre_block};
        $cout .= $body;
        $cout .= $self->{post_block};
        $cout .= "\n}\n";
    }
    else {
        $cout .= "{$body\n}\n";
    }

    for my $mmd ( @{ $self->mmds } ) {
        $cout .= $mmd->generate_body($pmc);
    }

    #remove trailing whitespace
    $cout =~ s/^\s+$//mg;
    return $cout;
}

sub generate_headers {
    my ( $self, $pmc ) = @_;
    my $hout = "";
    
    $hout .= $self->decl( $pmc, 'HEADER' );

    for my $mmd ( @{ $self->mmds } ) {
        $hout .= $mmd->decl( $pmc, 'HEADER' );
    }

    return $hout;
}

=item C<decl($classname, $method, $for_header)>

Returns the C code for the PMC method declaration. C<$for_header>
indicates whether the code is for a header or implementation file.

=cut

sub decl {
    my ( $self, $pmc, $for_header ) = @_;

    my $pmcname = $pmc->name;
    my $ret     = $self->return_type;
    my $meth    = $self->name;
    my $args    = $self->parameters;
    my $ro      = $pmc->flag('is_ro') ? '' : '';
    $args = ", $args" if $args =~ /\S/;
    my ( $export, $extern, $newl, $semi, $interp, $pmcvar );
    if ($for_header eq 'HEADER') {
        $export = $pmc->is_dynamic ? 'PARROT_DYNEXT_EXPORT ' : 'PARROT_API ';
        $extern = "extern ";
        $newl   = " ";
        $semi   = ";";
        $interp = $pmcvar = "";
    }
    else {
        $export = "";
        $extern = "";
        $newl   = "\n";
        $semi   = "";
        $interp = 'interp';
        $pmcvar    = ' pmc';
    }
    return <<"EOC";
$export$extern$ret${newl}Parrot_${pmcname}${ro}_$meth(Interp *$interp, PMC*$pmcvar$args)$semi
EOC
}

=item C<full_arguments($args)>

Prepends C<INTERP, SELF> to C<$args>.

=cut

sub full_arguments {
    my $args = shift;
    my $obj  = shift || 'SELF';

    return "INTERP, $obj, $args" if ( $args =~ m/\S/ );
    return "INTERP, $obj";
}

=item C<proto($type,$parameters)>

Determines the prototype (argument signature) for a method body
(see F<src/call_list>).

=cut

my %calltype = (
    "char"     => "c",
    "short"    => "s",
    "char"     => "c",
    "short"    => "s",
    "int"      => "i",
    "INTVAL"   => "I",
    "float"    => "f",
    "FLOATVAL" => "N",
    "double"   => "d",
    "STRING*"  => "S",
    "char*"    => "t",
    "PMC*"     => "P",
    "short*"   => "2",
    "int*"     => "3",
    "long*"    => "4",
    "void"     => "v",
    "void*"    => "b",
    "void**"   => "B",

    #"BIGNUM*" => "???" # XXX
);

sub proto {
    my ( $type, $parameters ) = @_;

    # reduce to a comma separated set of types
    $parameters =~ s/\w+(,|$)/,/g;
    $parameters =~ s/ //g;

    # type method(interp, self, parameters...)
    my $ret = $calltype{ $type or "void" };
    $ret .= "JO" . join( '', map { $calltype{$_} or "?" } split( /,/, $parameters ) );

    # TODO
    # scan src/call_list.txt if the generated signature is available
    # TODO report errors for "?"
    # --leo

    return $ret;
}

=item C<rewrite_nci_method($self, $pmc )>

Rewrites the method body performing the various macro substitutions for
nci method bodies (see F<tools/build/pmc2c.pl>).

=cut

sub rewrite_nci_method {
    my ( $self, $pmc ) = @_;
    my $pmcname = $pmc->name;

    local $_ = $self->body;

    # Rewrite DYNSELF.other_method(args...)
    s/\bDYNSELF\b       # Macro: DYNSELF
      \.(\w+)           # other_method
      \(\s*(.*?)\)      # capture argument list
     /"pmc->vtable->$1(" . full_arguments($2) . ')'/xeg;

    # Rewrite SELF.other_method(args...)
    s/\bSELF\b          # Macro SELF
      \.(\w+)           # other_method
      \(\s*(.*?)\)      # capture argument list
     /"Parrot_${pmcname}" .  ($pmc->is_vtable_method($1) ? "" : "_nci") .
      "_$1(" . full_arguments($2) . ")"/xeg;

    # Rewrite SELF -> pmc, INTERP -> interp
    s/\bSELF\b/pmc/g;
    s/\bINTERP\b/interp/g;

    return $_;
}

=item C<rewrite_vtable_method($self, $pmc, $super, $super_table)>

Rewrites the method body performing the various macro substitutions for
vtable method bodies (see F<tools/build/pmc2c.pl>).

=cut

sub rewrite_vtable_method {
    my ( $self, $pmc, $super, $super_table ) = @_;
    my $name = $self->name;
    my $pmcname = $pmc->name;
    
    local $_ = $self->body;

    # Rewrite method body
    # Some MMD variants don't have a super mapping.
    if ($super)
    {
        my $supertype = "enum_class_$super";
        die "$pmcname defines unknown vtable method '$name'\n" unless defined $super_table->{$name};
        my $supermethod = "Parrot_" . $super_table->{$name} . "_$name";

        # Rewrite DYNSUPER(args)
        s/\bDYNSUPER\b      # Macro: DYNSUPER
        \(\s*(.*?)\)      # capture argument list
        /"interp->vtables[$supertype].$name(" . full_arguments($1) . ')'/xeg;

        # Rewrite OtherClass.SUPER(args...)
        s/(\w+)             # capture OtherClass
        \.SUPER\b         # Macro: SUPER
        \(\s*(.*?)\)      # capture argument list
        /"Parrot_${1}_$name(" . full_arguments($2) . ')'/xeg;

        # Rewrite SUPER(args...)
        s/\bSUPER\b         # Macro: SUPER
        \(\s*(.*?)\)      # capture argument list
        /"$supermethod(" . full_arguments($1) . ')'/xeg;
    }

    # Rewrite DYNSELF.other_method(args...)
    s/\bDYNSELF\b       # Macro: DYNSELF
      \.(\w+)           # other_method
      \(\s*(.*?)\)      # capture argument list
     /"pmc->vtable->$1(" . full_arguments($2) . ')'/xeg;

    # Rewrite DYNSELF(args...). See comments above.
    s/\bDYNSELF\b       # Macro: DYNSELF
      \(\s*(.*?)\)      # capture argument list
     /"pmc->vtable->$name(" . full_arguments($1) . ')'/xeg;

    # Rewrite OtherClass.SELF.other_method(args...)
    s/(\w+)             # OtherClass
      \.\bSELF\b        # Macro SELF
      \.(\w+)           # other_method
      \(\s*(.*?)\)      # capture argument list
     /"Parrot_${1}" .  ($pmc->is_vtable_method($2) ? "" : "_nci") . "_$2(" .
        full_arguments($3) . ')'/xeg;

    # Rewrite OtherClass.object.other_method(args...)
    s/(\w+)             # OtherClass
      \.\b(\w+)\b       # any object
      \.(\w+)           # other_method
      \(\s*(.*?)\)      # capture argument list
     /"Parrot_${1}" .  ($pmc->is_vtable_method($3) ? "" : "_nci") . "_$3(" 
        . full_arguments($4, $2) . ')'/xeg;

    # Rewrite SELF.other_method(args...)
    s/\bSELF\b          # Macro SELF
      \.(\w+)           # other_method
      \(\s*(.*?)\)      # capture argument list
     /"Parrot_${pmcname}" .
      ($pmc->is_vtable_method($1) ? "" : "_nci") .  "_$1(" . full_arguments($2) . ")"/xeg;

    # Rewrite SELF -> pmc, INTERP -> interp
    s/\bSELF\b/pmc/g;
    s/\bINTERP\b/interp/g;

    # now use macros for all rewritten stuff
    s/\b(?:\w+)->vtable->(\w+)\(/ VTABLE_$1(/g;

    return $_;
}

1;

# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4:
