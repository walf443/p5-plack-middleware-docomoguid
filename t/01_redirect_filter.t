use strict;
use warnings;
use Test::More;
use Plack::Test;
use Plack::Builder;
use Plack::Request;

test_psgi(
    app => sub {
        my $env = shift;
        my $app = builder {
            enable 'Lint';
            enable 'DoCoMoGUID::RedirectFilter';
            enable 'Lint';
            sub {
                my $env = shift;
                my $req = Plack::Request->new($env);
                if ( $req->param('guid') ) {
                    return [200, [], ['found']];
                } else {
                    return [302, [Location => $req->uri->as_string], []];
                }
            };
        };
        $app->($env);
    },
    client => sub {
        my $cb = shift;
        my $req = HTTP::Request->new(GET => "http://localhost/hello");
        my $res = $cb->($req);
        is($res->header('location'), 'http://localhost/hello?guid=ON');
    }
);

done_testing();
