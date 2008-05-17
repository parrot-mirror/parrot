=head2 P6object

    P6metaobject.'register'('Integer')

    $P0 = P6metaobject.'new_class'('MyHash', 'parent'=>'Hash')
    P6metaobject.map('Hash', $P0)

=over 4

=item onload()

P6metaclass initialization.

=cut

.namespace ['P6object']

.sub 'main' :main
.end

.sub 'onload' :anon :init :load
    ##  create the %!metaclass hash for parrotclass => metaclass mapping
    $P0 = new 'Hash'
    set_hll_global ['P6metaclass'], '%!metaclass', $P0

    $P0 = newclass 'P6protoobject'

    $P0 = newclass 'P6object'

    $P1 = subclass $P0, 'P6metaclass'
    addattribute $P1, 'parrotclass'
    addattribute $P1, 'protoobject'
    addattribute $P1, 'longname'
    addattribute $P1, 'shortname'

    $P2 = new 'P6metaclass'
    $P2.'register'($P0)
    $P3 = $P2.'register'($P1)
    setattribute $P3, 'protoobject', $P3
.end


=item HOW()

Return the metaclass for the invocant.

=cut

.sub 'HOW' :method
    .local pmc parrotclass, mhash, how
    mhash = get_hll_global ['P6metaclass'], '%!metaclass'
    parrotclass = typeof self
    $I0 = get_addr parrotclass
    how = mhash[$I0]
    unless null how goto end
    $S0 = parrotclass
    how = mhash[$S0]
  end:
    .return (how)
.end


=item WHAT()

Return the protoobject for the invocant.

=cut

.sub 'WHAT' :method
    .local pmc how, what
    how = self.'HOW'()
    .return how.'WHAT'()
.end


=back

=head2 P6metaclass

=over

=item WHAT()

Return the protoobject for this metaclass.

=cut

.namespace ['P6metaclass']

.sub 'WHAT' :method
    $P0 = getattribute self, 'protoobject'
    .return ($P0)
.end

=item isa(x)

Return a true value if the invocant 'isa' C<x>.

=cut

.sub 'isa' :method
    .param pmc x

    .local pmc parrotclass
    parrotclass = self.'get_parrotclass'(x)
    $P0 = self.'WHAT'()
    $I0 = isa $P0, parrotclass
    .return ($I0)
.end

=item register(parrotclass [, 'name'=>name] [, 'protoobject'=>proto])

Sets objects of type C<parrotclass> to use C<protoobject>,
and verifies that parrotclass has P6object methods defined.

=cut

.sub 'register' :method
    .param pmc parrotclass
    .param pmc options         :slurpy :named

    ##  get the true parrotclass
    $I0 = isa parrotclass, 'Class'
    if $I0 goto have_parrotclass
    parrotclass = self.'get_parrotclass'(parrotclass)
  have_parrotclass:

    ##  get the mapping hash
    .local pmc mhash
    mhash = get_hll_global ['P6metaclass'], '%!metaclass'

    ##  make sure parrotclass isa P6object or has P6object methods
    $I0 = isa parrotclass, 'P6object'
    if $I0 goto p6object_done
    $S0 = typeof parrotclass
    if $S0 == 'PMCProxy' goto p6object_proxy
    $P0 = get_class 'P6object'
    parrotclass.'add_parent'($P0)
    goto p6object_done
  p6object_proxy:
    ##  iterate over P6object's methods, adding them to parrotclass' namespace
    .local pmc methods, iter, parrotclassns
    $P0 = get_class 'P6object'
    methods = $P0.'methods'()
    iter = new 'Iterator', methods
    parrotclassns = parrotclass.'get_namespace'()
  iter_loop:
    unless iter goto iter_end
    $S0 = shift iter
    $P0 = parrotclassns.'find_sub'($S0)
    unless null $P0 goto iter_loop
    $P0 = methods[$S0]
    parrotclassns.'add_sub'($S0, $P0)
    goto iter_loop
  iter_end:
  p6object_done:

    ##  determine parrotclass' canonical p6-name
    .local pmc ns
    $S0 = parrotclass
    ##  Parrot joins namespaces with ';'
    ns = split ';', $S0
    $I0 = elements ns
    if $I0 > 1 goto have_ns
    ##  but perhaps it's a (legacy) ::-delimited name instead
    ns = split '::', $S0
  have_ns:

    ##  get the metaclass (how) from :protoobject, or create one
    .local pmc how
    $P0 = options['protoobject']
    if null $P0 goto make_how
    how = $P0.'HOW'()
    goto have_how
  make_how:
    ##  create a metaclass for parrotclass
    how = new 'P6metaclass'
    setattribute how, 'parrotclass', parrotclass

    ##  create an anonymous class for the protoobject
    .local pmc protoclass, protoobject
    protoclass = new 'Class'
    $P0 = get_class 'P6protoobject'
    ##  P6protoobject methods override parrotclass methods...
    protoclass.'add_parent'($P0)
    protoclass.'add_parent'(parrotclass)
    ##  ...except for 'new'
    $P0 = parrotclass.'methods'()
    $P1 = $P0['new']
    if null $P1 goto have_protoclass
    protoclass.'add_method'('new', $P1)
  have_protoclass:
    ##  register the protoclass in %!metaobject
    $I0 = get_addr protoclass
    mhash[$I0] = how
    ##  create the protoobject for parrotclass
    protoobject = new protoclass
    setattribute how, 'protoobject', protoobject

    ##  store the long and short names in the protoobject
    .local pmc longname, shortname
    $S0 = join '::', ns
    longname = new 'String'
    longname = $S0
    shortname = ns[-1]
    setattribute how, 'longname', longname
    setattribute how, 'shortname', shortname

  have_how:

    ##  store the protoobject in appropriate namespace
    protoobject = how.'WHAT'()
    $S0 = pop ns
    set_hll_global ns, $S0, protoobject

    ##  map parrotclass to the metaobject
    $I0 = get_addr parrotclass
    mhash[$I0] = how
    $S0 = parrotclass
    mhash[$S0] = how

    ##  return the protoobject
    .return (protoobject)
.end


=item new_class(name [, 'parent'=>parentclass])

=cut
.sub 'new_class' :method
    .param string name
    .param pmc options         :slurpy :named

    .local pmc parentclass
    parentclass = options['parent']
    if null parentclass goto parent_p6object
    parentclass = self.'get_parrotclass'(parentclass)
    goto have_parentclass
  parent_p6object:
    parentclass = get_class 'P6object'
  have_parentclass:

    .local pmc parrotclass
    parrotclass = subclass parentclass, name
    .return self.'register'(parrotclass)
.end


=item get_parrotclass(x)

Multimethod helper to return the parrotclass for C<x>.

=cut

.sub 'get_parrotclass' :method :multi(_,Class)
    .param pmc x
    .return (x)
.end

.sub 'get_parrotclass' :method :multi(_,PMCProxy)
    .param pmc x
    .return (x)
.end

.sub 'get_parrotclass' :method :multi(_,P6metaclass)
    .param pmc x
    $P0 = getattribute x, 'parrotclass'
    .return ($P0)
.end

.sub 'get_parrotclass' :method :multi(_,String)
    .param pmc x
    $P0 = get_class x
    .return ($P0)
.end

.sub 'get_parrotclass' :method :multi(_,_)
    .param pmc x
    $P0 = typeof x
    .return ($P0)
.end


=back

=head2 P6protoobject

=cut

.namespace ['P6protoobject']

.sub 'get_string' :vtable :method
    $P0 = self.'HOW'()
    $P1 = getattribute $P0, 'shortname'
    .return ($P1)
.end

.sub 'defined' :vtable :method
    .return (0)
.end

.sub 'new' :method
    .local pmc parrotclass
    $P0 = self.'HOW'()
    ##  for speed we access the 'parrotclass' attribute directly here
    parrotclass = getattribute $P0, 'parrotclass'
    $P1 = new parrotclass
    .return ($P1)
.end
