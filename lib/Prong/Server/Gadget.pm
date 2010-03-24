package Prong::Server::Gadget;
use Moose;
use Prong::Schema;
use Plack::Request;
use Router::Simple;
use Text::MicroTemplate::File;
use namespace::autoclean;

with qw(
    Prong::Trait::WithAPI
    Prong::Trait::WithDBIC
);

has controllers => (
    is => 'ro',
    isa => 'ArrayRef',
    lazy_build => 1,
);

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

sub BUILD {
    my $self = shift;
    foreach my $controller (@{ $self->controllers }) {
        $controller->register( $self );
    }
}

sub _build_apis {
    my $self = shift;

    my %apis;
    foreach my $module qw(Module ModuleContent) {
        my $class = "Prong::API::$module";
        if (! Class::MOP::is_class_loaded($class)) {
            Class::MOP::load_class($class);
        }

        $apis{ $module } = $class->new(schema => $self->schema, apis => \%apis);
    }

    return \%apis;
}

sub _build_controllers {
    my $self = shift;

    my @controllers;
    foreach my $controller qw(Root Application) {
        my $class = "Prong::Server::Gadget::Controller::$controller";
        if (! Class::MOP::is_class_loaded( $class ) ) {
            Class::MOP::load_class( $class );
        }
        push @controllers, $class->new();
    }
    return \@controllers;
}

sub _build_router {
    my $self = shift;
    return Router::Simple->new();
}

sub add_route {
    my ($self, @args) = @_;
    $self->router->connect(@args);
}

sub process {
    my ($self, $env) = @_;

    if (my $p = $self->router->match( $env )) {
        my $controller = $p->{controller};
        my $action     = $p->{action};
        my $res = $controller->$action( Plack::Request->new( $env ), $p );
        return (blessed $res) ?
            $res->finalize() :
            $res
        ;
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