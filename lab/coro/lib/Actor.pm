use 5.10.0;
use MooseX::Declare;
use Coro;
use Coro::EV;

class Actor {
    use MooseX::AttributeHelpers;
    has mailbox => (
        metaclass => 'Collection::Array',
        isa       => 'ArrayRef',
        is        => 'ro',
        default   => sub { [] },
        provides  => {
            count => 'msg_count',
            push  => 'post',
            shift => 'get_message',
        }
    );

    has stopped => (
        metaclass => 'Bool',
        isa       => 'Bool',
        is        => 'rw',
        default   => 0,
        provides  => {
            set => 'quit',
            not => 'running'
        }
    );

    sub start {
        my ($self) = @_;
        Coro::async {
            while ( $self->running ) {
                my $m = $self->get_message;
                next unless $m;
                $self->receive($m);
                Coro::cede;
            }
        }
    }

    sub send {
        my ( $self, $to, $text ) = @_;
        $to->post( { sender => $self, text => $text } );
    }
};
