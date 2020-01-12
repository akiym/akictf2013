package Problem6::Web;
use strict;
use warnings;
use utf8;
use parent qw/Problem6 Amon2::Web/;
use File::Spec;

# dispatcher
use Problem6::Web::Dispatcher;
sub dispatch {
    return (Problem6::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::JSON',
);

# setup view
use Problem6::Web::View;
{
    my $view = Problem6::Web::View->make_instance(__PACKAGE__);
    sub create_view { $view }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );
    },
);

1;
