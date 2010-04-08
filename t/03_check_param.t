use strict;
use warnings;
use Test::More;
use HTTP::Request;
use Plack::Test;
use Plack::Builder;
use Plack::Request;

subtest 'do filter case' => sub {
    test_psgi(
        app => sub {
            my $env = shift;
            my $app = builder {
                enable 'Lint';
                enable 'DoCoMoGUID::CheckParam';
                enable 'Lint';
                sub {
                    my $env = shift;
                    return [200, [], ['hello']];
                };
            };
            $app->($env);
        },
        client => sub {
            my $cb = shift;
            {
                my $req = HTTP::Request->new(GET => "http://localhost/hello?foo=bar");
                my $res = $cb->($req);
                is($res->code, 302, 'redirect ok')
                    or diag($res->content);
                is($res->header('location'), 'http://localhost/hello?guid=ON&foo=bar', 'guid=ON should set');
            }
            {
                my $req = HTTP::Request->new(GET => "http://localhost/hello?foo=bar&guid=FOO");
                my $res = $cb->($req);
                is($res->code, 200, 'redirect should not work')
                    or diag($res->content);
            }
        },
    );

    done_testing();
};

subtest 'use optional param' => sub {
    test_psgi(
        app => sub {
            my $env = shift;
            my $app = builder {
                enable 'Lint';
                enable 'DoCoMoGUID::CheckParam', params => +{ guid => 'ON', always => 'need' };
                enable 'Lint';
                sub {
                    my $env = shift;
                    return [200, [], ['hello']];
                };
            };
            $app->($env);
        },
        client => sub {
            my $cb = shift;
            {
                my $req = HTTP::Request->new(GET => "http://localhost/hello?foo=bar");
                my $res = $cb->($req);
                is($res->code, 302, 'redirect ok')
                    or diag($res->content);
                is($res->header('location'), 'http://localhost/hello?guid=ON&always=need&foo=bar', 'guid=ON and always=need should set');
            }
            {
                my $req = HTTP::Request->new(GET => "http://localhost/hello?foo=bar&always=need&guid=FOO");
                my $res = $cb->($req);
                is($res->code, 200, 'redirect should not work')
                    or diag($res->content);
            }
        },
    );

    done_testing();
};

done_testing();
