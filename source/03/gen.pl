use 5.016;
use warnings;
use utf8;
use Acme::Collector64;
use Encode;

my $table = join '', reverse ('A'..'Z', 'a'..'z', '0'..'9', '+', '/', '=');

my $c64 = Acme::Collector64->new(
    index_table => $table,
);

say $c64->encode(encode_utf8('Well done! The flag is "All your Base64 are belong to us".'));

say $c64->decode('rKrUl+/clKHb4u/sm6sgnaPfnO/XkO=ewqPU45bRjp4gwa7NntoM467Onu/enqPRlakgj6Egjp0e1gAA');
