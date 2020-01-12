package Q34::Web;
use strict;
use warnings;
use utf8;
use parent qw/Q34 Amon2::Web/;
use File::Spec;

# dispatcher
use Q34::Web::Dispatcher;
sub dispatch {
    return (Q34::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# setup view
use Q34::Web::View;
{
    sub create_view {
        my $view = Q34::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *Q34::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

sub render_text {
    my ($c, $text, $code) = @_;
    $code ||= 200;
    $text = Encode::encode($c->encoding, $text);
    return $c->create_response(
        $code,
        [
            'Content-Type'   => 'text/html; charset=utf-8',
            'Content-Length' => length($text),
        ],
        [$text]
    );
}

sub create_simple_status_page {
    my ($c, $code, $text) = @_;
    return $c->render_text($text, $code);
}

1;
