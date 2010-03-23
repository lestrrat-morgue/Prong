package Prong::Schema::Result;
use strict;
use warnings;
use base qw(DBIx::Class);

use Data::UUID;

__PACKAGE__->mk_classdata('uuid_gen' => Data::UUID->new());
__PACKAGE__->mk_classdata(engine => 'InnoDB');
__PACKAGE__->mk_classdata(charset => 'UTF8');

sub uuid {
    my $self = shift;
    return $self->uuid_gen->create_str()
}

sub sqlt_deploy_hook {
    my ($self, $sqlt_table) = @_;

    $sqlt_table->extra->{mysql_table_type} = $self->engine;
    $sqlt_table->extra->{mysql_charset}    = $self->charset;
    return;
}

1;

