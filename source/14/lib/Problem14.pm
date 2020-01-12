package Problem14;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

__PACKAGE__->load_plugin(qw/DBI/);

# initialize database
use DBI;
sub setup_schema {
    my $self = shift;
    my $dbh = $self->dbh();
    my $driver_name = $dbh->{Driver}->{Name};
    my $fname = lc("sql/${driver_name}.sql");
    open my $fh, '<:encoding(UTF-8)', $fname or die "$fname: $!";
    my $source = do { local $/; <$fh> };
    for my $stmt (split /;/, $source) {
        next unless $stmt =~ /\S/;
        $dbh->do($stmt) or die $dbh->errstr();
    }
}

use HTTP::Session;
use HTTP::Session::Store::File;
use HTTP::Session::State::Cookie;
sub session {
    my $self = shift;
    HTTP::Session->new(
        store => HTTP::Session::Store::File->new(
            dir => '/home/ctfq/ctfq14/q14-session',
        ),
        state => HTTP::Session::State::Cookie->new(
            name => 'q14',
        ),
        id => 'Problem14::Session::ID::Vuln',
        request => $self->req->env,
    );
}

1;
