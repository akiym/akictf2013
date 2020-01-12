package Q34;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;

use parent qw/Amon2/;

use Cache::Memcached::Fast;
sub memd {
    my $c = shift;
    if (!exists $c->{memd}) {
        my $conf = $c->config->{'Cache::Memcached::Fast'}
            or die "Missing configuration about Cache::Memcached::Fast";
        $c->{memd} = Cache::Memcached::Fast->new($conf);
    }
    $c->{memd};
}

1;
__END__

=head1 NAME

Q34 - Q34

=head1 DESCRIPTION

This is a main context class for Q34

=head1 AUTHOR

Q34 authors.

