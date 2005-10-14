=head1 NAME

PGE::Match - implementation of PGE match objects

=head1 DESCRIPTION

This file implements match objects returned by the Parrot Grammar Engine.

=cut

.namespace [ "PGE::Match" ]

.sub "__onload"
    .local pmc base
    newclass base, "PGE::Match"
    addattribute base, "$:target"                  # target
    addattribute base, "$:from"                    # start of match
    addattribute base, "$:pos"                     # current match position
    addattribute base, "&:corou"                   # match's corou
    addattribute base, "@:capt"                    # subpattern captures
    addattribute base, "%:capt"                    # subpattern captures
    .return ()
.end

=head2 Functions

=item C<newfrom(PMC mob [, int from [, string grammar]])>

Creates a new Match object, based on C<mob>.  If C<grammar> is
specified then the newly created object is an instance of that class,
otherwise if C<isa mob, "PGE::Match"> then the new object is the
same class as C<mob>, otherwise the new object is a "PGE::Match"
object.  The optional C<from> parameter says how to initialize
the C<$:from> attribute of the new object if it can't start from
the current position of C<mob>.

=cut

.sub "newfrom"
    .param pmc mob
    .param int from            :optional           # from for new object
    .param int has_from        :opt_flag
    .param string grammar      :optional           # grammar to use
    .param int has_grammar     :opt_flag
    .local pmc me

    $I0 = isa mob, "PGE::Match"
    if $I0 goto newfrom_mob
    $P1 = new String
    assign $P1, mob
    $P2 = new PerlInt
    $P2 = -1
    if has_grammar goto new_me
    grammar = "PGE::Rule"
    goto new_me
  newfrom_mob:
    if has_grammar goto newfrom_2
    grammar = classname mob
  newfrom_2:
    $P1 = getattribute mob, "PGE::Match\x0$:target"
    $P2 = getattribute mob, "PGE::Match\x0$:pos"
    $P2 = clone $P2
  new_me:
    $I0 = find_type grammar
    me = new $I0
    setattribute me, "PGE::Match\x0$:target", $P1
    setattribute me, "PGE::Match\x0$:from", $P2
    $P3 = new PerlInt
    $P3 = -1
    setattribute me, "PGE::Match\x0$:pos", $P3
    if has_from == 0 goto end
    if $P2 >= 0 goto end
    $P2 = from
  end:
    .return (me)
.end

=head2 Methods

=item C<next()>

Tell a Match object to continue the previous match from where
it left off.

=cut

.sub "next" method
    .local pmc corou

    corou = getattribute self, "PGE::Match\x0&:corou"
    if_null corou, next_1
    goto next_2
  next_1:
    $P0 = getattribute self, "PGE::Match\x0$:pos"
    $P0 = -1
    goto end
  next_2:
    corou()
  end:
    .return ()
.end

=item C<from()>

Returns the offset in the target string of the first item
this object matched.

=cut

.sub "from" method
    .local pmc from
    from = getattribute self, "PGE::Match\x0$:from"
    .return (from)
.end

=item C<to()>

Returns the offset at the end of this match.

=cut

.sub "to" method
    .local pmc to
    to = getattribute self, "PGE::Match\x0$:pos"
    .return (to)
.end

=item C<__get_bool()>

Returns 1 if this object successfully matched the target string,
0 otherwise.

=cut

.sub "__get_bool" method
    $P0 = getattribute self, "PGE::Match\x0$:pos"
    $I0 = $P0
    isge $I1, $I0, 0
    .return ($I1)
.end

=item C<__get_integer()>

Returns the integer value of this match.

=cut

.sub "__get_integer" method
    $S0 = self
    $I0 = $S0
    .return ($I0)
.end

=item C<__get_number()>

Returns the numeric value of this match.

=cut

.sub "__get_number" method
    $S0 = self
    $N0 = $S0
    .return ($N0)
.end

=item C<__get_string()>

Returns the portion of the target string matched by this object.

=cut

.sub "__get_string" method
    $P0 = getattribute self, "PGE::Match\x0$:target"
    $P1 = getattribute self, "PGE::Match\x0$:from"
    $P2 = getattribute self, "PGE::Match\x0$:pos"
    if $P2 < 0 goto false
    if $P2 <= $P1 goto false
    $I1 = $P1
    $I2 = $P2
    $I2 -= $I1
    $S1 = substr $P0, $I1, $I2
    .return ($S1)
  false:
    .return ("")
.end

=item C<__get_pmc_keyed(PMC key)>

Returns the subrule capture associated with C<key>.  This
returns either a single Match object or an array of match
objects depending on the rule.

=cut

.sub "__get_pmc_keyed" method
    .param pmc key
    $P0 = getattribute self, "PGE::Match\x0%:capt"
    if_null $P0, get_1
    $P0 = $P0[key]
  get_1:
    .return ($P0)
.end

=item C<__get_pmc_keyed_int(int key)>

Returns the subpattern capture associated with C<key>.  This
returns either a single Match object or an array of match
objects depending on the rule.

=cut

.sub "__get_pmc_keyed_int" method
    .param int key
    $P0 = getattribute self, "PGE::Match\x0@:capt"
    if_null $P0, get_1
    $P0 = $P0[key]
  get_1:
    .return ($P0)
.end

.sub "__set_pmc_keyed" method
    .param pmc key
    .param pmc val
    .local pmc capt
    capt = getattribute self, "PGE::Match\x0%:capt"
    unless_null capt, set_1
    capt = new PerlHash
    setattribute self, "PGE::Match\x0%:capt", capt
  set_1:
    capt[key] = val
.end

.sub "__set_pmc_keyed_int" method
    .param int key
    .param pmc val
    .local pmc capt
    capt = getattribute self, "PGE::Match\x0@:capt"
    unless_null capt, set_1
    capt = new PerlArray
    setattribute self, "PGE::Match\x0@:capt", capt
  set_1:
    capt[key] = val
.end

.sub "__delete_keyed" :method
    .param pmc key
    .local pmc capt
    capt = getattribute self, "PGE::Match\x0%:capt"
    delete capt[key]
.end

.sub "__delete_keyed_int" :method
    .param int key
    .local pmc capt
    capt = getattribute self, "PGE::Match\x0@:capt"
    delete capt[key]
.end

.sub "__defined_keyed" :method
    .param pmc key
    .local pmc capt
    $I0 = 0
    capt = getattribute self, "PGE::Match\x0%:capt"
    if_null capt, end
    $I0 = defined capt[key]
  end:
    .return ($I0)
.end

.sub "__defined_keyed_int" :method
    .param int key
    .local pmc capt
    $I0 = 0
    capt = getattribute self, "PGE::Match\x0@:capt"
    if_null capt, end
    $I0 = defined capt[key]
  end:
    .return ($I0)
.end


=item C<get_hash()>

Returns the hash component of the match object.

=cut

.sub "get_hash" method
    .param pmc hash
    hash = getattribute self, "PGE::Match\x0%:capt"
    .return (hash)
.end

=item C<get_array()>

Returns the array component of the match object.

=cut

.sub "get_array" method
    .param pmc array
    array = getattribute self, "PGE::Match\x0@:capt"
    .return (array)
.end

=item C<dump()>

Produces a data dump of the match object and all of its subcaptures.

=cut

.sub "dump" method
    .param string prefix       :optional           # name of match variable
    .param int has_prefix      :opt_flag
    .param string b1           :optional           # bracket open
    .param int has_b1          :opt_flag
    .param string b2           :optional           # bracket close
    .param int has_b2          :opt_flag

    .local pmc capt
    .local int spi, spc
    .local pmc iter
    .local string prefix1, prefix2

    if has_b2 goto start
    b2 = "]"
    if has_b1 goto start
    b1 = "["
  start:
    print prefix
    print ":"
    unless self goto subpats
    print " <"
    print self
    print " @ "
    $I0 = self."from"()
    print $I0
    print "> "

  subpats:
    $I0 = self
    print $I0
    print "\n"
    capt = getattribute self, "PGE::Match\x0@:capt"
    if_null capt, subrules
    spi = 0
    spc = elements capt
  subpats_1:
    unless spi < spc goto subrules
    prefix1 = concat prefix, b1
    $S0 = spi
    concat prefix1, $S0
    concat prefix1, b2
    $I0 = defined capt[spi]
    unless $I0 goto subpats_2
    $P0 = capt[spi]
    bsr dumper
  subpats_2:
    inc spi
    goto subpats_1

  subrules:
    capt = getattribute self, "PGE::Match\x0%:capt"
    if_null capt, end
    iter = new Iterator, capt
    iter = 0
  subrules_1:
    unless iter goto end
    $S0 = shift iter
    prefix1 = concat prefix, "<"
    concat prefix1, $S0
    concat prefix1, ">"
    $I0 = defined capt[$S0]
    unless $I0 goto subrules_1
    $P0 = capt[$S0]
    bsr dumper
    goto subrules_1

  dumper:
    $I0 = isa $P0, "Array"
    if $I0 goto dumper_0
    $P0."dump"(prefix1, b1, b2)
    ret
  dumper_0:
    $I0 = 0
    $I1 = elements $P0
  dumper_1:
    if $I0 >= $I1 goto dumper_2
    $P1 = $P0[$I0]
    prefix2 = concat prefix1, b1
    $S0 = $I0
    concat prefix2, $S0
    concat prefix2, b2
    $P1."dump"(prefix2, b1, b2)
    inc $I0
    goto dumper_1
  dumper_2:
    ret

  end:
    .return ()
.end

=head1 AUTHOR

Patrick Michaud (pmichaud@pobox.com) is the author and maintainer.
Patches and suggestions should be sent to the Perl 6 compiler list
(perl6-compiler@perl.org).

=cut
