use 5.016;
use warnings;
use utf8;
use Acme::EyeDrops qw/sightly/;

print sightly({
    Shape => 'damian',
    Regex => 1,
    Print => 1,
    SourceString => 'Damian Conway',
});
