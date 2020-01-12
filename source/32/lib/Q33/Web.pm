package Q33::Web;
use strict;
use warnings;
use utf8;
use parent qw/Q33 Amon2::Web/;
use File::Spec;

# dispatcher
use Q33::Web::Dispatcher;
sub dispatch {
    return (Q33::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# setup view
use Q33::Web::View;
{
    sub create_view {
        my $view = Q33::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *Q33::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

sub create_simple_status_page {
    my ($c, $code, $message) = @_;
    return $c->create_response(
        $code,
        ['Content-Type' => 'text/plain'],
        [$message]
    );
}

1;
