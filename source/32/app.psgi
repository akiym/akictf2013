use strict;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Plack::Builder;

use Q33::Web;
use Q33;

builder {
    enable 'Plack::Middleware::ReverseProxy';
    Q33::Web->to_app();
};
