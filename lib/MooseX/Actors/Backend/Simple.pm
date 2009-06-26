package MooseX::Actors::Backend::Simple;
use Moose;

with qw(
  MooseX::Actors::Backend
);

has method_table => (
    isa     => 'MooseX::Actors::Backend::MethodTable',
    is      => 'ro',
    default => sub { MooseX::Actors::Backend::MethodTable },
);

sub start {
    my ($self) = shift;
}

1;
