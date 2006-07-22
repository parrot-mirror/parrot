# $Id$

=head1 NAME

src/grammar/expr/functions - [expr] function definitions

=head2 Nullary Functions

Functions are very similar to ops, so handle them similarly here.

=cut

.namespace

.sub 'function:rand'
.end

=head2 Unary Functions

=cut

.sub 'function:abs' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:abs' :multi (pmc)
    .param pmc a
    .local pmc b
    b = clone a
    b = neg b
    .return (b)
.end

.sub 'function:acos' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:acos' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = acos a
    ret = $N0
    .return (ret)
.end

.sub 'function:asin' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:asin' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = asin a
    ret = $N0
    .return (ret)
.end

.sub 'function:atan' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:atan' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = atan a
    ret = $N0
    .return (ret)
.end

.sub 'function:ceil' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:ceil' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = ceil a
    ret = $N0
    .return (ret)
.end

.sub 'function:cos' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:cos' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = cos a
    ret = $N0
    .return (ret)
.end

.sub 'function:cosh' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:cosh' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = cosh a
    ret = $N0
    .return (ret)
.end

.sub 'function:double' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:double' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    ret = a
    .return (ret)
.end

.sub 'function:exp' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:exp' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = exp a
    ret = $N0
    .return (ret)
.end

.sub 'function:floor' 
.end

.sub 'function:int' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:int' :multi (pmc)
    .param int a
    .return (a)
.end

.sub 'function:log' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:log' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = ln a
    ret = $N0
    .return (ret)
.end

.sub 'function:log10' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:log10' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = log10 a
    ret = $N0
    .return (ret)
.end

.sub 'function:round' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:round' :multi (pmc)
    .param float a
    if a < 0 goto neg

    $N0 = a + 0.5
    $I0 = $N0
    .return ($I0)
neg: 
    $N0 = a - 0.5
    $I0 = $N0
    .return ($I0)
.end

.sub 'function:sin' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:sin' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = sin a
    ret = $N0
    .return (ret)
.end

.sub 'function:sinh' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:sinh' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = sinh a
    ret = $N0
    .return (ret)
.end

.sub 'function:sqrt' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:sqrt' :multi (pmc)
    .param float a
    .local pmc ret
    if a < 0 goto domain_error
    ret = new "TclFloat"
    $N0 = sqrt a
    ret = $N0
    .return (ret)

domain_error:
    .throw('domain error: argument not in valid range')
.end

.sub 'function:srand'
.end

.sub 'function:tan' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:tan' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = tan a
    ret = $N0
    .return (ret)
.end

.sub 'function:tanh' :multi (String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:tanh' :multi (pmc)
    .param float a
    .local pmc ret
    ret = new "TclFloat"
    $N0 = tanh a
    ret = $N0
    .return (ret)
.end

.sub 'function:wide'
.end

=head2 Binary Functions

=cut

.sub 'function:fmod' :multi (String, pmc)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:fmod' :multi (pmc, String)
    .throw("argument to math function didn't have numeric value")
.end

.sub 'function:fmod' :multi (pmc, pmc)
    .param float a
    .param float b
    if b == 0 goto domain_error
    $N0 = a / b
    $I0 = $N0
    $N0 -= $I0 
    .local pmc ret
    ret = new "TclFloat"
    ret = $N0
    .return (ret)

 domain_error:
    .throw('domain error: argument not in valid range')
.end
