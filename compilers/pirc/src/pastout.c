/*
 * $Id$
 * Copyright (C) 2007, The Perl Foundation.
 */

/*

=head1 NAME

pastout.c - routines for emitting PAST

=head1 STATUS

Initial.

=cut

*/

#include "pastout.h"
#include "pirvtable.h"
#include "pirutil.h"
#include <stdio.h>
#include <stdlib.h>

/* number of spaces for 1 indention level */
static const int INDENT = 4;


/*

=head1 DATA STRUCTURE

The PAST back-end implements the C<emit_data> data structure.
Currently, only a single data member is used, to control the
indention.

=over 4

=cut

*/
typedef struct emit_data {
    int indent;
    int index;
    char *outputfile;
    FILE *file;

} emit_data;

/*

=item C<static int indent(emit_data *data)>

increase the indention level

=cut

*/

static int
indent(emit_data *data)
{
    data->indent += INDENT;
    return data->indent;
}

/*

=item C<static int dedent(emit_data *data)>

decrease the indention level

=cut

*/

static int
dedent(emit_data *data)
{
    data->indent -= INDENT;
    return data->indent;
}

/*

=back

=head1 PAST VTABLE ENTRIES

=over 4

=item C<static void past_init(struct emit_data *data)>

Prints initializing PAST: ["past" => PMC 'PAST::Block' {]

=cut

*/

static void
past_init(struct emit_data *data)
{

    if (data->outputfile) data->file = open_file(data->outputfile, "w");
    else data->file = stdout;

    fprintf(data->file, "\"past\" => PMC 'PAST::Block'  {\n");
    indent(data);
}

/*

=item C<static void past_block(struct emit_data *data)>

Prints PAST for a block, including <source> and <pos> attributes.

=cut

*/
static void
past_block(struct emit_data *data)
{
    fprintf(data->file, "%*sPMC 'PAST::Block'  {\n", data->indent, " ");
    indent(data);
}

/*

=item C<static void
past_source(emit_data *data, char *source)>

TODO: Not yet documented!!!

=cut

*/

static void
past_source(emit_data *data, char *source)
{
    fprintf(data->file, "%*s<source> => \"%s\"\n", data->indent, " ", source);
}

/*

=item C<static void
past_position(emit_data *data, int pos)>

TODO: Not yet documented!!!

=cut

*/

static void
past_position(emit_data *data, int pos)
{
    fprintf(data->file, "%*s<pos> => %d\n", data->indent, " ", pos);
}

/*

=item C<static void past_close(struct emit_data *data)>

Close down a PAST entity. The closing brace is printed, and the
indention level is decremented.

=cut

*/

static void
past_close(struct emit_data *data)
{
    dedent(data);
    /* check for indent == 0, if so, then print no space, this is
     * so otherwise a single space is printed.
     */
    fprintf(data->file, "%*s}\n", data->indent, (data->indent == 0) ? "" : " ");

}

/*

=item C<static void past_name(struct emit_data *data, char *name)>

Prints a PAST <name> entry.

=cut

*/

static void
past_name(struct emit_data *data, char *name)
{
    fprintf(data->file, "%*s<name> => \"%s\"\n", data->indent, " ", name);
}

/*

=item C<static void past_stmts(struct emit_data *data)>

Opens a PAST::Stmts node.

=cut

*/
static void
past_stmts(struct emit_data *data)
{
    fprintf(data->file, "%*s[%d] => PMC 'PAST::Stmts'  {\n", data->indent, " ", data->index++);
    indent(data);
}

/*

=item C<static void past_param(struct emit_data *data)>

Generates a PAST::Var node and set its scope attribute to "parameter".

=cut

*/
static void
past_param(struct emit_data *data)
{
    fprintf(data->file, "%*sFIXTHIS => PMC 'PAST::Var'  {\n", data->indent, " ");
    indent(data);
    fprintf(data->file, "%*s<scope> => \"parameter\"\n", data->indent, " ");
}

/*

=item C<static void past_type(struct emit_data *data, char *type)>

TODO: Not yet documented!!!

=cut

*/

static void
past_type(struct emit_data *data, char *type)
{
    fprintf(data->file, "%*s<type> => \"%s\"\n", data->indent, " ", type);
}

/*

=item C<static void past_subflag(struct emit_data *data, int flag)>

TODO: Not yet documented!!!

=cut

*/

static void
past_subflag(struct emit_data *data, int flag)
{
    /* fprintf(data->file, "%*s<???> => \"%s\"\n", data->indent, " ", type);
    */
}


/*

=item C<static void past_op(struct emit_data *data, char *op)>

TODO: Not yet documented!!!

=cut

*/

static void
past_op(struct emit_data *data, char *op)
{
    fprintf(data->file, "%*sFIXME => PMC 'PAST::Op'  {\n", data->indent, " ");
    indent(data);
    fprintf(data->file, "%*s<pirop> => \"%s\"\n", data->indent, " ", op);

}

/*

=item C<static void past_expr(struct emit_data *data, char *expr)>

TODO: Not yet documented!!!

=cut

*/

static void
past_expr(struct emit_data *data, char *expr)
{
    fprintf(data->file, "%*s[%d] => \"%s\"\n", data->indent, " ", data->index++, expr);
    /* fix index */
}

/*

=item C<static void past_destroy(emit_data *data)>

Destructor, close the outputfile if any, and free the emit_data structure.

=cut

*/

static void
past_destroy(emit_data *data)
{
    if (data->outputfile) fclose(data->file);
    free(data);
    data = NULL;
}

/*

=item C<pirvtable * init_past_vtable(char *outputfile)>

Creates a vtable for the PAST emitting module, and
then this vtable is set into the parser_state struct.

=cut

*/

pirvtable *
init_past_vtable(char *outputfile)
{
    pirvtable *vtable = new_pirvtable();

    /* override vtable methods */
    vtable->initialize   = past_init;
    vtable->destroy      = past_destroy;
    vtable->source       = past_source;
    vtable->position     = past_position;
    vtable->sub_start    = past_block;
    vtable->sub_end      = past_close;
    vtable->name         = past_name;
    vtable->stmts_start  = past_stmts;
    vtable->stmts_end    = past_close;
    vtable->end          = past_close;
    vtable->param_start  = past_param;
    vtable->param_end    = past_close;
    vtable->type         = past_type;
    vtable->sub_flag     = past_subflag;
    vtable->op_start     = past_op;
    vtable->expression   = past_expr;
    vtable->op_end       = past_close;

    /* allocate the emit_data structure and initialize it */
    vtable->data = (emit_data *)malloc(sizeof (emit_data));
    if (vtable->data == NULL) {
        fprintf(stderr, "Failed to allocate memory for vtable data\n");
        exit(EXIT_FAILURE);
    }
    vtable->data->indent = 0;
    vtable->data->outputfile = outputfile;
    vtable->data->index = 0;

    return vtable;
}

/*

=back

=cut

*/

/*
 * Local variables:
 *   c-file-style: "parrot"
 * End:
 * vim: expandtab shiftwidth=4:
 */
