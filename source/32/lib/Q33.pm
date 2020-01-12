package Q33;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;

use parent qw/Amon2/;

use DBI;
sub dbh {
    my $c = shift;
    if (!exists $c->{dbh}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        $c->{dbh} = DBI->connect(@$conf);
    }
    $c->{dbh};
}

1;
__END__

=head1 NAME

Q33 - Q33

=head1 DESCRIPTION

This is a main context class for Q33

=head1 AUTHOR

Q33 authors.

