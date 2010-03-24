use lib "lib";
use Prong::Server::Gadget;
use Plack::Builder;

builder {
    enable "Plack::Middleware::Static",
        path => qr{^/static/},
        root => "root/"
    ;

    mount "/" => Prong::Server::Gadget->new(
        schema => Prong::Schema->connect(
            'dbi:mysql:dbname=prong',
            'root',
            undef
        ),
        template => Text::MicroTemplate::File->new(
            use_cache => 1,
            include_path => [
                'root'
            ]
        )
    )->psgi_app;
};