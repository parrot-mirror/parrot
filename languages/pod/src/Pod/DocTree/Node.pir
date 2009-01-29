=head1 NAME

Pod;DocTree - Pod Document Tree

=head1 DESCRIPTION

This file implements the various node types for Pod;DocTree, a tree
representation of a Pod document.

=cut

.namespace [ 'Pod';'DocTree';'Node' ]

.sub 'onload' :anon :load :init
    ##   create the Pod;DocTree;Node base class
    load_bytecode 'P6object.pbc'
    .local pmc p6meta, parent, base
    p6meta = new 'P6metaclass'
    parent = get_class ['PCT';'Node']
    base = p6meta.'new_class'('Pod;DocTree;Node', 'parent'=>parent)

    p6meta.'new_class'('Pod;DocTree;File',        'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Heading',     'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Block',       'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;List',        'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Item',        'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Text',        'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Format',      'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Paragraph',   'parent'=>base)
    p6meta.'new_class'('Pod;DocTree;Literal',     'parent'=>base)

    .return ()
.end

=head1 Pod;DocTree Node Types

=head2 Pod;DocTree;Node

C<Pod;DocTree;Node> is the base class for all PAST nodes, and is
derived from C<PCT::Node>. A node has an array component to
hold its children, and a hash component for its attributes.
However, we tend to use accessor methods for accessing the node's
attributes instead of accessing the hash directly.

Every Pod;DocTree node inherits C<name>, C<source>, and C<pos> attributes
from C<PCT::Node>.  The C<name> attribute is the node's name, if
any, while C<source> and C<pos> are used to identify the location
in the original source code for the node.  The C<source> and C<pos>
values are generally set by the C<node> method inherited from
C<PCT::Node>.

Other node attributes are generally defined by subclasses of C<Pod;DocTree;Node>.

=head2 Pod;DocTree;File

A C<Pod;DocTree;File> node represents a file containing Pod. As such, it's
the C<root> node of the Pod parse tree. The C<name> attribute contains the
name of the file.


=head2 Pod;DocTree;Heading

C<Pod;DocTree;Heading> nodes represent heading directives in the Pod document
tree.  The C<name> attribute contains the name of the C<=headX> tag ('head1',
'head2', etc). The C<level> attribute is the numeric heading level (1, 2, etc).
The C<title> attribute is the heading title text.

=over 4

=item level([value])

Get/set the heading level for this node.

=cut

.namespace [ 'Pod';'DocTree';'Heading' ]

.sub 'level' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .tailcall self.'attr'('level', value, has_value)
.end

=item title([value])

Get/set the heading title for this node.

=cut

.sub 'title' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .tailcall self.'attr'('title', value, has_value)
.end

=back

=head2 Pod;DocTree;Block

C<Pod;DocTree;Block> nodes represent block sections in the Pod document tree,
either C<=begin>/C<=end> pairs, or a C<=for>. The C<name> attribute contains
the name of the block (the first word after the tag). The C<title> attribute is
the block title text (any text after the name on the block directive line).

=over 4

=item title([value])

Get/set the block title for this node.

=cut

.namespace [ 'Pod';'DocTree';'Block' ]

.sub 'title' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .tailcall self.'attr'('title', value, has_value)
.end

=back

=head2 Pod;DocTree;List

C<Pod;DocTree;List> nodes represent list sections in the Pod document tree,
C<=over>/C<=back> pairs. Lists have multiple children, all C<Pod;DocTree;Item>
nodes. The C<name> attribute may indicate if the list is 'ordered', 'bullet',
or 'named'.

=head2 Pod;DocTree;Item

C<Pod;DocTree;Item> nodes represent list items in the Pod document tree,
corresponding to an C<=item> tag. The C<name> attribute contains the item name,
number, or bullet. The C<type> attribute indicates whether the list item is
'ordered', 'bullet', or 'named'. Items have multiple children which may be
paragraphs, literal paragraphs, or blocks.

=over 4

=item type([value])

Get/set the list item type for this node.

=cut

.namespace [ 'Pod';'DocTree';'Item' ]

.sub 'type' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .tailcall self.'attr'('type', value, has_value)
.end

=back

=head2 Pod;DocTree;Text

C<Pod;DocTree;Text> nodes represent a section of plain text (a string of
alphabetics, numbers, spaces, and punctuation) containing no formatting codes
in the Pod document tree. The C<name> attribute contains the text for the node.

=head2 Pod;DocTree;Format

C<Pod;DocTree;Format> nodes represent a format code in the Pod document tree.
The C<name> attribute contains one of 'bold', 'italic', 'code', 'nonbreaking',
'escape', 'index', 'filename', 'link', or 'noop'. The original single character
code is stored in the C<code> attribute. Format nodes have multiple children,
which may be text sections or format nodes.

=over 4

=item code([value])

Get/set the single character formatting code for this node.

=cut

.namespace [ 'Pod';'DocTree';'FormatCode' ]

.sub 'code' :method
    .param pmc value           :optional
    .param int has_value       :opt_flag
    .tailcall self.'attr'('code', value, has_value)
.end

=back

=head2 Pod;DocTree;Paragraph

C<Pod;DocTree;Paragraph> nodes represent paragraph sections in the Pod document
tree. Paragraphs have multiple children, which may be text sections or format nodes.

=head2 Pod;DocTree;Literal

C<Pod;DocTree;Literal> nodes represent literal paragraph sections in the Pod
document tree (those paragraphs indented by some number of spaces in the
original Pod). Literals have multiple children, which may be text sections
or format nodes.

=cut


# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
