package Q33::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Log::Minimal;

get '/' => sub {
    my ($c) = @_;
    return $c->render('index.tx');
};

post '/' => sub {
    my ($c) = @_;
    my $id = $c->req->param('id') // die 'missing id';
    infof("%s", ddf($c->req->parameters->as_hashref));
    unless ($id =~ /^[0-9]+$/m) {
        return $c->render('index.tx');
    }

    my ($body) = $c->dbh->selectrow_array(
        "SELECT body FROM message WHERE id = $id"
    );

    return $c->render('index.tx' => {
        body => $body,
        flag => ($body && $body eq '700_51mpl3'),
    });
};

1;
