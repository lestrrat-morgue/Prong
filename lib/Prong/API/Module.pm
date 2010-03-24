package Prong::API::Module;
use Moose;
use namespace::autoclean;

with 'Prong::API::WithDBIC';

__PACKAGE__->meta->make_immutable();

1;
