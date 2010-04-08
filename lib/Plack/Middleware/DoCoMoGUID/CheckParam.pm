package Plack::Middleware::DoCoMoGUID::CheckParam;
use strict;
use warnings;
use parent 'Plack::Middleware';
use URI;

sub call {
    my ($self, $env) = @_;
    if ( $env->{QUERY_STRING} !~ m/(^|&)guid=/ ) {
        my $redirect_uri = sprintf('%s://%s%s', $env->{'psgi.url_scheme'}, ($env->{HTTP_HOST} || $env->{SERVER_NAME}), $env->{REQUEST_URI});
        my $uri = URI->new($redirect_uri);
        $uri->query_form(guid => 'ON', $uri->query_form);
        return [ 302, [ Location => $uri->as_string ], [] ];
    } else {
        return $self->app->($env);
    }
}

1;
