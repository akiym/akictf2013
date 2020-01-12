package Problem14::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::Lite;
use FormValidator::Lite;
use Log::Minimal;

use Problem14::M::User;

any '/' => sub {
    my ($c) = @_;

    my $session_id = $c->req->cookies->{q14};
    if ($session_id && length($session_id) != 32) {
        warnf('someone noticed!');
        return $c->render('error.tt' => {
            message => 'Hint: substr(Digest::MD5::md5_hex($_), 0, 32)',
        });
    }

    my $user;
    if (defined(my $name = $c->session->get('name'))) {
        infof('logging in: %s', $name);
        $user = Problem14::M::User->retrieve(name => $name);
    }
    return $c->render('index.tt' => {
        user         => $user,
        recent_users => Problem14::M::User->search_recent_users(),
    });
};

post '/account/new' => sub {
    my ($c) = @_;
    my $validator = FormValidator::Lite->new($c->req);
    $validator->check(
        name     => [qw/NOT_NULL/, [LENGTH => qw/1 10/]],
        password => [qw/NOT_NULL/, [LENGTH => qw/1 255/]],
    );
    $validator->set_message(
        'name.not_null'     => 'what your name?',
        'name.length'       => 'name <= 10',
        'password.not_null' => 'password is required!',
        'password.length'   => 'password <= 255',
    );
    if ($validator->has_error) {
        return $c->render('error.tt' => {
            message => ($validator->get_error_messages())[0],
        });
    }

    my $name = $c->req->param('name');
    my $password = $c->req->param('password');
    if (Problem14::M::User->retrieve(name => $name)) {
        warnf('duplicate user: %s (password: %s)', $name, $password);
        return $c->render('error.tt' => {
            message => "'$name' is already taken.",
        });
    }

    infof('create new user: %s:%s', $name, $password);
    my $user = Problem14::M::User->register(
        name     => $name,
        password => $password,
    );

    my $session = $c->session();
    $session->set(name => $name);

    my $res = $c->redirect('/');
    $session->response_filter($res);
    $session->finalize();
    return $res;
};

post '/account/login' => sub {
    my ($c) = @_;
    my $validator = FormValidator::Lite->new($c->req);
    $validator->check(
        name     => [qw/NOT_NULL/, [LENGTH => qw/1 10/]],
        password => [qw/NOT_NULL/, [LENGTH => qw/1 255/]],
    );
    $validator->set_message(
        'name.not_null'     => 'what your name?',
        'name.length'       => 'name <= 10',
        'password.not_null' => 'password is required!',
        'password.length'   => 'password <= 255',
    );
    if ($validator->has_error) {
        return $c->render('error.tt' => {
            message => ($validator->get_error_messages())[0],
        });
    }

    my $name = $c->req->param('name');
    my $password = $c->req->param('password');
    my $user = Problem14::M::User->login(
        name     => $name,
        password => $password,
    );
    if ($user) {
        infof('login success: %s', $name);
        my $session = $c->session();
        Problem14::M::User->update_timestamp(name => $name);
        $session->regenerate_session_id;
        $session->set(name => $name);

        my $res = $c->redirect('/');
        $session->response_filter($res);
        $session->finalize();
        return $res;
    } else {
        warnf('login failed: %s:%s', $name, $password);
        return $c->render('error.tt' => {
            message => 'login failed.',
        });
    }
};

1;
