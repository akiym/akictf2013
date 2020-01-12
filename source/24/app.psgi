use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use Q24::Web;
use Q24;
use Plack::Session::Store::DBI;
use Plack::Session::State::Cookie;
use DBI;

my $db_config = Q24->config->{DBI} || die "Missing configuration for DBI";
builder {
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Log::Minimal';
    enable 'Plack::Middleware::Session',
        store => Plack::Session::Store::DBI->new(
            get_dbh => sub {
                DBI->connect( @$db_config )
                    or die $DBI::errstr;
            }
        ),
        state => Plack::Session::State::Cookie->new(
            httponly    => 1,
            session_key => 'gyazo_session',
        );
    Q24::Web->to_app();
};
