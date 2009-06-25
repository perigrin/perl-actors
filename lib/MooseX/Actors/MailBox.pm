package MooseX::Actors::MailBox;
use Moose::Role;
use MooseX::AttributeHelpers;
use namespace::autoclean;

has mailbox => (
    traits     => ['Collection::Array'],
    isa        => 'ArrayRef',
    is         => 'ro',
    lazy_build => 1,
    provides   => {
        push  => 'post',
        empty => 'has_messages',
        count => '_message_count',
        shift => '_get_message',
    }
);

sub _build_mailbox { [] }

1;

__END__

=head1 NAME

MooseX::Actor::MailBox - A class to ...

=head1 SYNOPSIS

    package My::Actor;
    with  qw(MooseX::Actor::MailBox);

=head1 DESCRIPTION

The MooseX::Actor::MailBox class implements a mailbox interface for an Actor
Model.

=head1 ATTRIBUTES

=over 

=item mailbox (ArrayRef[Message])

=back

=head1 METHODS

=over

=item post (Message $message)

Add a new message to the mailbox. 

=back

=head1 DEPENDENCIES

Moose::Role

MooseX::AttributeHelpers

namespace::autoclean

=head1 NOTES

...

=head1 BUGS AND LIMITATIONS

None known currently, please email the author if you find any.

=head1 AUTHOR

Chris Prather (perigrin@domain.tld)

=head1 LICENCE

Copyright 2009 by Chris Prather.

This software is free.  It is licensed under the same terms as Perl itself.

=cut
