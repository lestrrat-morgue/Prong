package Prong::Schema::Result::ModuleUserPref;
use strict;
use warnings;
use base qw(Prong::Schema::Result);

__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table( 'prong_module_userpref' );
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
    name => {
        data_type => 'CHAR',
        size => 64,
        is_nullable => 0,
    },
    data_type => {
        data_type => 'CHAR',
        size => 32,
        default_value => "string",
        is_nullable => 0,
    },
    display_name => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 0,
    },
    default_value => {
        data_type => 'CHAR',
        size => 256,
        is_nullable => 1,
    },
    is_required => {
        data_type => 'TINYINT',
        default_value => 0,
        is_nullable => 0,
    },
    content => {
        data_type => 'TEXT',
        is_nullable => 0,
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