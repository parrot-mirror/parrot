use Parrot::Vtable;
my %vtable = parse_vtable();

while (<DATA>) {
    next if /^#/ or /^$/;
    my @params = split;
    my $argc = $params[0];
    my $op = $params[1];
    my $vtable_entry = $params[2] || $op;
    die "Can't find $vtable_entry in vtable, line $.\n"
        unless exists $vtable{$vtable_entry};
    for (multimethod($vtable_entry, $argc)) {
        my $args  = $_->[0];
        my $entry = $_->[1];
        print "AUTO_OP $params[1] ($args) {\n";
        print "\t(\$2->vtable->$entry";
        print ")(interpreter, ";
        if ($params[0] == 3) {
            # Three-address function
            print '$2,$3,$1';
        } elsif ($params[0] == 2) {
            # Unary function
            print '$2,$1';
        }
        print ");\n}\n";
    }
}

sub multimethod {
    my ($name, $count) = @_; 
    my $type = $vtable{$name}{meth_type};
    die "$name not found\n" unless $vtable{$name};
    my @rv = [(join ",", ("p") x $count), $name];

    if ($type eq "int") {
        push @rv, 
            [ (join ",", ("p", ("p") x ($count-2), "i")), $name."_native"];
    }
    if ($type eq "num") {
        push @rv, 
            [ (join ",", ("p", ("p") x ($count-2), "n")), $name."_float"],
            [ (join ",", ("p", ("p") x ($count-2), "i")), $name."_int"];
    }
    if ($type eq "str") {
        push @rv, 
            [ (join ",", ("p", ("p") x ($count-2), "s")), $name."_native"];
    }
        
    return @rv;
}


__DATA__
# Three-address functions
3 add
3 sub subtract
3 mul multiply
3 div divide
3 mod modulus
3 concat concatenate
3 and logical_and
3 or logical_or
# Unary functions
2 not logical_not
