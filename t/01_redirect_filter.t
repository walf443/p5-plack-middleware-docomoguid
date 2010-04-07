use strict;
use warnings;
use Test::More;
use Plack::Test;
use Plack::Builder;
use Plack::Request;

subtest 'do filter case' => sub {
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
            my $req = HTTP::Request->new(GET => "http://localhost/hello?foo=bar");
            my $res = $cb->($req);
            is($res->header('location'), 'http://localhost/hello?guid=ON&foo=bar');
        },
    );

    done_testing();
};

subtest 'should not work filter case' => sub {
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
                    return [302, [Location => "http://example.com/?foo=bar" ], []];
                };
            };
            $app->($env);
        },
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => "http://localhost/hello");
            my $res = $cb->($req);
            is($res->header('location'), 'http://example.com/?foo=bar');
        },
    );

    done_testing();
};

done_testing();
