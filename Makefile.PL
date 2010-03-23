use inc::Module::Install;

name 'Prong';

all_from 'lib/Prong.pm';

requires 'Data::UUID';
requires 'DBIx::Class';
requires 'Moose';
requires 'MooseX::Getopt';
requires 'XML::LibXML';
requires 'namespace::autoclean';

auto_set_repository;

WriteAll;
