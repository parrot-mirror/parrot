# Copyright: 2001-2003 The Perl Foundation.  All Rights Reserved.
# $Id$

=head1 NAME

Parrot::Docs::Item - Docmentation item

=head1 SYNOPSIS

	use Parrot::Docs::Item;
	
	my $item = Parrot::Docs::Item->new('Usual suspects', 'foo', 'bar');

=head1 DESCRIPTION

An item is one or more related paths with some optional descriptive text.

Directory paths will be expanded to all the file paths within the
directory and any subdirectories recursively (see the C<files()> method
in C<Parrot::IO::Directory>).

=head2 Methods

=over

=cut

package Parrot::Docs::Item;

use strict;
use Parrot::Docs::Directory;

=item C<new($text, @paths)>

Returns a new item. If there is no descriptive text then C<$text> should
be an empty string.

The paths will be interpreted as being relative to the C<$target>
argument in C<write_html()>. There should be at least one path otherwise
an exception is raised.

=cut

sub new
{
	my $self = ref $_[0] ? ref shift : shift;
	my $text = shift;
	my @content = @_;
	
	die "No content.\n" unless @content;
	
	$self = bless {
		TEXT => $text,
		CONTENTS => \@content,
	}, $self;

	return $self;
}

=item C<write_html($source, $target, $silent)>

Any POD-formatted text in the item's files is converted to HTML and
written to a file in C<$target> and an HTML link is created to it.

Alternatively, if a file responds true to C<is_docs_link()> then an HTML
link is created to the file itself.

Some HTML-formatted text describing the files linked to is returned.

=cut

sub write_html
{
	my $self = shift;
	my $source = shift;
	my $target = shift;
	my $silent = shift;
	my $index_html = '';
		
	foreach my $rel_path (@{$self->{CONTENTS}})
	{
		my @rel_paths = $self->relative_file_paths_for_relative_path(
			$source, $rel_path);
		
		foreach my $rel_path (@rel_paths)
		{
			my $file = $source->file_with_relative_path($rel_path);
			
			if ( $file->contains_pod )
			{	
				print "\n", $rel_path unless $silent;
			
				$rel_path .= '.html';
				
				my $docs_file = $target->file_with_relative_path($rel_path);
				
				$index_html .= sprintf("<a href= \"%s\">%s</a><br>\n",
					$rel_path, $source->relative_path($file->path));
		
				my $file_html = $file->pod_as_html;

				# TODO This is messy. 
				# There may be a bug in relative_path().
				
				my $name = $target->name;
				$rel_path = $file->relative_path($target->path);
				$rel_path =~ s|/([^/]+$)||;

				$file_html =~ s|href="">Contents|href="../$rel_path/$name/index.html">Contents|s;
				$file_html =~ s|http://dev.perl.org|../$rel_path/resources|s;
				$file_html =~ s|http://www.parrotcode.org/images|../$rel_path/resources|s;

				$docs_file->write($file_html);				
			}
			elsif ( $file->is_docs_link )
			{
				print "\n", $rel_path unless $silent;
			
				$index_html .= sprintf("<a href= \"%s\">%s</a><br>\n",
					$target->relative_path($file->path), 
					$source->relative_path($file->path));
			}
		}
	}
	
	if ( $index_html and $self->{TEXT} )
	{
		$index_html .= "$self->{TEXT}<br>\n";
		$index_html = '<p>' . $index_html . "</p>\n";
	}
	
	return $index_html;
}

=item C<relative_file_paths_for_relative_path($dir, $path)>

If C<$path> is an immediate subdirectory of C<$dir>, then this method
returns all the file paths within the directory and any subdirectories
recursively, relative to C<$dir>.

If C<$path> is a file in C<$dir> then C<$path> is returned.

If C<$path> cannot be found then an exception is raised.

=cut

sub relative_file_paths_for_relative_path
{
	my $self = shift;
	my $source = shift;
	my $rel_path = shift;
	my @rel_paths = ();
	
	if ( $source->relative_path_is_directory($rel_path) )
	{
		my $dir = $source->directory_with_relative_path($rel_path);
		
		foreach my $file ($dir->files(1))
		{
			push @rel_paths, $source->relative_path($file->path);
		}
	}
	elsif ( $source->relative_path_is_file($rel_path) )
	{
		push @rel_paths, $rel_path;
	}
	else
	{
		die "Failed to process $rel_path.\n";
	}

	return @rel_paths;
}

=back

=head1 SEE ALSO

C<Parrot::Docs::Section>, C<Parrot::Docs::Group>.

=cut

1;