use lib "lib";
use Prong::Server::Gadget;

Prong::Server::Gadget->new(
    schema => Prong::Schema->connect(
        'dbi:mysql:dbname=prong',
        'root',
        undef
    ),
    template => Text::MicroTemplate::File->new(
        use_cache => 1,
        include_path => [
            'templates'
        ]
    )
)->psgi_app;