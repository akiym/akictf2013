use 5.016;
use warnings;
use utf8;
use Digest::MD5 qw/md5_hex/;

mkdir 'q15';
chdir 'q15';

my @char_table = ('A'..'Z', 'a'..'z');
for (1..16) {
    my $text = $char_table[int rand 52];
    my $filename = md5_hex($text);
    say $text;
    open my $fh, '>', $filename or die $!;
    print {$fh} "$text\n";

    sleep 1;
}
