package Make::Link_Obj;
use Exporter;

use vars qw(@ISA @EXPORT_OK);
@ISA=qw(Make::Dependency);
@EXPORT_OK = qw(Link);

my $program = "cc";
sub program { $program = shift; }

my @flags = ();
sub flags { @flags = @_ }

my @libraries = ();
sub libraries { @libraries = @_ }

sub Link {
  my $class = 'Make::Link_Obj';
  my %args = @_;
  unless(exists $args{input} and
         exists $args{dependsOn}) {
    my $target = "*** make.pl: Link() called from line ".(caller(0))[2];
    unless(exists $args{input}) {
      print STDERR "$target had no input specified.\n";
    }
    unless(exists $args{dependsOn}) {
      print STDERR "$target had no dependsOn specified.\n";
    }
  }

  $args{dependsOn} = [$args{dependsOn}]
    unless ref($args{dependsOn}) eq 'ARRAY';
  $args{input} = [$args{input}]
    unless ref($args{input}) eq 'ARRAY';
  my $self = bless {
    local_flags => $args{flags} || undef,
    local_libraries => $args{libraries} || undef,
    local_library_paths => $args{library_paths} || undef,

    dependsOn => $args{dependsOn},
    input => $args{input},
    output => $args{output},
    type => 'Link',
  }, $class;
  $self;
}

sub build {
  my ($self) = @_;
  my $flags = $self->_flags_string();
  my $libraries = $self->_library_string();
  my $library_paths = $self->_library_path_string();

  { action =>
      "$program $flags $library_paths $libraries -o $self->{output} ".join ' ',@{$self->{input}},
  };
}

1;
