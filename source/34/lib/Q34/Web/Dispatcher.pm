package Q34::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;

use Q34::CaptchaGenerator;
use Q34::M::Host;

get '/' => sub {
    my ($c) = @_;
    my $host = Q34::M::Host->new($c->req->address);
    my $count = $host->count();
    my $timeout = $count < 5 ? 10 : 3;
    return $c->render('index.tx', {
        captcha_id => $host->next_id($timeout),
        count      => $host->count(), # refetch
        timeout    => $timeout,
    });
};

# XXX Oops! It has vulnerability. You can access the image several times.
get '/challenge/{id:[a-f0-9]{32}}.png' => sub {
    my ($c, $args) = @_;

    my $host = Q34::M::Host->new($c->req->address);

    if ($host->count == 10) {
        return $c->create_response(
            200,
            ['Content-Type' => 'image/png'],
            Q34::CaptchaGenerator->gen('CcaaAPpTTTCccHhA')
        );
    }

    my $id = $host->get_id();
    if ($id && $id eq $args->{id}) {
        my $key = $host->get_key();
        return $c->create_response(
            200,
            ['Content-Type' => 'image/png'],
            Q34::CaptchaGenerator->gen($key)
        );
    } else {
        return $c->res_404();
    }
};

post '/challenge' => sub {
    my $c = shift;
    my $id = $c->req->param('id') // die 'missing id';
    my $key = $c->req->param('key') // die 'missing key';

    my $host = Q34::M::Host->new($c->req->address);

    if ($host->count == 10) {
        return $c->render_text('Your challenge is over :)');
    }

    my $ok = $host->captcha($id, $key);
    if ($ok) {
        $host->incr_count;
        $host->next;
        return $c->redirect('/');
    } else {
        $host->reset_count;
        $host->end;
        return $c->redirect('/');
    }
};

1;
