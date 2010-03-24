package Prong::Trait::WithAPI;
use Moose::Role;
use namespace::autoclean;

has apis => (
    is => 'rw',
    isa => 'HashRef[Object]',
    lazy_build => 1,
);

sub _build_apis { +{} }

sub api {
    my ($self, $key) = @_;
    my $api = $self->apis->{$key};
    if (! $api) {
        confess "API by key $key was not found for $self";
    }
    return $api;
};

1;

