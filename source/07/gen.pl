use 5.016;
use warnings;
use utf8;
use Encode;
use List::Util qw/shuffle/;
use Crypt::Caesar qw/caesar/;

my $text = 'DIMENSION-CONTROLLING FORT "DOH" HAS NOW BEEN DEMOLISHED, AND TIME STARTED FLOWING REVERSELY. "VAUS" MANAGED TO ESCAPE FROM THE DISTORTED SPACE. BUT THE REAL VOYAGE OF "ARKANOID" IN THE GALAXY HAS ONLY STARTED......';

my @char = ('A'..'Z');
my %greek = (
A => 'Α',
B => 'Β',
C => 'Γ',
D => 'Δ',
E => 'Ε',
Z => 'Ζ',
H => 'Η',
I => 'Ι',
K => 'Κ',
L => 'Λ',
M => 'Μ',
N => 'Ν',
O => 'Ο',
P => 'Π',
R => 'Ρ',
S => 'Σ',
T => 'Τ',
V => 'Υ',
Y => 'Υ',# same!
X => 'Χ',

F => 'F',
G => 'G',
J => 'J',
Q => 'Q',
U => 'U',
W => 'W',
);
my @greeks;
for my $c (@char) {
    push @greeks, $greek{$c};
}

my $search = join '', @char;
my $replace = join '', (@greeks[-5 .. -1], @greeks[0 .. @greeks-6]);
eval "\$text =~ tr/$search/$replace/;";
say encode_utf8($text);

my %reverse_table = (
    ' ' => ' ',
    '"' => '"',
    '#' => '#',
    ',' => ',',
    '-' => '-',
    '.' => '.',
);
for my $key (keys %greek) {
    $reverse_table{$greek{$key}} = $key;
}

$text =~ s/(.)/$reverse_table{$1}/g;
#say $text;

#say caesar($text);
