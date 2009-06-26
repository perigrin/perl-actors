use 5.10.0;
use lib qw(lib);
use MooseX::Declare;

actor Ping {
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

    sub BUILD { $_[0]->send( $_[0]->pong => 'Ping' ) }

    recieve {
         (Str $msg where { $_ =~ /^Pong/ }) {
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
};

actor Pong  {

    has pongCount => (
        isa     => 'Str',
        is      => 'rw',
        default => 0,
    );

    recieve {
        when (Str $msg where { $_ =~ /^Ping/ }) {
            say "Pong:ping ${\$self->pongCount}"
              unless ( $self->pongCount % 1000 );
            $self->send( $sender => 'Pong' );
            $self->pongCount( $self->pongCount + 1 );
        }

        when (Str $msg where { $_ =~ /^Quit/ }) {
            say "Pong: stop";
            $self->quit;
        }
    }

};

class Main {
    use Actors;

    my $pong = Pong->new();
    my $ping = Ping->new( pingsLeft => 10000, pong => $pong );
   
   subtype Quit as Str where { $_ =~ /^Quit/ };
    
    recieve {
        (Quit $msg) {
            
        }                    
        (Num $msg where ($_ > 10)) { }
    }
}
