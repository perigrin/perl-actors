use 5.10.0;
use lib qw(lib);
use MooseX::Declare;
use Games::Roshambo;

class RPS extends Actor {
    has rps => (
        is         => 'ro',
        lazy_build => 1
    );
    sub _build_rps { Games::Roshambo->new() }

    sub receive {
        my ( $self, $msg ) = @_;
        given ( $msg->{text} ) {
            when (/^throw/i) {
                my $player = ucfirst $msg->{args}->[0];
                my $throw  = $self->rps->gen_throw;
                my $action = $self->rps->getaction( $player, $throw );
                $throw = $self->rps->num_to_name($throw);
                $self->send(
                    $msg->{sender},
                    results => "$player $action $throw"
                );
            }
            when (/^quit/) {
                exit;
            }
        }
    }

};

class Player extends Actor {

    sub receive {
        my ( $self, $msg ) = @_;
        given ( $msg->{text} ) {
            when (/^quit/) {
                $self->quit;
            }            
            default {
                say $msg->{args}->[0];
            }
        }
    }
};

class Main {
    use Actor::Framework;
    my $game = RPS->new();
    $game->start;

    my @players = map { Player->new() } ( 0 .. 1 );
    $_->start for @players;

    $_->send( $game => 'throw' => 'paper' )    for @players;
    $_->send( $game => 'throw' => 'rock' )     for @players;
    $_->send( $game => 'throw' => 'scissors' ) for @players;
    $game->send($game => 'quit');
    run();
}
