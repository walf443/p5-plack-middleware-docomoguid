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
__END__

=head1 NAME

Plack::Middleware::DoCoMoGUID::CheckParam - redirect to param append location if required param is not exist.

=head1 SYNOPSIS

    use Plack::Builder;

    builder {
        enable_if { $_[0]->{HTTP_USER_AGENT} =~ /DoCoMo/i } 'DoCoMoGUID::CheckParam', params => { guid => 'ON' };
        # if you are not specify params parameter, params is handled by { guid => 'ON' }.
    };

=head1 DESCRIPTION

Plack::Middleware::DoCoMoGUID::CheckParam is a Plack::Middleware that redirect to param append location if required param is not exist.

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<Plack::Middleware>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut