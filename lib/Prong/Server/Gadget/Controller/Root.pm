package Prong::Server::Gadget::Controller::Root;
use Moose;
use namespace::autoclean;

extends 'Prong::Server::Gadget::Controller';

override register => sub {
    my ($self, $server) = @_;
    super();
    $server->add_route('/' => { controller => $self, action => 'index' });
};

sub index {
    my ($self, $req, $args) = @_;
    my @modules = $self->api('Module')->search();

    return $req->new_response(
        200,
        [ "Content-Type" => "text/html" ],
        $self->render( 'index.mt', $req, { modules => \@modules } )
    );
}

__PACKAGE__->meta->make_immutable();

1;