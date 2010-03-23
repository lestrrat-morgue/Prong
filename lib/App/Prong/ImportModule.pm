package App::Prong::ImportModule;
use Moose;
use XML::LibXML;
use namespace::autoclean;

with 'MooseX::Getopt';

has dsn => (is => 'ro', isa => 'Str', required => 1, default => $ENV{TEST_DSN});
has username => (is => 'ro', isa => 'Str');
has password => (is => 'ro', isa => 'Str');
has source => (is => 'ro', isa => 'ArrayRef', predicate => 'has_source');
has schema_class => (is => 'ro', isa => 'Str', default => 'Prong::Schema');
has data_source => (is => 'ro', isa => 'Str');

has parser => (
    traits => [ 'NoGetopt' ],
    is => 'ro',
    isa => 'XML::LibXML',
    lazy_build => 1,
);

sub run {
    my $self = shift;

    my $file = $self->extra_argv->[0];
    if (! $file) {
        confess "No file specified";
    }

    
    my $xml = $self->parser->parse_file( $file );
    my $schema_class = $self->schema_class;
    if (! Class::MOP::is_class_loaded( $schema_class ) ) {
        Class::MOP::load_class( $schema_class );
    }

    my $schema = $schema_class->connect(
        $self->dsn,
        $self->username,
        $self->password,
        {
            RaiseError => 1,
            AutoCommit => 1,
        }
    );

    my $guard = $schema->txn_scope_guard();

    my $module = $self->create_module( $schema, $xml );

    $guard->commit;
}

sub _build_parser {
    return XML::LibXML->new();
}

sub create_module {
    my ($self, $schema, $xml) = @_;

    my %args = (
        spec_version => $xml->findvalue('/Module/@speficiationVersion') || '1.0',
        $self->_get_module_prefs($xml->findnodes('/Module/ModulePrefs')),
    );
    my $module = $schema->resultset('Module')->create( \%args );

    $self->create_module_prefs( $module, $schema, $xml->findnodes('/Module/ModulePrefs' ) );

    foreach my $userpref ($xml->findnodes('/Module/UserPref')) {
        $self->create_module_userpref( $module, $schema, $userpref );
    }

    foreach my $content ($xml->findnodes('/Module/Content')) {
        $self->create_module_content( $module, $schema, $content );
    }
}

sub create_module_prefs {
    my ($self, $module, $schema, $xml) = @_;

    foreach my $required ( $xml->findnodes( 'Require' ) ) {
        $module->create_related('features', {
            name => $required->findvalue('@feature'),
            version => $required->findvalue('@version'),
            is_required => 1,
        } );
    }

    foreach my $required ( $xml->findnodes( 'Optional' ) ) {
        $module->create_related('features', {
            name => $required->findvalue('@feature'),
            version => $required->findvalue('@version'),
            is_required => 0,
        } );
    }

    foreach my $preload ( $xml->findnodes( 'Preload' ) ) {
        my %args = (
            uri => $preload->findvalue('@href'),
        );
        foreach my $attr qw( authz sign_owner sign_viewer views ) {
            my $value = $preload->findvalue("\@$attr");
            $args{ $attr } = $value if defined $value && length $value;
        }
        $module->create_related('preloads', \%args);
    }

    return $module;
}

sub _get_module_prefs {
    my ($self, $xml) = @_;

    return unless $xml;

    my %attrs;

    foreach my $attr qw(title title_url description author author_email screenshot thumbnail height width) {
        my $value = $xml->findvalue("\@$attr");
        $attrs{ $attr } = $value if defined $value && length $value;
    }

    return %attrs;
}

sub create_module_userpref {
    my ($self, $module, $schema, $xml) = @_;

    my %attrs = (
        name => $xml->findvalue('@name'),
        data_type => $xml->findvalue('@datatype') || undef,
    );

    foreach my $attr qw(display_name default_alue) {
        my $value = $xml->findvalue("\@$attr");
        $attrs{ $attr } = $value if defined $value && length $value;
    }
    $module->create_related('userprefs', \%attrs );
}

sub create_module_content {
    my ($self, $module, $schema, $xml) = @_;

    my %attrs = (
        content_type => $xml->findvalue('@type'),
        uri => $xml->findvalue('@href') || undef,
        view => $xml->findvalue('@view'),
        content => $xml->textContent(),
    );

    foreach my $attr qw(preferred_height preferred_width) {
        my $value = $xml->findvalue("\@$attr");
        $attrs{ $attr } = $value if defined $value && length $value;
    }
    $module->create_related('contents', \%attrs );
}

__PACKAGE__->meta->make_immutable();

1;