package Q24::Web;
use strict;
use warnings;
use utf8;
use parent qw/Q24 Amon2::Web/;
use File::Spec;

# dispatcher
use Q24::Web::Dispatcher;
sub dispatch {
    return (Q24::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# setup view
use Q24::Web::View;
{
    my $view = Q24::Web::View->make_instance(__PACKAGE__);
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
