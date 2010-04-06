package Plack::Middleware::DoCoMoGUID;

use strict;
use warnings;
our $VERSION = '0.01';
use parent 'Plack::Middleware';

use Plack::Middleware::DoCoMoGUID::HTMLStickyQuery;
use Plack::Middleware::DoCoMoGUID::RedirectFilter;

sub call {
    my ($self, $env) = @_;

    my $app = Plack::Middleware::DoCoMoGUID::HTMLStickyQuery->wrap($self->app);
    $app = Plack::Middleware::DoCoMoGUID::RedirectFilter->wrap($app);
    return $app->($env);
}

1;
__END__

=head1 NAME

Plack::Middleware::DoCoMoGUID - combine DoCoMoGUID::RedirectFilter and DoCoMoGUID::HTMLStickyQuery.

=head1 SYNOPSIS

  use Plack::Builder;

  builder {
    enable_if { $_[0]->{UserAgent} =~ m/DoCoMo/i } "DoCoMoGUID";
  };

=head1 DESCRIPTION

Plack::Middleware::DoCoMoGUID append ?guid=ON to HTML content relative link or form action or Location header of your HTTP_HOST.

If you want not to use with redirect filter and html filter, consider using RedirectFilter or HTMLStickyQuery separatery.

=head1 AUTHOR

Keiji Yoshimi E<lt>walf443 at gmail dot comE<gt>

=head1 SEE ALSO

+<Plack::Middleware::DoCoMoGUID::RedirectFilter>, +<Plack::Middleware::DoCoMoGUID::HTMLStickyQuery>

http://www.nttdocomo.co.jp/service/imode/make/content/ip/index.html#imodeid

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
