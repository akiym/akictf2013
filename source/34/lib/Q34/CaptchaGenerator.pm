package Q34::CaptchaGenerator;
use strict;
use warnings;
use utf8;
use Imager;

my $font = Imager::Font->new(
    file => 'share/migu-1m-bold.ttf',
    type => 'ft2',
) or die Imager->errstr;
my $bg = Imager::Color->new(255, 255, 255) or die Imager->errstr;
my $color = Imager::Color->new(0, 0, 0) or die Imager->errstr;

sub gen {
    my ($class, $key) = @_;
    my $img = Imager->new(
        xsize => 320,
        ysize => 50,
    ) or die Imager->errstr;
    $img->box(filled => 1, color => $bg);
    $img->filter(
        type    => 'noise',
        amount  => 300,
        subtype => 1,
    );
    $img->string(
        string => $key,
        font   => $font,
        size   => 38,
        color  => $color,
        x      => 7,
        y      => 36,
    );
    for (1 .. int(rand 10) + 10) {
        $img->line(
            color => $color,
            x1    => int rand 320,
            y1    => int rand 50,
            x2    => int rand 320,
            y2    => int rand 50,
        );
    }
    for (1 .. int(rand 15) + 5) {
        my $x = int rand 320;
        my $y = int rand 15;
        $img->polygon(
            color => $color,
            x     => [$x, $x + int rand 15, $x + int rand 15, $x + int rand 15],
            y     => [$y, $y + int rand 80, $y + int rand 80, $y + int rand 80],
        );
    }
    $img->write(data => \my $data, type => 'png') or die $img->errstr;
    return $data;
}

1;
