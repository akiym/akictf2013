package Problem6::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;
use FormValidator::Lite;

any '/' => sub {
    my ($c) = @_;
    return $c->render('index.tt');
};

post '/janken' => sub {
    my ($c) = @_;
    my $validator = FormValidator::Lite->new($c->req);
    $validator->check(
        h     => [qw/NOT_NULL/],
        money => [qw/NOT_NULL INT/],
    );
    if ($validator->has_error) {
        return $c->render_json({error => 1});
    }

    my $money = $c->req->param('money');
    unless ($c->gen_hash($money) eq $c->req->param('h')) {
        return $c->render_json({error => 1});
    }

    if ($money <= 1) {
        return $c->render_json({
            message => "Game over.",
            h       => $c->gen_hash(0),
            money   => 0,
        });
    }

    $money -= 1;

    return $c->render_json({
        message => "You lose... Rock, Paper, Scissors. 1 2 3!",
        h       => $c->gen_hash($money),
        money   => $money,
    });
};

post '/register' => sub {
    my ($c) = @_;
    my $validator = FormValidator::Lite->new($c->req);
    $validator->check(
        h     => [qw/NOT_NULL/],
        money => [qw/NOT_NULL INT/],
    );
    if ($validator->has_error) {
        return $c->render_json({error => 1});
    }

    my $money = $c->req->param('money');
    unless ($c->gen_hash($money) eq $c->req->param('h')) {
        return $c->render_json({error => 1});
    }

    if ($money > 1000000) {
        return $c->render_json({
            message => 'Congrats! The flag is "YIPPEE".',
        });
    } else {
        return $c->render_json({
            message => "Umm... You don't have enough money!",
        });
    }
};

1;
