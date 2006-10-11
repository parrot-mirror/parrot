## $Id$

=head1 TITLE

parse.pir - Parsing support subroutines

=head2 DESCRIPTION

This file contains support subroutines for parsing Lua programs.

=over 4

=item C<Name>

ident but not keywords

=cut

.sub 'Name'
    .param pmc mob
    .param pmc params :slurpy

    .local pmc ident
    ident = get_hll_global ['PGE::Match'], 'ident'
    mob = ident(mob, params)

    $I0 = mob.'__get_bool'()
    unless $I0 goto L2
    .local pmc kw
    push_eh H1
    kw = get_hll_global 'keyword'
    $I0 = kw        # heisenbug ???
    clear_eh
    goto L1
H1:
    kw = _const_keyword()
    set_hll_global 'keyword', kw
L1:
    $S0 = mob.'text'()
    $I0 = exists kw[$S0]
    unless $I0 goto L2
    mob.'next'()
L2:
    .return (mob)
.end

.sub _const_keyword :anon
    .local pmc kw
    new kw, .Hash
    kw['and'] = 1
    kw['break'] = 1
    kw['do'] = 1
    kw['else'] = 1
    kw['elseif'] = 1
    kw['end'] = 1
    kw['false'] = 1
    kw['for'] = 1
    kw['function'] = 1
    kw['if'] = 1
    kw['in'] = 1
    kw['local'] = 1
    kw['nil'] = 1
    kw['not'] = 1
    kw['or'] = 1
    kw['repeat'] = 1
    kw['return'] = 1
    kw['then'] = 1
    kw['true'] = 1
    kw['until'] = 1
    kw['while'] = 1
    .return (kw)
.end

=item C<quoted_literal>

Handles parsing of quoted literals.

=cut

.sub 'quoted_literal'
    .param pmc mob
    .param string delim
    .param pmc adv :slurpy :named

    .local string target
    .local pmc mfrom, mpos
    .local int pos, lastpos
    (mob, target, mfrom, mpos) = mob.'newfrom'(mob)
    pos = mfrom
    lastpos = length target

    .local string literal
    literal = ''
LOOP:
    if pos < lastpos goto L1
    error(mob, "unfinished string")
L1:
    $S0 = substr target, pos, 1
    if $S0 != delim goto L2
    mob.'value'(literal)
    mpos = pos
    .return (mob)
L2:
    $I0 = index "\n\r", $S0
    if $I0 < 0 goto L3
    error(mob, "unfinished string")
L3:
    if $S0 != "\\" goto CONCAT
    inc pos
    if pos == lastpos goto LOOP # error
    $S0 = substr target, pos, 1
    $I0 = index 'abfnrtv', $S0
    if $I0 < 0 goto L4
    $S0 = substr "\x07\x08\f\n\r\t\x0b", $I0, 1
    goto CONCAT
L4:
    $I0 = index "\n\r", $S0
    if $I0 < 0 goto L5
    $S0 = "\n"
    goto CONCAT
L5:
    $I0 = index '0123456789', $S0
    if $I0 < 0 goto CONCAT
    inc pos
    $S0 = substr target, pos, 1
    $I1 = index '0123456789', $S0
    if $I1 < 0 goto L6
    $I0 *= 10
    $I0 += $I1
    inc pos
    $S0 = substr target, pos, 1
    $I1 = index '0123456789', $S0
    if $I1 < 0 goto L6
    $I0 *= 10
    $I0 += $I1
    goto L7
L6:
    dec pos
L7:
    if $I0 < 256 goto L8
    error(mob, "escape sequence too large")
L8:
    $S0 = chr $I0

CONCAT:
    concat literal, $S0
    inc pos
    goto LOOP
.end

=item C<long_string>

=cut

.sub 'long_string'
    .param pmc mob
    .param pmc adv :slurpy :named

    .local string target
    .local pmc mfrom, mpos
    .local int pos, lastpos
    (mob, target, mfrom, mpos) = mob.'newfrom'(mob)
    pos = mfrom
    lastpos = length target

    .local int sep
    sep = 0
    $S0 = substr target, pos, 1
    if $S0 != '[' goto END
    inc pos
    (pos, sep) = _skip_sep(target, pos, '[')
    if sep >= 0 goto L1
    if sep == -1 goto END
    error(mob, "invalid long string delimiter")
L1:
    inc pos
    $S0 = substr target, pos, 1
    $I0 = index "\n\r", $S0
    if $I0 < 0 goto L2
    inc pos
L2:

    .local string literal
    literal = ''
LOOP:
    if pos < lastpos goto L3
    error(mob, "unfinished long string")
L3:
    $S0 = substr target, pos, 1
    if $S0 != '[' goto L4
    inc pos
    $S0 = substr target, pos, 1
    if $S0 != '[' goto L5
    error(mob, "nesting of [[...]] is deprecated")
L5:
    dec pos
    goto CONCAT
L4:
    if $S0 != ']' goto L6
    inc pos
    ($I0, $I1) = _skip_sep(target, pos, ']')
    if $I1 != sep goto L7
    pos = $I0 + 1
    mob.'value'(literal)
    mpos = pos
    goto END
L7:
    dec pos
    goto CONCAT
L6:
    $I0 = index "\n\r", $S0
    if $I0 < 0 goto L8
    $S0 = "\n"
    goto CONCAT
L8:

CONCAT:
    concat literal, $S0
    inc pos
    goto LOOP

END:
    .return (mob)
.end

=item C<long_comment>

=cut

.sub 'long_comment'
    .param pmc mob
    .param pmc adv :slurpy :named

    .local string target
    .local pmc mfrom, mpos
    .local int pos, lastpos
    (mob, target, mfrom, mpos) = mob.'newfrom'(mob)
    pos = mfrom
    lastpos = length target

    .local int sep
    sep = 0
    $S0 = substr target, pos, 1
    if $S0 != '[' goto END
    inc pos
    (pos, sep) = _skip_sep(target, pos, '[')
    if sep < 0 goto END
    inc pos
#    $S0 = substr target, pos, 1
#    $I0 = index "\n\r", $S0
#    if $I0 < 0 goto L2
#    inc pos
#L2:

#    .local string literal
#    literal = ''
LOOP:
    if pos < lastpos goto L3
    error(mob, "unfinished long comment")
L3:
    $S0 = substr target, pos, 1
    if $S0 != '[' goto L4
    inc pos
    $S0 = substr target, pos, 1
    if $S0 != '[' goto L5
    error(mob, "nesting of [[...]] is deprecated")
L5:
    dec pos
    goto CONCAT
L4:
    if $S0 != ']' goto L6
    inc pos
    ($I0, $I1) = _skip_sep(target, pos, ']')
    if $I1 != sep goto L7
    pos = $I0 + 1
#    mob.'value'(literal)
    mpos = pos
    goto END
L7:
    dec pos
    goto CONCAT
L6:
    $I0 = index "\n\r", $S0
    if $I0 < 0 goto L8
#    $S0 = "\n"
    goto CONCAT
L8:

CONCAT:
#    concat literal, $S0
    inc pos
    goto LOOP

END:
    .return (mob)
.end

.sub _skip_sep
    .param string target
    .param int pos
    .param string delim
    .local int count
    count = 0
L1:
    $S0 = substr target, pos, 1
    if $S0 != '=' goto L2
    inc count
    inc pos
    goto L1
L2:
    if $S0 == delim goto L3
    neg count
    dec count
L3:
    .return (pos, count)
.end

=item C<error(PMC match, [, message [, ...]] )>

Throws an exception at the current point in the match. If message
doesn't end with a newline, also produces the line number and offset
of the match.

=cut

.sub 'error'
    .param pmc mob
    .param pmc params :slurpy

    $P0 = get_hll_global ['PGE::Util'], 'die'
    $P0(mob, params :flat)
.end

=back

=cut

