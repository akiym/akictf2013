use 5.016;
use warnings;
use utf8;
use MIME::Base64;

my $flag = 'The flag is S3CR3T_K3Y';

$flag = reverse $flag;
say $flag;

$flag = encode_base64($flag);
say $flag;

$flag = reverse $flag;
say $flag;
