use strict;
use warnings;
use Plack::Builder;
use Cache::Memory::Simple;

my $_CACHE = Cache::Memory::Simple->new();

my $flag = '6890c6f34d3c3ad95cfa13ab321943d7';
my $flag_len = length $flag;

my $app = sub {
    my $env = shift;
    if ($env->{REQUEST_METHOD} eq 'GET') {
        my $remote_host = '_';
        my $loop = $_CACHE->get($remote_host) || 0;
        if ($loop >= $flag_len) {
            $loop = 0;
        }
        my $fragment = substr $flag, $loop, 2;
        $loop += 2;
        $_CACHE->set($remote_host, $loop, 1);
        return [302, [Location => $env->{PATH_INFO}, 'X-Flag' => $fragment], []];
    } else {
        # trap :)
        return [302, [Location => $env->{PATH_INFO}], []];
    }
};

builder {
    enable 'Plack::Middleware::ReverseProxy';
    $app;
};
