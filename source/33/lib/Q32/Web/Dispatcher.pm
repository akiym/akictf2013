package Q32::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use FormValidator::Lite;
use Log::Minimal;

use Q32::M::User;

get '/' => sub {
    my ($c) = @_;
    return $c->render('index.tx' => {
        user  => $c->user,
        users => [Q32::M::User->recent_users],
    });
};

post '/' => sub {
    my ($c) = @_;

    infof("login: %s", ddf($c->req->parameters->as_hashref));

    my $validator = FormValidator::Lite->new($c->req);
    $validator->check(
        name     => [qw/ASCII/, [LENGTH => 1, 32]],
        password => [qw/ASCII/, [LENGTH => 1, 32]],
    );
    my $is_error = 0;
    if ($validator->has_error) {
        $is_error = 1;
    } else {
        my $user = Q32::M::User->login($c->req->parameters->as_hashref);
        if (defined $user) {
            $c->session->set(id => $user->id);
        } else {
            $is_error = 1;
        }
    }
    if ($is_error) {
        return $c->render('index.tx' => {
            user    => $c->user,
            users   => [Q32::M::User->recent_users],
            message => 'login failed.',
        });
    }

    return $c->redirect('/');
};

get '/logout' => sub {
    my ($c) = @_;
    $c->session->expire();
    return $c->redirect('/');
};

get '/register' => sub {
    my ($c) = @_;
    return $c->render('register.tx');
};

post '/register' => sub {
    my ($c) = @_;

    infof("register: %s", ddf($c->req->parameters->as_hashref));

    my $validator = FormValidator::Lite->new($c->req);
    $validator->check(
        name     => [qw/NOT_NULL ASCII/, [LENGTH => 1, 32]],
        password => [qw/NOT_NULL ASCII/, [LENGTH => 1, 32]],
    );
    $validator->set_message_data({
        message => {
        },
        param => {
            name     => 'name',
            password => 'password',
        },
        function => {
            not_null => '[_1] is empty.',
            ascii    => 'use only ascii in [_1].',
            length   => '[_1] is too long.',
        },
    });
    my @messages;
    if ($validator->has_error) {
        push @messages, $validator->get_error_messages;
    }
    if ((not exists $validator->errors->{name})
        && Q32::M::User->is_exist($c->req->param('name'))) {
        # nameの重複チェックを最優先する
        unshift @messages, 'sorry, this name is already taken.';
    }
    if (@messages) {
        $c->fillin_form($c->req);
        return $c->render('register.tx' => {
            message => $messages[0],
        });
    }

    my $user_id = Q32::M::User->insert($c->req->parameters->as_hashref);
    $c->session->set(id => $user_id);

    return $c->redirect('/');
};

1;
