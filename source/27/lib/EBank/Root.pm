package EBank::Root;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;

sub index {
    my $self = shift;
    if ($self->db->user) {
        $self->stash->{registers} = $self->db->registers();
    } else {
        $self->stash->{registers} = $self->db->recent_registers();
        $self->stash->{user_num} = $self->db->count('user');
    }
    return $self->render('root/index');
}

sub signup_page {
    my $self = shift;
    return $self->redirect_to('/') if $self->user;
    return $self->render('root/signup');
}

sub signup {
    my $self = shift;
    my $validator = FormValidator::Lite->new($self->req);
    $validator->check(
        username    => [qw/NOT_NULL ASCII/, [LENGTH => qw/1 14/]],
        screen_name => [qw/NOT_NULL/, [LENGTH => qw/1 25/]],
        password    => [qw/NOT_NULL ASCII/, [LENGTH => qw/1 32/]],
    );
    $validator->set_message(
        'username.not_null'    => 'username is required.',
        'username.ascii'       => 'username is invalid.',
        'username.length'      => 'username is too long.',
        'screen_name.not_null' => 'full name is required.',
        'screen_name.length'   => 'full name is too long.',
        'password.not_null'    => 'password is required.',
        'password.ascii'       => 'password is invalid.',
        'password.length'      => 'password is too long.',
    );
    if ($validator->has_error) {
        $self->stash->{error} = ($validator->get_error_messages)[0];
        return $self->render_fill('root/signup', $self->req->params);
    }

    my $username = $self->param('username');

    if ($self->db->single(user => {username => $username})) {
        $self->stash->{error} = "$username is already taken.",
        return $self->render_fill('root/signup', $self->req->params);
    } else {
        my ($user_id, $ident) = $self->db->signup(
            $username,
            $self->param('screen_name'),
            $self->param('password'),
        );
        $self->session->{user_id} = $user_id;
        $self->session->{ident} = $ident;
        return $self->redirect_to('/');
    }
}

sub login_page {
    my $self = shift;
    return $self->redirect_to('/') if $self->user;
    return $self->render('root/login');
}

sub login {
    my $self = shift;
    my $validator = FormValidator::Lite->new($self->req);
    $validator->check(
        username => [qw/NOT_NULL ASCII/, [LENGTH => qw/1 14/]],
        password => [qw/NOT_NULL ASCII/, [LENGTH => qw/1 32/]],
    );
    $validator->set_message(
        'username.not_null'    => 'username is required.',
        'username.ascii'       => 'username is invalid.',
        'username.length'      => 'username is too long.',
        'password.not_null'    => 'password is required.',
        'password.ascii'       => 'password is invalid.',
        'password.length'      => 'password is too long.',
    );
    if ($validator->has_error) {
        $self->stash->{error} = ($validator->get_error_messages)[0];
        return $self->render_fill('root/login', $self->req->params);
    }

    my $username = $self->param('username');
    my $password = $self->param('password');

    my $user = $self->db->login($username, $password);
    if ($user) {
        $self->session->{user_id} = $user->user_id;
        $self->session->{ident} = $user->ident;
        return $self->redirect_to('/');
    } else {
        $self->stash->{error} = "sorry, please try again.";
        return $self->render_fill('root/login', $self->req->params);
    }
}

sub logout {
    my $self = shift;
    $self->session(expires => 1);
    return $self->redirect_to('/');
}

1;
