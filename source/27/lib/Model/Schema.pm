package Model::Schema;
use strict;
use warnings;
use Teng::Schema::Declare;

table {
    name 'user';
    pk 'user_id';
    columns (
        'user_id',
        'username',
        'screen_name',
        'password',
        'ident_qq9ed7',
        'money',
        'last_login',
    );
};

table {
    name 'e_bank_account_register__';
    pk 'register_id';
    columns (
        'register_id',
        'from_user',
        'to_user',
        'from_money',
        'to_money',
    );
    row_class 'Model::Row::EBankAccountRegister';
};

1;
