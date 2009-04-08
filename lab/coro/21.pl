use 5.10.0;
use lib qw(lib);
use MooseX::Declare;
use Games::Blackjack;

class Game extends Actor {

    has dealer => (
        isa      => 'Actor',
        is       => 'ro',
        required => 1,
    );

    has players => (
        isa      => 'ArrayRef[Actor]',
        is       => 'ro',
        required => 1,
    );

    has shoe => (
        is         => 'ro',
        lazy_build => 1,
    );

    sub _build_shoe {
        my $shoe = Games::Blackjack::Shoe->new( nof_decks => 4 );
    }

    has [qw(hand stay quit)] => (
        isa        => 'HashRef',
        is         => 'ro',
        lazy_build => 1
    );

    sub _build_stay { {} }
    sub _build_quit { {} }

    sub _build_hand {
        my ($self) = @_;
        my %hand = ();
        for ( @{ $self->players }, $self->dealer ) {
            my $hand = Games::Blackjack::Hand->new( shoe => $self->shoe );
            $hand->draw() for ( 1 .. 2 );    # draw 2 cards
            $hand{$_} = $hand;               # store it for the player
        }
        return \%hand;
    }

    sub BUILD {
        my ($self) = @_;
        $self->tell_go( $self->players->[0] );
    }

    sub get_next_player {
        my ( $self, $method ) = @_;
        my @players = ( @{ $self->players }, $self->dealer );
        my ($next) = grep { !exists $self->$method->{$_} } @players;
        return $next;
    }

    sub tell_go {
        my ( $self, $next ) = @_;
        my $hand   = $self->hand->{$next};
        my $string = "${ \$hand->count_as_string}: ${\$hand->as_string}";
        $self->send( $next => 'Go' => $string );
    }

    sub tell_tally {
        my ( $self, $next ) = @_;
        my $hand   = $self->hand->{$next};
        my $string = $hand->score( $self->hand->{ $self->dealer } );
        $self->send( $next => 'Tally' => $string );
    }

    sub receive {
        my ( $self, $msg ) = @_;
        given ( $msg->{text} ) {
            when (/^Stay/) {
                $self->stay->{ $msg->{sender} }++;
                if ( my $next = $self->get_next_player('stay') ) {
                    $self->tell_go($next);
                }
                else {
                    warn 'nobody next';
                    $self->tell_tally( $self->players->[0] );
                }
            }
            when (/^Done/) {
                $self->quit->{$msg->{sender}}++;
                if ( my $next = $self->get_next_player('quit') ) { 
                    $self->tell_tally($next);
                    if ($next eq $self->dealer) {
                        $self->quit;
                    }
                }
            }
        }
    }

};

class Player extends Actor {
    has name => (
        isa      => 'Str',
        is       => 'ro',
        required => 1,
    );

    sub receive {
        my ( $self, $msg ) = @_;
        say "($msg->{text}) ${\$self->name}: $msg->{args}->[0]";
        given ( $msg->{text} ) {
            when ('Tally') {
                $self->send( $msg->{sender}, 'Done' );
                $self->quit;          
            }
            default {
                $self->send( $msg->{sender}, 'Stay' );
                Coro::cede();                
            }
        }
    }
};

class Main {
    use Actor::Framework;
    my $dealer = Player->new( name => 'Becky' );
    my $player = Player->new( name => 'Larry' );
    my $game = Game->new( dealer => $dealer, players => [$player] );
    $player->start;
    $game->start;
    $dealer->start;

    run();
};
