package Plack::Middleware::DoCoMoGUID;

use strict;
use warnings;
our $VERSION = '0.06';
use parent 'Plack::Middleware';

use Plack::Middleware::DoCoMoGUID::HTMLStickyQuery;
use Plack::Middleware::DoCoMoGUID::RedirectFilter;
use Plack::Middleware::DoCoMoGUID::CheckParam;

sub call {
    my ($self, $env) = @_;

    my %params;
    if ( $self->{params} ) {
        $params{params} = $self->{params};
    }
    my $app = Plack::Middleware::DoCoMoGUID::HTMLStickyQuery->wrap($self->app, %params);
    $app = Plack::Middleware::DoCoMoGUID::RedirectFilter->wrap($app, %params);
    $app = Plack::Middleware::DoCoMoGUID::CheckParam->wrap($app, %params);
    return $app->($env);
}

1;
__END__

=head1 NAME

Plack::Middleware::DoCoMoGUID - Combine Plack::Middleware::DoCoMoGUID::RedirectFilter and Plack::Middleware::DoCoMoGUID::HTMLStickyQuery.

=head1 SYNOPSIS

  use Plack::Builder;

  builder {
    enable_if { $_[0]->{HTTP_USER_AGENT} =~ m/DoCoMo/i } "DoCoMoGUID";
  };

or add check param

  builder {
    enable_if { $_[0]->{HTTP_USER_AGENT} =~ m/DoCoMo/i } "DoCoMoGUID", params => +{
        'foo' => 'bar',
    };
  };

this will check for the C<guid> and C<foo> parameter.

=head1 DESCRIPTION

Plack::Middleware::DoCoMoGUID is a L<Plack::Middleware> that filters HTML
content and adds C<?guid=ON> to all relative links and form actions using
L<HTML::StickyQuery::DoCoMoGUID> as well as to the Location header on
redirects.

If you only need the functionality of one module, consider using
L<Plack::Middleware::DoCoMoGUID::RedirectFilter> or
L<Plack::Middleware::DoCoMoGUID::HTMLStickyQuery> directly.

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

L<Plack::Middleware::DoCoMoGUID::RedirectFilter>,
L<Plack::Middleware::DoCoMoGUID::HTMLStickyQuery>,
L<Plack::Middleware::DoCoMoGUID::CheckParam>,
L<Plack::Middleware>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
