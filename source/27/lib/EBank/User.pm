package EBank::User;
use Mojo::Base 'Mojolicious::Controller';
use FormValidator::Lite;
use Time::Piece;

sub index {
    my $self = shift;

    my @registers = $self->db->search(user => {
        user_id => $self->user->user_id,
    });
    $self->stash->{registers} = \@registers;
}

sub bank_transfer_page {
    my $self = shift;
    return $self->render('user/bank_transfer');
}

sub bank_transfer {
    my $self = shift;
    my $user = $self->user;

    my $validator = FormValidator::Lite->new($self->req);
    $validator->check(
        to    => [
            qw/NOT_NULL ASCII/,
            [LENGTH => qw/1 14/],
            [MATCH => sub { $_[0] ne $user->username }],
        ],
        money => [
            qw/NOT_NULL/,
            [MATCH => sub { $_[0] =~ /^(?:[1-9]|[1-9][0-9]+)$/ && $_[0] > 0 }],
        ],
    );
    $validator->set_message(
        'to.not_null'    => 'transfer destination is required.',
        'to.ascii'       => 'username is invalid.',
        'to.length'      => 'username is too long.',
        'to.match'       => 'what are you doing?',
        'money.not_null' => 'amount is required.',
        'money.match'    => 'amount is invalid.',
    );
    if ($validator->has_error) {
        $self->stash->{error} = ($validator->get_error_messages)[0];
        return $self->render_fill('user/bank_transfer', $self->req->params);
    }

    my $money = $self->param('money');
    my $to = $self->param('to');

    my $txn = $self->db->txn_scope;
    my $to_user = $self->db->single(user => {username => $to});
    unless ($to_user) {
        $txn->rollback;
        $self->stash->{error} = "$to doesn't exist.";
        return $self->render_fill('user/bank_transfer', $self->req->params);
    }
    if ($user->money >= $money) {
        $user->update({
            money => $user->money - $money,
        });
        $to_user->update({
            money => $to_user->money + $money,
        });
        $self->db->insert_register($user->username, $to_user->username, $money);
    } else {
        $txn->rollback;
        $self->stash->{error} = 'there is not enough money.';
        return $self->render_fill('user/bank_transfer', $self->req->params);
    }
    $txn->commit;

    $self->stash->{message} = "transferred ¥$money to " . $to_user->username . '.';
    return $self->render('user/bank_transfer');
}

sub inquiry_page {
    my $self = shift;
    return $self->render('user/inquiry');
}

sub inquiry {
    my $self = shift;

    my $validator = FormValidator::Lite->new($self->req);
    $validator->check(
        # I forgot ASCII rule :P
        username    => [qw/NOT_NULL/, [LENGTH => qw/1 14/]],
        screen_name => [qw/NOT_NULL/, [LENGTH => qw/1 25/]],
    );
    if ($validator->has_error) {
        return $self->render(json => []);
    }

    my $username = $self->param('username');
    my $screen_name = $self->param('screen_name');

    # "SELECT username, last_login FROM user WHERE username = ''union select' OR last_login >= ',sql from sqlite_master"
    # => username='union select&money=,sql from sqlite_master--
    # => username='union select&money=',ident_qq9ed7 from user
    # => username='union select&money=',last_login from user

    # ?username='union%20select&screen_name=,sql%20from%20sqlite_master--

    # XXX SQLi
    my $itr = $self->db->search_by_sql(
        "SELECT screen_name, money FROM user WHERE username = '$username' AND screen_name = '$screen_name' LIMIT 1"
    );
    $itr->suppress_object_creation(1);
    return $self->render(json => [$itr->all]);
}

sub search_page {
    my $self = shift;
    return $self->render('user/search');
}

sub search {
    my $self = shift;

    my $validator = FormValidator::Lite->new($self->req);
    $validator->check(
        username => [qw/NOT_NULL ASCII/, [LENGTH => qw/1 14/]],
    );
    if ($validator->has_error) {
        return $self->render(json => []);
    }

    my $username = $self->param('username');

    # it's dirty :)
    $username = "%$username%";

    # XXX username: '%'
    my $itr = $self->db->search('user',
        {
            username => {LIKE => $username},
        },
        {
            order_by => 'username',
            column   => [qw/username last_login/],
        }
    );
    $itr->suppress_object_creation(1);
    my @users = $itr->all;
    for my $user (@users) {
        $user->{last_login}
            = localtime($user->{last_login})->strftime('%Y/%m/%d %H:%M:%S');
    }
    return $self->render(json => [@users]);
}

sub history {
    my $self = shift;
    return $self->render('user/history',
        registers => $self->user->search_registers(),
    );
}

1;
