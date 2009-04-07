use 5.10.0;
use lib qw(lib);
use MooseX::Declare;

class Ping extends Actor {
    has pong => (
        isa     => 'Actor',
        is      => 'ro',
        reqired => 1,
    );

    has pingsLeft => (
        isa      => 'Int',
        is       => 'rw',
        required => 1,
    );

    sub BUILD {
        $_[0]->send( $_[0]->pong => 'Ping' );
    }

    sub receive {
        my ( $self, $message ) = @_;
        given ( $message->{text} ) {
            when (/^Pong/) {
                say "Ping: Pong" unless ( $self->pingsLeft % 1000 );
                unless ( $self->pingsLeft ) {
                    say 'Ping: stop';
                    $self->send( $self->pong => 'Stop' );
                    $self->quit;
                }
                $self->send( $self->pong => 'Ping' );
                $self->pingsLeft( $self->pingsLeft - 1 );
            }

        }
    }
};

class Pong extends Actor {

    has pongCount => (
        isa     => 'Str',
        is      => 'rw',
        default => 0,
    );

    sub receive {
        my ( $self, $message ) = @_;
        given ( $message->{text} ) {
            when (/^Ping/) {
                say "Pong:ping ${\$self->pongCount}"
                    unless ( $self->pongCount % 1000 );
                $self->send( $message->{sender} => 'Pong' );
                $self->pongCount( $self->pongCount + 1 );
            }

            when (/^Stop/) {
                say "Pong: stop";
                $self->quit;
            }
        }
    }
};

class Main {
    use Actor::Framework;

    my $pong = Pong->new();
    my $ping = Ping->new( pingsLeft => 10000, pong => $pong );

    $pong->start;
    $ping->start;

    run();
}
