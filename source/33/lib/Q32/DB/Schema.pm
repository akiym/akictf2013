package Q32::DB::Schema;
use strict;
use warnings;
use utf8;

use Teng::Schema::Declare;
use Q32::M::User;

base_row_class 'Q32::DB::Row';

table {
    name 'user';
    pk 'id';
    columns qw(id name password);
};

1;
