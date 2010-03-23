package Prong::Schema::Result::ModuleContent;
use strict;
use warnings;
use base qw(Prong::Schema::Result);

__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table( 'prong_module_content' );
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
    content_type => {
        data_type => 'CHAR',
        size => 16,
        is_nullable => 0,
    },
    uri => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 1 # only if content_type is not uri...
    },
    preferred_height => {
        data_type => 'INTEGER',
        is_nullable => 1,
    },
    preferred_width => {
        data_type => 'INTEGER',
        is_nullable => 1,
    },
    view => {
        # XXX normalize?
        data_type => 'TEXT',
        is_nullable => 1,
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