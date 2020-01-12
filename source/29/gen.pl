use 5.016;
use warnings;
use utf8;

my $img = shift or die "Usage: $0 image\n";

my $src = do {
    open my $fh, '<:raw', $img or die $!;
    local $/; <$fh>;
};
my %chars;
for my $b (split //, $src) {
    if ($b =~ /[a-z]/) {
        $chars{$b}++;
    }
}
my @keys = sort { $chars{$b} <=> $chars{$a} } keys %chars;

for my $i (0..9) {
    my $replacement = $keys[$i];
    warn $replacement;

    my $output = $src;
    $output =~ s/$replacement/a/g;

    open my $fh, '>', "gli/$i.jpg" or die $!;
    print {$fh} $output;
}
