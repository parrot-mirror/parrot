
.HLL 'Forth', ''
.namespace ['TokenStream']

.sub init :anon :load
    .local pmc class
    class = newclass 'TokenStream'

    addattribute class, '$code'
    addattribute class, '$pos'
.end


.sub '__new_from_string'
    .param pmc class
    .param pmc str
    .param int flags

    .local pmc self
    $I0  = typeof class
    self = new $I0

    .local pmc pos
    pos = new .Integer
    pos = 0

    setattribute self, '$code', str
    setattribute self, '$pos',  pos

    .return(self)
.end


.sub '__get_bool' :method
    .local string code
    .local pmc pos
    pos  = getattribute self, '$pos'
    $P0  = getattribute self, '$code'
    code = $P0

    .local int len
    len = length code

    .include 'cclass.pasm'
    $I0 = pos
    $I0 = find_not_cclass .CCLASS_WHITESPACE, code, $I0, len
    if $I0 == len goto false

    pos = $I0
    .return(1)

false:
    .return(0)
.end

.sub '__shift_pmc' :method
    .local pmc token, pos
    .local string code, str
    null token
    pos  = getattribute self, '$pos'
    $P0  = getattribute self, '$code'
    code = $P0

    .local int len
    len = length code

    .include 'cclass.pasm'
    $I0 = pos
    $I0 = find_not_cclass .CCLASS_WHITESPACE, code, $I0, len
    $I1 = find_cclass     .CCLASS_WHITESPACE, code, $I0, len
    if $I0 == len goto return

    $I2 = $I1 - $I0
    str = substr code, $I0, $I2
    pos = $I1

    $I0 = length str
    $I1 = find_not_cclass .CCLASS_NUMERIC, str, 0, $I0
    if $I1 == $I0 goto numeric

    token = new .String
    token = str
    goto return

numeric:
    $I0 = str
    token = new .Integer
    token = $I0
    
return:
    .return(token)
.end


.sub remove_upto :method
    .param string str

    .local pmc code, pos
    code = getattribute self, '$code'
    pos  = getattribute self, '$pos'

    $S0 = code
    $I0 = pos
    inc $I0 # skip a space
    $I1 = index $S0, str, $I0

    $I2 = $I1 - $I0
    $S1 = substr $S0, $I0, $I2

    inc $I1
    pos = $I1

    .return($S1)
.end
