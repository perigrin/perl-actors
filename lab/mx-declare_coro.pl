#!/usr/bin/env perl
use strict;
use 5.10.0;

use MooseX::Declare;
use Coro;

# Based Upon the Ping/Pong example in Scala
# http://www.scala-lang.org/node/242

class Actor {
    use MooseX::AttributeHelpers;
    has mailbox => (
        metaclass => 'Collection::Array',
        isa       => 'ArrayRef',
        is        => 'ro',
        default   => sub { [] },
        provides  => {
            count => 'has_messages',
            push  => 'post',
            shift => 'get_message',
        }
    );

    has sender => ( isa => 'Actor', is => 'rw' );

    sub start {
        my ($self) = @_;
        Coro::async {
            while ( my $m = $self->get_message ) {
                $self->sender( $m->{sender} );
                $self->receive( @{ $m->{args} } );
                Coro::cede;
            }
        }
    }

    sub send {
        my ( $self, $to, @args ) = @_;
        $to->post( { sender => $self, args => [@args] } );
    }
};

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
        given ($message) {
            when (/^Pong/) {
                say "Ping: Pong" unless ( $self->pingsLeft % 1000 );
                unless ( $self->pingsLeft ) {
                    say 'Ping: stop';
                    $self->send( $self->pong => 'Stop' );
                    break;
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
        given ($message) {
            when (/^Ping/) {
                say "Pong:ping ${\$self->pongCount}"
                  unless ( $self->pongCount % 1000 );
                $self->send( $self->sender => 'Pong' );
                $self->pongCount( $self->pongCount + 1 );
            }

            when (/^Stop/) {
                say "Pong: stop";
                break;
            }
        }
    }
};

package main;

my $pong = Pong->new();
my $ping = Ping->new( pingsLeft => 10000, pong => $pong );

$pong->start;
$ping->start;
while ( $ping->has_messages || $pong->has_messages ) {
    Coro::cede;
}
