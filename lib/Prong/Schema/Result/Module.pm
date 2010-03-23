package Prong::Schema::Result::Module;
use strict;
use warnings;
use base qw(Prong::Schema::Result);

__PACKAGE__->load_components( qw(TimeStamp UTF8Columns Core) );
__PACKAGE__->table( 'prong_module' );
__PACKAGE__->add_columns(
    id => {
        data_type => 'CHAR',
        size      => 36,
        is_nullable => 0,
        dynamic_default_on_create => 'uuid',
    },
    spec_version => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 0,
        default => '1.0',
    },
    title => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 0,
    },
    title_url => {
        data_type => 'CHAR',
        size => 512,
        is_nullable => 0,
    },
    description => {
        data_type => 'CHAR',
        size => 1024,
        is_nullable => 0,
    },
    author => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 0,
    },
    author_email => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 0,
    },
    screenshot => {
        data_type => 'CHAR',
        size => 512,
        is_nullable => 1,
    },
    thumbnail => {
        data_type => 'CHAR',
        size => 512,
        is_nullable => 1,
    },
    height => {
        data_type => 'INT',
        is_nullable => 0,
        default_value => 300
    },
    width => {
        data_type => 'INT',
        is_nullable => 0,
        default_value => 400
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
__PACKAGE__->utf8_columns( 'title', 'description', 'author' );
__PACKAGE__->has_many( contents =>
    'Prong::Schema::Result::ModuleContent' => 'module_id' );
__PACKAGE__->has_many( features =>
    'Prong::Schema::Result::ModuleFeature' => 'module_id' );
__PACKAGE__->has_many( preloads =>
    'Prong::Schema::Result::ModulePreload' => 'module_id' );
__PACKAGE__->has_many( userprefs =>
    'Prong::Schema::Result::ModuleUserPref' => 'module_id' );

1;
