package MooseX::Actors::Agent;
use MooseX::Role;

parameter agent => (
    does       => 'MooseX::Actors::Backend',
    handles    => 'MooseX::Actors::Backend',
    lazy_build => 1,
);

sub _build_agent {
    MooseX::Actors::Backend::Simple->new();
}

1;
