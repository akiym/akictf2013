use strict;
use warnings;
use utf8;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), 'extlib', 'lib', 'perl5');
use lib File::Spec->catdir(dirname(__FILE__), 'lib');
use Amon2::Lite;
use Plack::Builder;

our $VERSION = '0.01';

sub load_config {
    my $c = shift;

    my $dir = File::Spec->catdir($c->base_dir, 'files');
    opendir my $dh, $dir or die $!;
    my %files;
    for my $filename (grep !/^\.+/, readdir $dh) {
        my $src = do {
            open my $fh, '<', File::Spec->catfile($dir, $filename) or die $!;
            local $/; <$fh>;
        };
        $files{$filename} = $src;
    }
    +{
        files => \%files,
    }
}


get '/' => sub {
    my ($c) = @_;

    my @files = sort keys %{$c->config->{files}};
    return $c->render('index.tt', {
        files => \@files,
    });
};

get '/file' => sub {
    my ($c) = @_;

    my $filename = $c->req->param('f') or return $c->res_404();
    if ($filename =~ /flag/) {
        return $c->create_response(
            403,
            ['Content-Type' => 'text/plain'],
            ['403 Forbidden']
        );
    }

    my $body;
    for my $key (keys %{$c->config->{files}}) {
        if ($key =~ /$filename/) {
            warn $key;
            $body = $c->config->{files}{$key};
            last;
        }
    }
    return $c->res_404() unless defined $body;
    return $c->create_response(
        200,
        ['Content-Type' => 'text/plain'],
        [$body]
    );
};

builder {
    enable 'Plack::Middleware::ReverseProxy';
    __PACKAGE__->to_app();
};

__DATA__

@@ index.tt
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>q18</title>
</head>
<body>
<ul>[% FOR file IN files %]
    <li><a href="[% uri_for('file', {f => file}) %]">[% file %]</a></li>
[% END %]</ul>
</body>
</html>
