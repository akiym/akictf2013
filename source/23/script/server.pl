use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '..', 'lib');
use Q23::Server;
use File::Basename;
use File::Spec;

$Q23::Server::PROBLEM = do File::Spec->catfile(dirname(__FILE__), 'problem.pl');
warn "couldn't parse: $@" if $@;
warn "couldn't do: $!"    unless defined $Q23::Server::PROBLEM;
warn "couldn't run"       unless $Q23::Server::PROBLEM;

$Q23::Server::PROBLEM_NUM = scalar @$Q23::Server::PROBLEM;

Q23::Server->run(
    port => 17023,
);
