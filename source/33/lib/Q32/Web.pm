package Q32::Web;
use strict;
use warnings;
use utf8;
use parent qw/Q32 Amon2::Web/;
use File::Spec;

# dispatcher
use Q32::Web::Dispatcher;
sub dispatch {
    return (Q32::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
);

# setup view
use Q32::Web::View;
{
    sub create_view {
        my $view = Q32::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *Q32::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

1;
