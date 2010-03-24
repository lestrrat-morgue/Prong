package Prong::Server::Gadget::Controller::Application;
use Moose;
use namespace::autoclean;

extends 'Prong::Server::Gadget::Controller';

override register => sub {
    my ($self, $server) = @_;
    super();
    $server->add_route('/app/{module_id}' => { controller => $self, action => 'view' } );
};

sub view {
    my ($self, $req, $p) = @_;

    my ($content) = $self->api('ModuleContent')->search({
        module_id => $p->{module_id}
    });

    return $req->new_response(
        200,
        [ "Content-Type" => "text/html" ],
        $self->render( 'app/view.mt', $req, { content => $content } )
    );
}

__PACKAGE__->meta->make_immutable();

1;

