package Model;
use strict;
use warnings;
use parent qw/Teng/;
use Helper;

__PACKAGE__->load_plugin(qw/Count/);

sub setup_schema {
    #my $self = shift;
    #open my $fh, '<:encoding(utf-8)', 'sql/sqlite.sql' or die $!;
    #my $src = do { local $/; <$fh> };
    #for my $stmt (split /;/, $src) {
    #    next unless $stmt =~ /\S/;
    #    $self->do($stmt);
    #}
}

sub user {
    my ($self, $user_id) = @_;
    return undef unless $user_id;
    return $self->single('user', {user_id => $user_id});
}

sub signup {
    my ($self, $username, $screen_name, $password) = @_;
    $password = Helper->gen_hashed_password($username, $password);
    my $txn = $self->txn_scope;
    my $user_num = $self->count('user') + 1;
    my $ident = Helper->gen_ident($user_num, $screen_name);
    my $user_id = $self->fast_insert(user => {
        username     => $username,
        screen_name  => $screen_name,
        password     => $password,
        ident_qq9ed7 => $ident,
        money        => 100000,
        last_login   => time(),
    });
    $self->fast_insert(e_bank_account_register__ => {
        from_user => $username,
        money     => 100000,
    });
    $txn->commit;
    return ($user_id, $ident);
}

sub login {
    my ($self, $username, $password) = @_;
    $password = Helper->gen_hashed_password($username, $password);
    my $user = $self->single(user => {
        username => $username,
        password => $password,
    });
    return unless $user;
    $user->update({last_login => time()});
    return $user;
}

sub recent_registers {
    my $self = shift;
    my @registers = $self->search('e_bank_account_register__',
        {},
        {
            order_by => {register_id => 'DESC'},
            limit    => 10,
        }
    );
    return \@registers;
}

sub insert_register {
    my ($self, $from, $to, $money) = @_;
    $self->insert('e_bank_account_register__' => {
        from_user => $from,
        to_user   => $to,
        money     => $money
    });
}

1;
