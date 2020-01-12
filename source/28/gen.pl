use 5.016;
use warnings;
use utf8;
use Audio::Wav;
use Math::Complex qw/pi2/;
use Convert::Morse qw/as_morse/;

my $SAMPLE_RATE = 44100;
my $BITS_SAMPLE = 16;

# flag: camel2

my @message = (
    'partfourofflagise',
    'parttwoofflagisa',
    'partsixofflagis2',
    'partfiveofflagisl',
    'partthreeofflagism',
    'partoneofflagisc',
);

my $i = 0;
for my $msg (@message) {
    my $wav = Audio::Wav->new();
    my $writer = $wav->write("$i.wav", {
        bits_sample => $BITS_SAMPLE,
        sample_rate => $SAMPLE_RATE,
        channels    => 1,
    });
    my $morse = as_morse($msg);
    warn $morse;
    for my $l (split //, $morse) {
        if ($l eq '-') {
            add_morse($writer, 1800 - ($i * 200), 0.2);
            add_morse($writer, 0, 0.1);
        } elsif ($l eq '.') {
            add_morse($writer, 1800 - ($i * 200), 0.1);
            add_morse($writer, 0, 0.1);
        } else {
            add_morse($writer, 0, 0.2);
        }
    }

    $i++;
}

sub add_morse {
    my ($writer, $hz, $length) = @_;
    $length *= $SAMPLE_RATE;
    my $max_no = (2 ** $BITS_SAMPLE) / 2 - 1;
    for my $pos (0 .. $length) {
        my $time = $pos / $SAMPLE_RATE;
        $time *= $hz;
        my $val = sin pi2 * $time;
        my $samp = $val * $max_no;
        $writer->write($samp);
    }
}
