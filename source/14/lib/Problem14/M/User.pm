package Problem14::M::User;
use strict;
use warnings;
use feature qw/state/;
use utf8;
use Amon2::Declare;
use Data::Validator;
use Time::Piece ();

sub retrieve {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name => 'Str',
    );
    my $args = $rule->validate(@_);

    my $user = $c->dbh->selectrow_hashref(
        q{SELECT user_id, name, password, last_login FROM user WHERE name = ?},
        undef,
        $args->{name}
    );
    return undef unless $user;
    return $class->_inflate_row($user);
}

sub _inflate_row {
    my ($class, $user) = @_;
    $user->{last_login} = Time::Piece->new($user->{last_login})->cdate;
    return $user;
}

sub register {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name     => 'Str',
        password => 'Str',
    );
    my $args = $rule->validate(@_);

    $class->_insert(
        %$args,
        last_login => time(),
    );
    return $class->retrieve(name => $args->{name});
}

sub _insert {
    my ($class, %args) = @_;
    my $c = c();
    $c->dbh->insert('user' => \%args);
}

sub login {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name     => 'Str',
        password => 'Str',
    );
    my $args = $rule->validate(@_);

    my $retval = $c->dbh->selectrow_hashref(
        q{SELECT 1 FROM user WHERE name = ? AND password = ?},
        undef,
        $args->{name}, $args->{password}
    );
    return undef unless $retval;
    return $class->retrieve(name => $args->{name});
}

sub update_timestamp {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name => 'Str',
    );
    my $args = $rule->validate(@_);

    $c->dbh->do_i(
        q{UPDATE user SET}, {
            last_login => time(),
        }, q{ WHERE name =}, \$args->{name}
    );
}

sub search_recent_users {
    my $class = shift;
    my $c = c();

    my $users = $c->dbh->selectall_arrayref(
        q{SELECT user_id, name, password, last_login FROM user ORDER BY user_id LIMIT 3},
        {Slice => {}}
    );
    return [] unless @$users;
    for (@$users) {
        $_->{password} =~ s/./*/g;
        $class->_inflate_row($_);
    }
    return $users;
}

1;

