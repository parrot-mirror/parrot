package Make::Dependency;

use vars qw(@ISA @EXPORT_OK);
@ISA = qw(Exporter);
@EXPORT_OK = qw(Object Executable);

sub DEBUG () { 1 }

sub Object {
  my %args = @_;
  unless(exists $args{input}) {
    my $target = "*** make.pl: Object() called from line ".(caller(0))[2];
    unless(exists $args{input}) {
      print STDERR "$target had no input specified.\n";
    }
  }
  $args{input} .= $^O =~ /Win/ ? '.obj' : '.o';
  $args{input};
}

sub Executable {
  my %args = @_;
  unless(exists $args{input}) {
    my $target = "*** make.pl: Executable() called from line ".(caller(0))[2];
    unless(exists $args{input}) {
      print STDERR "$target had no input specified.\n";
    }
  }
  $args{input} .= $^O =~ /Win/ ? '.exe' : '';
  $args{input};
}

sub satisfied {
  my $self = shift;
  my $actions = shift;
  my $satisfied = 1;

  for(@{$self->{dependsOn}}) {
    if(ref($_) =~ /_Obj/) {
      $satisfied = undef unless $_->satisfied($actions);
      if(-e $self->{output} and -e $_->{output}) {
        print "Testing $self->{output} vs $_->{output}\n" if DEBUG;
        $satisfied = undef unless -C $self->{output} <= -C $_->{output};
      }
    }
    else {
      print -e $_ ? "$_ exists\n" :
                    "$_ doesn't exist\n" if DEBUG;
      print -e $self->{output} ? "$self->{output} exists\n" :
                                 "$self->{output} doesn't exist\n" if DEBUG;
      if(-e $self->{output}) {
        print -C $self->{output} < -C $_ ? "After\n" : "Before\n" if DEBUG;
      }
      $satisfied = undef
        unless -e $_ and
               -e $self->{output} and
               (-C $self->{output} < -C $_);
    }
  }
  unless($satisfied) {
    my $action = $self->build();
    push @$actions,$action if defined $action;
  }
  return $satisfied;
}

1;
