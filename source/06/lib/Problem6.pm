package Problem6;
use strict;
use warnings;
use utf8;
use parent qw/Amon2/;
our $VERSION='0.01';
use 5.008001;

use Digest::MD5;
sub gen_hash {
    my ($self, $money, $stretch) = @_;
    $stretch ||= 1;
    for (1 .. $stretch) {
        $money = Digest::MD5::md5_hex($money);
    }
    return $money;
}

1;
