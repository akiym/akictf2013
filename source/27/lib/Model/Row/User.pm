package Model::Row::User;
use strict;
use warnings;
use utf8;
use parent qw/Teng::Row/;

sub ident {
    my $self = shift;
    return $self->get_column('ident_qq9ed7');
}

sub transfer {
    my ($self, $to, $money) = @_;

    my $txn = $self->handle->txn_scope;

    my $from_user = $self->refetch;
    my $to_user = $self->handle->single(user => {username => $to});

    if ($to_user && $from_user->money >= $money) {
        $from_user->update({
            money => $from_user->money - $money,
        });
        $to_user->update({
            money => $to_user->money + $money,
        });
        $self->handle->insert_register(
            $from_user->username, $to_user->username, $money
        );
        $txn->commit;
        return 1;
    } else {
        $txn->rollback;
        return 0;
    }
}

sub search_registers {
    my $self = shift;
    my $username = $self->get_column('username');
    my @registers = $self->handle->search_by_sql(
        q{SELECT from_user, to_user, money FROM e_bank_account_register__ WHERE from_user = ? OR to_user = ? ORDER BY register_id DESC},
        [$username, $username]
    );
    return \@registers;
}

1;
