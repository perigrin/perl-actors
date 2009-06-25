package MooseX::Actor;
use Moose;
use namespace::autoclean;

with qw(
  MooseX::Actors::Mailbox
  MooseX::Actors::Agent
);

sub handle_message { }

1;
