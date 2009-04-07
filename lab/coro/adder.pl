use 5.10.0;
use lib qw(lib);
use MooseX::Declare;

class Server extends Actor {
    use List::Util qw(sum);

    sub receive {
        my ( $self, $message ) = @_;
        given ( $message->{text} ) {
            when (/^Add/) {
                $self->send(
                    $message->{sender},
                    sum( @{ $message->{args} } )
                );
            }
            when (/^Quit/) {
                $self->send( $message->{sender} => 'Quit' );
                $self->quit;
            }
        }
    }
};

class Client extends Actor {

    sub receive {
        my ( $self, $message ) = @_;
        given ( $message->{text} ) {
            when (/^Quit/) {
                $self->quit;
            }
            default {
                say $message->{text};
            }
        }
    }

}

class Main {
    use Actor::Framework;
    my $server = Server->new();
    my $client = Client->new();
    $server->start;
    $client->start;

    $client->send( $server => Add => 1, 1 );
    $client->send( $server => Add => 2, 2 );
    $client->send( $server => Add => (1) x 33 );
    $client->send( $server => 'Quit' );
    run();
}
