package Q24::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;

use Digest::MD5 qw/md5_hex/;
use File::Basename;
use File::Spec;
use HTTP::Date;
use Log::Minimal;

any '/' => sub {
    my ($c) = @_;
    my $files = $c->dbh->selectall_arrayref(
        q{SELECT id, name, author, accesscode FROM images ORDER BY id DESC LIMIT 10},
        {Slice => {}}
    );
    # ignore '', 'welcome', 'flag'
    my @files = grep { $_->{name} !~ /^(?:|welcome|flag)$/ } @$files;
    return $c->render('index.tt' => {
        me    => $c->session->id,
        files => \@files,
    });
};

post '/upload' => sub {
    my ($c) = @_;
    my $name = $c->req->param('name') or die '@name';
    warnf('name: %s', $name);
    die '@name: not ascii' unless $name =~ /^[\x20-\x7e]+$/;
    my $imagedata = $c->req->upload('imagedata') or die '@imagedata';
    warnf('imagedata: %s (%s)', $imagedata->basename, $imagedata->content_type);
    die 'error: content_type' unless $imagedata->content_type eq 'image/png';
    die 'error: maximum size' unless $imagedata->size < 102400; # 100 kb

    $name = basename($name);
    $name =~ s/\.png$//;
    if ($name =~ /^(?:welcome|flag)$/) {
        return $c->create_response(
            500,
            ['Content-Type' => 'text/plain'],
            ["$name.png are belong to us."]
        );
    }

    infof('Upload image: %s (%s)', $name, $c->req->address);

    my $src = do {
        open my $fh, '<:raw', $imagedata->path or die $!;
        local $/; <$fh>;
    };
    open my $fh, '>:raw', File::Spec->catfile($c->base_dir, 'dat', "$name.png") or die $!;
    print {$fh} $src;

    my $accesscode = md5_hex('salt' . $name . 'peter');

    my ($exists) = $c->dbh->selectrow_array(
        q{SELECT 1 FROM images WHERE name = ?},
        undef,
        $name
    );
    if ($exists) {
        $c->dbh->do_i(
            q{UPDATE images SET}, {
                author => $c->session->id,
            }, q{ WHERE name =}, \$name
        );
    } else {
        $c->dbh->insert('images' => {
            name       => $name,
            author     => $c->session->id,
            accesscode => $accesscode,
        });
    }
    return $c->redirect("/file/$name.png", {accesscode => $accesscode});
};

get '/file/{filename}' => sub {
    my ($c, $args) = @_;

    my $filename = $args->{filename};
    my $code = $c->req->param('accesscode');
    warnf('filename: %s, accesscode: %s', $filename, $code);
    unless ($filename =~ s/\.png$//) {
        return $c->create_response(404, ['Content-Type' => 'text/plain'], ['not found']);
    }
    my $image = $c->dbh->selectrow_hashref(
        q{SELECT name, accesscode FROM images WHERE name = ?},
        {Slice => {}},
        $filename
    );
    unless ($image) {
        return $c->create_response(
            404,
            ['Content-Type' => 'text/plain'],
            ['not found']
        );
    }

    if (defined $code && $code eq $image->{accesscode}) {
        my $file = File::Spec->catfile($c->base_dir, 'dat', "$filename.png");
        my @stat = stat $file;
        open my $fh, '<:raw', $file or die $!;
        return $c->create_response(
            200,
            [
                'Content-Type'   => 'image/png',
                'Content-Length' => $stat[7],
                'Last-Modified'  => HTTP::Date::time2str($stat[9]),
            ],
            $fh
        );
    } else {
        return $c->create_response(
            403,
            ['Content-Type' => 'text/plain'],
            ['invalid access code']
        );
    }
};

1;
