use strict;
use warnings;
use utf8;
use Test::More;
use Encode;
use HTTP::Request;
use Plack::Test;
use Plack::Builder;
use Plack::Request;
use HTML::TreeBuilder::XPath;

subtest 'success case' => sub {
    test_psgi(
        app => sub {
            my $env = shift;
            my $app = builder {
                enable 'Lint';
                enable 'DoCoMoGUID::HTMLStickyQuery';
                enable 'Lint';
                sub {
                    my $env = shift;

                    my $body = <<"...";

                    <html>
                        <head></head>
                        <body>
                            <a class="should_replace1" href="/foo?foo=bar">foo</a>
                            <a class="should_replace2" href="relative?foo=bar">あいうえお</a>
                            <a class="should_not_replace" href="http://example.com/?foo=bar">かきくけこ</a>

                            <form method="POST" action="/foo?foo=bar">
                            </form>
                        </body>
                    </html>
...

                    $body = Encode::encode_utf8($body);
                    [200, [ 'Content-Type' => 'text/html'], [ $body ] ];
                };
            };
            $app->($env);
        },
        client => sub {
            my $cb = shift;
            my $req = HTTP::Request->new(GET => "http://localhost/hello?foo=bar");
            my $res = $cb->($req);
            unless ( $res->is_success ) {
                die $res->content;
            }
            my $tree = HTML::TreeBuilder::XPath->new;
            $tree->parse(Encode::decode_utf8($res->content));
            my $node1 = $tree->findnodes('//a[@class="should_replace1"]');
            is($node1->[0]->attr('href'), '/foo?guid=ON&foo=bar', 'should_replace1 ok');

            my $node2 = $tree->findnodes('//a[@class="should_replace2"]');
            is($node2->[0]->attr('href'), 'relative?guid=ON&foo=bar', 'should_replace2 ok');

            my $node3 = $tree->findnodes('//a[@class="should_not_replace"]');
            is($node3->[0]->attr('href'), 'http://example.com/?foo=bar', 'should_not_replace ok');
        },
    );

    done_testing();
};

done_testing();
