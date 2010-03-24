package Prong::API::WithDBIC;
use Moose::Role;
use namespace::autoclean;

with
    'Prong::Trait::WithDBIC' => {
        -excludes => [ qw(_build_default_moniker) ],
    },
    'MooseX::WithCache' => {
        backend => 'Cache::Memcached'
    }
;

has primary_key => (
    is => 'ro',
    required => 1,
    lazy_build => 1
);

has cache_prefix => (
    is => 'ro',
    required => 1,
    lazy_build => 1,
);

sub _build_default_moniker {
    my $self = shift;
    return
        ((blessed $self) =~ /^Prong::API::(.+)$/) ?
        $1 :
        ()
    ;
}

sub _build_primary_key {
    my $self = shift;
    my $schema = $self->schema();
    my $rs = $self->resultset();

    my @pk = $rs->result_source->primary_columns;
    return [ @pk ];
}

sub _build_cache_prefix {
    my $self = shift;
    return join('.', split(/\./, ref $self));
}

sub find {
    my ($self, @id) = @_;

    my $schema    = $self->schema();
    my $cache_key = [$self->cache_prefix, @id ];
    my $obj       = $self->cache_get($cache_key);
    if ($obj) {
        $obj = $schema->thaw($obj);
    } else {
        $obj = $self->resultset->find(@id);
        if ($obj) {
            $self->cache_set($cache_key, $schema->freeze($obj));
        }
    }
    return $obj;
}

sub load_multi {
    my ($self, @ids) = @_;

    my $schema = $self->schema();

    # keys is a bit of a hassle
    my $rs = $self->resultset();
    my @keys = map { [ $self->cache_prefix, ref $_ ? @$_ : $_ ] } @ids;
    my $h = $self->cache_get_multi(@keys);

    my @ret;
    if ($h) {
        my $results = $h->{results};
        foreach my $key (@keys) {
            if (my $got = $results->{$key}) {
                push @ret, $schema->thaw($got);
            } else {
                push @ret, $self->find( ref $key->[1] ? @{$key->[1]} : $key->[1]);
            }
        }
    } else {
        @ret = map { $self->find($_) } @ids;
    }

    return wantarray ? @ret : \@ret;
}


sub search {
    my ($self, $where, $attrs) = @_;

    $attrs ||= {};

    my $rs = $self->resultset();
    my $pk = $self->primary_key();

    $attrs->{select} ||= $pk;

    my @rows = $rs->search($where, $attrs);
    my @keys = map {
        my $row = $_;
        [ map { $row->$_ } @$pk ]
    } @rows;

    return $self->load_multi(@keys);
}

sub create {
    my ($self, $args) = @_;
    my $rs = $self->resultset();
    return $rs->create($args);
}

sub update {
    my ($self, $args) = @_;

    my $schema = $self->schema();

    my $pk = $self->primary_key();
    my $rs = $self->resultset();
    my $key = [ map { delete $args->{$_} } @$pk ];

    my $guard = $schema->txn_scope_guard;

    my $row = $self->find(@$key);
    if ($row) {
        while (my ($field, $value) = each %$args) {
            if (! $row->can($field)) {
                confess blessed $self . ": Attempt to update unknown column: $field";
            }
            $row->$field( $value );
        }
        $row->update;
        $self->cache_del([ $self->cache_prefix, @$key ]);
    }

    $guard->commit;

    return $row;
}

sub delete {
    my ($self, @id) = @_;

    my $schema = $self->schema();

    my $guard = $schema->txn_scope_guard;
    foreach my $id (@id) {
        my @key = ref $id ? @$id : $id;
        my $obj = $schema->resultset($self->resultset_moniker)->find(@key);
        if ($obj) {
            $obj->delete;
        }

        my $cache_key = [$self->cache_prefix, @key ];
        $self->cache_del($cache_key);
    }

    $guard->commit;
    return ();
}

sub all {
    my $self = shift;

    my $pk = $self->primary_key;

    # Should optimize this!
    my @all = $self->resultset->search(
        {},
        { select => $self->primary_key }
    );
    return $self->load_multi( map {
        my $h = $_;
        [ map { $h->$_ } @$pk ]
    } @all);
}

1;
