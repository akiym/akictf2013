use 5.016;
use warnings;
use utf8;
use Imager;

my $img = Imager->new(file => 'pic2.gif') or die Imager->errstr;

my $width = $img->getwidth();
my $height = $img->getheight();

my @imgs;
for my $i (0 .. $height - 1) {
    my $newimg = $img->crop(
        left   => 0,
        right  => $width,
        top    => $i,
        bottom => $i + 1,
    ) or die $img->errstr;
    #$newimg->write(file => "pic_$i.gif") or die $img->errstr;
    push @imgs, $newimg;
}

Imager->new()->write_multi({
    file => 'anime.gif',
    gif_loop => 1,
}, @imgs);
