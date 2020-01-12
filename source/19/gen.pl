use 5.016;
use warnings;
use utf8;

my $flag = 'GreatPyramidOfGiza';
my $len = length $flag;
my $blocks = 1;
for my $i (1 .. $len) {
    my $str = random_string($blocks);
    # ピラミッドの中央にflagを入れる
    my $offset = ($blocks + 1) / 2 - 1;
    substr($str, $offset, 1, substr($flag, $i - 1, 1));
    #print ' ' x ($len - $i);
    say $str;
    $blocks += 2;
}

sub random_string {
    my $length = shift;
    my @chars = ('A'..'Z', 'a'..'z');
    my $ret;
    for (1..$length) {
        $ret .= $chars[int rand @chars];
    }
    return $ret;
}
