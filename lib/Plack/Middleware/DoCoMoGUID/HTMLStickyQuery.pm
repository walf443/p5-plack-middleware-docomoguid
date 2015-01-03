package Plack::Middleware::DoCoMoGUID::HTMLStickyQuery;
use strict;
use warnings;
use parent 'Plack::Middleware';
use Plack::Util;
use HTML::StickyQuery::DoCoMoGUID;

sub call {
    my ($self, $env) = @_;
    my $res = $self->app->($env);
    if ( $res->[0] == 200 ) {
        my $headers = $res->[1];
        my $body = $res->[2];
        my $content_type = Plack::Util::header_get($res->[1], 'content-type');
        if ( $content_type && $content_type =~ m{html} ) {
            my $sticky = HTML::StickyQuery::DoCoMoGUID->new;
            $sticky->{sticky}->utf8_mode(1);
            $body = $sticky->sticky(
                arrayref => $body,
                ( $self->{params} ? ( param => $self->{params} ) : () ),
            );
            if ( Plack::Util::header_exists($res->[1], 'Content-Length') ) {
                Plack::Util::header_set($res->[1], 'Content-Length', length($body));
            }
            $res->[2] = [ $body ];
        }
    }

    return $res;
}

1;
__END__

=head1 NAME

Plack::Middleware::DoCoMoGUID::HTMLStickyQuery - Add C<?guid=ON> to HTML content links.

=head1 SYNOPSIS

    use Plack::Builder;

    builder {
        enable_if { $_[0]->{HTTP_USER_AGENT} =~ /DoCoMo/i } 'DoCoMoGUID::HTMLStickyQuery';
    };

or add check param

    use Plack::Builder;

    builder {
        enable_if { $_[0]->{HTTP_USER_AGENT} =~ /DoCoMo/i } 'DoCoMoGUID::HTMLStickyQuery' params => +{ 'foo' => 'bar' };
    };

this will also append the C<foo> parameter to all relative links and form actions.

=head1 DESCRIPTION

Plack::Middleware::DoCoMoGUID::HTMLStickyQuery is a L<Plack::Middleware> that
filters HTML content and adds C<?guid=ON> to all relative links and form actions
using L<HTML::StickyQuery::DoCoMoGUID>.

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

L<HTML::StickyQuery::DoCoMoGUID>,
L<Plack::Middleware>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
