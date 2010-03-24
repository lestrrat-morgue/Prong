package Prong::Server::Gadget::Controller;
use Moose;
use namespace::autoclean;

with 'Prong::Trait::WithAPI';

has template => (
    is => 'rw',
    isa => 'Text::MicroTemplate::File',
    handles => {
        render => 'render_file',
    }
);

sub register {
    my ($self, $server) = @_;
    $self->apis( $server->apis );
    $self->template( $server->template );
}

__PACKAGE__->meta->make_immutable();

1;