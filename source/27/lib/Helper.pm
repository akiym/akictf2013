package Helper;
use strict;
use warnings;
use utf8;
use Digest::SHA;
use Digest::MD5 qw/md5_hex/;

sub gen_hashed_password {
    my ($class, $username, $password) = @_;

    my $hash = '';
    my $salt = $class->gen_salt($username);
    my $sha = Digest::SHA->new('SHA-256');
    for (1..893) {
        $sha->add($hash, $password, $salt);
        $hash = $sha->hexdigest;
    }
    return $hash;
}

sub gen_salt {
    my ($class, $username) = @_;
    return $username . pack('H*', 'salt_JyOnfbpcqRandomRQp6bg5ALTfsrvrWa');
}

sub _random_string {
    my ($class, $len, $chars) = @_;
    my $ret = '';
    for (1..$len) {
        $ret .= $chars->[int rand @$chars];
    }
    return $ret;
}

sub gen_ident {
    my ($class, $user_id, $screen_name) = @_;
    return $user_id . ':' . md5_hex($screen_name);
}

1;
