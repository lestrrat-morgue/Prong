package Prong::Schema::Result::ModulePreload;
use strict;
use warnings;
use base qw(Prong::Schema::Result);

__PACKAGE__->load_components( qw(TimeStamp Core) );
__PACKAGE__->table( 'prong_module_preload' );
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
    uri => {
        data_type => 'CHAR',
        size => 512,
        is_nullable => 0,
    },
    authz => {
        # NULL, signed, oauth
        data_type => 'CHAR',
        size => 32,
        is_nullable => 1
    },
    sign_owner => {
        data_type => 'TINYINT',
        is_nullable => 0,
        default_value => 1,
    },
    sign_viewer => {
        data_type => 'TINYINT',
        is_nullable => 0,
        default_value => 1,
    },
    views => {
        data_type => 'CHAR',
        size => 32,
        is_nullable => 1,
    },
    oauth_service_name => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 1,
    },
    oauth_token_name => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 1,
    },
    oauth_request_token => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 1,
    },
    oauth_request_token_secret => {
        data_type => 'CHAR',
        size => 128,
        is_nullable => 1,
    },
);
__PACKAGE__->set_primary_key( 'id' );
__PACKAGE__->belongs_to( module => 'Prong::Schema::Result::Module' => 'module_id' );

1;