package Problem14::Web;
use strict;
use warnings;
use utf8;
use parent qw/Problem14 Amon2::Web/;
use File::Spec;

# dispatcher
use Problem14::Web::Dispatcher;
sub dispatch {
    return (Problem14::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# setup view
use Problem14::Web::View;
{
    my $view = Problem14::Web::View->make_instance(__PACKAGE__);
    sub create_view { $view }
}

1;
