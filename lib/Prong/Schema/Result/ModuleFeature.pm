package Prong::Schema::Result::ModuleFeature;
use strict;
use warnings;
use base qw(Prong::Schema::Result);

__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table( 'prong_module_feature' );
__PACKAGE__->add_columns(
    id => {
        data_type => 'CHAR',
        size      => 36,
        is_nullable => 0,
        dynamic_default_on_create => 'uuid',
    },
    module_id => {
        data_type => 'CHAR',
        size => 36,
        is_nullable => 0,
    },
    is_required => {
        data_type => 'TINYINT',
        is_nullable => 0,
        default_value => 0,
    },
    name => {
        data_type => 'CHAR',
        size => 64,
        is_nullable => 0,
    },
    version => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 0,
        default => '1.0',
    },
    created_on => {
        data_type => 'DATETIME',
        is_nullable => 0,
        set_on_create => 1,
    },
    modified_on => {
        data_type => 'TIMESTAMP',
        is_nullable => 0,
        set_on_create => 1,
        set_on_update => 1,
    },
);
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->belongs_to( module => 'Prong::Schema::Result::Module' => 'module_id' );

1;