package Q32;
use strict;
use warnings;
use utf8;
our $VERSION='0.01';
use 5.008001;
use Q32::DB::Schema;
use Q32::DB;

use parent qw/Amon2/;

my $schema = Q32::DB::Schema->instance;

sub db {
    my $c = shift;
    if (!exists $c->{db}) {
        my $conf = $c->config->{DBI}
            or die "Missing configuration about DBI";
        $c->{db} = Q32::DB->new(
            schema       => $schema,
            connect_info => [@$conf],
            # I suggest to enable following lines if you are using mysql.
            # on_connect_do => [
            #     'SET SESSION sql_mode=STRICT_TRANS_TABLES;',
            # ],
        );
    }
    $c->{db};
}

use Q32::M::User;
sub user {
    my $c = shift;
    my $id = $c->session->get('id');
    return undef unless defined $id;
    return Q32::M::User->retrieve($id);
}

1;
__END__

=head1 NAME

Q32 - Q32

=head1 DESCRIPTION

This is a main context class for Q32

=head1 AUTHOR

Q32 authors.

