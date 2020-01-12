package Problem14::Session::ID::Vuln;
use warnings;
use strict;
use Digest::MD5 ();

sub generate_id {
    my ($class, $sid_length) = @_;
    return substr(Digest::MD5::md5_hex(time()), 0, $sid_length);
}

1;
