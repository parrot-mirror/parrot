#!./parrot
# Copyright (C) 2001-2008, The Perl Foundation.
# $Id$

=head1 NAME

t/compilers/imcc/syn/subflags.t  - test flags on PIR subs

=head1 SYNOPSIS

    % prove t/compilers/imcc/syn/subflags.t

=head1 DESCRIPTION

=cut

.namespace ['FlagTest']

.sub 'main' :main
    load_bytecode 'library/Test/More.pbc'

    .local pmc exports, curr_namespace, test_namespace
    curr_namespace = get_namespace
    test_namespace = get_hll_namespace ['Test';'More']
    exports        = split ' ', 'plan diag ok nok is todo isa_ok'
    test_namespace.'export_to'(curr_namespace, exports)

    ##  set our plan
    plan(15)

    .local pmc pmcnull
    null pmcnull

    ## normal (unflagged) subs
    .const 'Sub' $P0 = 'normal1'
    isa_ok($P0, 'Sub', "sub found w/.const")
    $P1 = get_global 'normal1'
    is_same($P0, $P1, "namespace entry same as const")
    $S0 = $P1()
    is($S0, 'normal1', "sub executable from namespace entry")
    $S0 = 'normal1'()
    is($S0, 'normal1', "sub executable from name")

    ## :anon subs
    .const 'Sub' $P10 = 'anon1'
    isa_ok($P10, 'Sub', ":anon sub found w/.const")
    $P11 = get_global 'anon1'
    is_same($P11, pmcnull, ":anon sub not found in namespace")
    $S0 = $P10()
    is($S0, 'anon1', ':anon sub executable from .const')
    $S0 = 'anon1'()
    is($S0, 'anon1', ':anon sub executable by name')

    ## :nsentry subs
    .const 'Sub' $P20 = 'nsentry1'
    isa_ok($P20, 'Sub', ":nsentry found w/.const")
    $P21 = get_global 'nsentry1'
    isa_ok($P21, 'Sub', ":nsentry found in namespace")
    is_same($P20, $P21, ":nsentry in namespace same as const")
    $S0 = $P21()
    is($S0, 'nsentry1', "sub executable from nsentry")
    $S1 = 'nsentry1'()
    is($S1, 'nsentry1', "sub executable by name")

    ## :method subs
    .const 'Sub' $P30 = 'method1'
    isa_ok($P30, 'Sub', ":method sub found w/.const")
    $P0 = get_global 'method1'
    todo(0, ":method sub not found in namespace")
    #is_same($P0, pmcnull, ":method sub not found in namespace")
.end


.sub 'is_same'
    .param pmc x
    .param pmc y
    .param string msg
    $I0 = issame x, y
    'ok'($I0, msg)
.end

.sub 'isnt_same'
    .param pmc x
    .param pmc y
    .param string msg
    $I0 = issame x, y
    'nok'($I0, msg)
.end


.sub 'normal1'
    .return ('normal1')
.end


.sub 'anon1' :anon
    .return ('anon1')
.end


.sub 'nsentry1' :nsentry
    .return ('nsentry1')
.end


.sub 'method1' :method
    .return ('method1')
.end


