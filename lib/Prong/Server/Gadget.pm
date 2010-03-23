package Prong::Server::Gadget;
use Moose;
use Prong::Schema;
use Plack::Request;
use Router::Simple;
use Text::MicroTemplate::File;
use namespace::autoclean;

has router => (
    is => 'ro',
    isa => 'Router::Simple',
    lazy_build => 1,
);

has template => (
    is => 'ro',
    isa => 'Text::MicroTemplate::File',
    required => 1,
);

has schema => (
    is => 'ro',
    isa => 'Prong::Schema',
    required => 1,
);

sub _build_router {
    my $self = shift;

    my $router = Router::Simple->new();
    $router->connect('/' => {
        code => sub {
            my $req = shift;
            my @modules = $self->schema->resultset('Module')->search();
            return [
                200,
                [ "Content-Type" => "text/html" ],
                [ $self->template->render_file( 'index.mt', $req, { modules => \@modules } ) ]
            ];
        }
    } );

    $router->connect('/app/{module_id}' => {
        code => sub {
            my ($req, $p) = @_;
            my $content = $self->schema->resultset('ModuleContent')->search({
                module_id => $p->{module_id},
            })->single;
            return [
                200,
                [ "Content-Type" => "text/html" ],
                [ $self->template->render_file( 'app/view.mt', $req, { content => $content } ) ]
            ];
        }
    });

    return $router;
}

sub process {
    my ($self, $env) = @_;

    if (my $p = $self->router->match( $env )) {
        return $p->{code}->( Plack::Request->new( $env ), $p );
    }

    return [ 404, [], [ 'Not Found' ] ];
}

sub psgi_app {
    my $self = shift;
    return sub {
        my $env = shift;
        $self->process( $env );
    };
}

__PACKAGE__->meta->make_immutable();

1;