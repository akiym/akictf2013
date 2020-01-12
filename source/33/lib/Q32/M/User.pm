package Q32::M::User;
use strict;
use warnings;
use feature qw/state/;
use Amon2::Declare;
use Data::Validator;
use Crypt::RC4;
use Log::Minimal;
use HTML::Entities;

sub gen_hashed_password {
    my ($class, $password) = @_;
    my $c = c();
    my $passphrase = $c->config->{passphrase}
        // die "Missing configuration: passphrase";
    return RC4($passphrase, $password);
}

sub insert {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name     => 'Str',
        password => 'Str',
    );
    my $args = $rule->validate(@_);

    return $c->db->fast_insert(user => {
        name     => $args->{name},
        password => $class->gen_hashed_password($args->{password}),
    });
}

sub retrieve {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        id => 'Int',
    )->with('StrictSequenced');
    my $args = $rule->validate(@_);

    return $c->db->single(user => {
        id => $args->{id},
    });
}

sub login {
    my $class = shift;
    my $c = c();
    state $rule = Data::Validator->new(
        name     => 'Str',
        password => 'Str',
    );
    my $args = $rule->validate(@_);

    my $password = $class->gen_hashed_password($args->{password});

    # XXX oops!
    my $itr = eval {
        $c->db->search_by_sql(
            "SELECT * FROM user WHERE name = ? AND password = '$password'",
            [$args->{name}],
        );
    };
    if ($@) {
        warnf("invalid sql: %s", encode_entities($password, "\200-\377"));
    }
    return $itr ? $itr->next : undef;
}

sub is_exist {
    my ($class, $name) = @_;
    my $c = c();
    my $user = $c->db->single(user => {
        name => $name,
    });
    return defined $user ? 1 : 0;
}

sub recent_users {
    my ($class) = @_;
    my $c = c();
    my $itr = $c->db->search_by_sql(
        q{
            SELECT * FROM
                (SELECT * FROM user ORDER BY id DESC LIMIT 4)
                UNION SELECT * FROM user WHERE id = 1 ORDER BY id DESC
        }
    );
    return $itr->all;
}

1;
