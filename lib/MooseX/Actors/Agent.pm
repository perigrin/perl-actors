package MooseX::Actors::Agent;
use MooseX::Role::Parameterized;

requires qw(clear_mailbox next_message);

parameter backend => ( isa => 'MooseX::Actors::Backend', );

role {
    my $p = shift;

    sub start { $self->clear_mailbox }

    sub check_mailbox {
        for my $message ( @{ $self->mail_box } ) {
            $self->handle_message($message);
        }
    }
}

1;
