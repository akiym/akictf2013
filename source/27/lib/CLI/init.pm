package CLI::init;
use Mojo::Base 'Mojolicious::Command';

use List::Util qw/shuffle/;
use Helper;

has description => "Set up.\n";
has usage       => "usage: $0 init\n";

sub run {
    my $self = shift;

    my $password = Helper->_random_string(32, [map chr, 0x21 .. 0x7e]);
    $password = Helper->gen_hashed_password('john', $password);
    $self->app->db->fast_insert(user => {
        user_id      => 34,
        username     => 'john',
        screen_name  => 'John Doe',
        password     => $password,
        ident_qq9ed7 => Helper->gen_ident(34, 'John Doe'),
        money        => '294307500', # XXX This is flag
        last_login   => '809222701',
    });

    $self->create_dummy_user;
    $self->record_initial_money;
    $self->create_dummy_register;
}

sub record_initial_money {
    my $self = shift;
    my $db = $self->app->db;
    my @rows;
    my @users = $db->search(user => {});
    for my $user (@users) {
        push @rows, {
            from_user => $user->username,
            money     => $user->money,
        };
    }
    $db->bulk_insert('e_bank_account_register__', \@rows);
}

sub create_dummy_user {
    my $self = shift;
    my @names = (
        [1, 'launcelot', 'Launcelot Kiernan'],
        [2, 'annabel', 'Annabel Head'],
        [3, 'jacquelyn', 'Jacquelyn Herne'],
        [4, 'dorothea', 'Dorothea Linton'],
        [5, 'una', 'Una Nuckey'],
        [6, 'zenobia', 'Zenobia Chichester'],
        [7, 'daphne', 'Daphne Crosby'],
        [8, 'philene', 'Philene Rooke'],
        [9, 'bret', 'Bret Felton'],
        [10, 'emily', 'Emily Carse'],
        [11, 'randal', 'Randal Harris'],
        [12, 'les', 'Les Molina'],
        [13, 'magdalen', 'Magdalen Asquith'],
        [14, 'rick', 'Rick Roche'],
        [15, 'cary', 'Cary McKintosh'],
        [16, 'hick', 'Hick Baxter'],
        [17, 'alethea', 'Alethea Parmar'],
        [18, 'enoch', 'Enoch Ahl'],
        [19, 'hariet', 'Hariet Fitzgerald'],
        [20, 'arlene', 'Arlene Sheridan'],
        [21, 'shirley', 'Shirley McCormick'],
        [22, 'rutland', 'Rutland Nicol'],
        [23, 'abra', 'Abra Dumfries'],
        [24, 'arthur', 'Arthur Hoddle'],
        [25, 'etty', 'Etty Grieve'],
        [26, 'maudie', 'Maudie Chaucer'],
        [27, 'elliza', 'Elliza Hilton'],
        [28, 'lizbeth', 'Lizbeth Hodge'],
        [29, 'noel', 'Noel Burberry'],
        [30, 'eliphalet', 'Eliphalet Roseingrave'],
        [31, 'hector', 'Hector Geeson'],
        [32, 'adonis', 'Adonis Spies'],
        [33, 'trixie', 'Trixie Joyce'],
        #[34, 'lucretius', 'Lucretius Middleton'],
        [35, 'nina', 'Nina Alderton'],
        [36, 'pollyanna', 'Pollyanna Merchant'],
        [37, 'sarah', 'Sarah Balcon'],
        [38, 'hamish', 'Hamish Kincaid'],
        [39, 'johanna', 'Johanna Akiwande'],
        [40, 'joseph', 'Joseph Cowen'],
        [41, 'fabius', 'Fabius Percy'],
        [42, 'margot', 'Margot Coleman'],
        [43, 'roma', 'Roma Bambridge'],
        [44, 'geoff', 'Geoff Beckham'],
        [45, 'dunstan', 'Dunstan Boon'],
        [46, 'della', 'Della McCall'],
        [47, 'jackie', 'Jackie Colet'],
        [48, 'zak', 'Zak Galica'],
        [49, 'russel', 'Russel Finck'],
        [50, 'dob', 'Dob Rankl'],
        [51, 'addy', 'Addy Reed'],
        [52, 'fip', 'Fip Fritche'],
        [53, 'betty', 'Betty Roth'],
        [54, 'rupert', 'Rupert House'],
        [55, 'luanna', 'Luanna Emerson'],
        [56, 'luisa', 'Luisa Furnivall'],
        [57, 'dennis', 'Dennis Morley'],
        [58, 'annie', 'Annie Audubon'],
        [59, 'aylmer', 'Aylmer Presley'],
        [60, 'kiefer', 'Kiefer Delgado'],
        [61, 'micki', 'Micki Sotherton'],
        [62, 'vyvyan', 'Vyvyan McGuire'],
        [63, 'xanthippe', 'Xanthippe Berti'],
        [64, 'wolfgang', 'Wolfgang Allport'],
        [65, 'marguerite', 'Marguerite Salzedo'],
        [66, 'lily', 'Lily McCann'],
        [67, 'intyre', 'Intyre Malone'],
        [68, 'isobel', 'Isobel Linacre'],
        [69, 'granville', 'Granville Bessemer'],
        [70, 'freddy', 'Freddy Ahl'],
        [71, 'nix', 'Nix Helson'],
        [72, 'lazarus', 'Lazarus Kellogg'],
        [73, 'althea', 'Althea Flynn'],
        [74, 'milton', 'Milton Clare'],
        [75, 'angelica', 'Angelica Hillton'],
        [76, 'anastsius', 'Anastsius Blackburn'],
        [77, 'leroy', 'Leroy Gay'],
        [78, 'hazel', 'Hazel Savale'],
        [79, 'kathleen', 'Kathleen Finley'],
        [80, 'ira', 'Ira Scholes'],
        [81, 'sam', 'Sam Daniel'],
        [82, 'abbie', 'Abbie Rowling'],
        [83, 'beryl', 'Beryl Elford'],
        [84, 'berhard', 'Berhard Jenkinson'],
        [85, 'linda', 'Linda Bowyer'],
        [86, 'julius', 'Julius Foulds'],
        [87, 'dinah', 'Dinah Else'],
        [88, 'davy', 'Davy Addinsell'],
        [89, 'gillian', 'Gillian Bastholm'],
        [90, 'carol', 'Carol Fuchs'],
        [91, 'jehu', 'Jehu Gethin'],
        [92, 'fay', 'Fay Allingham'],
        [93, 'jenifer', 'Jenifer Kroto'],
        [94, 'maisie', 'Maisie Soper'],
        [95, 'maurice', 'Maurice McFall'],
        [96, 'kieron', 'Kieron Piper'],
        [97, 'lia', 'Lia McClair'],
        [98, 'paul', 'Paul Akiwande'],
        [99, 'frances', 'Frances Granger'],
        [100, 'finlay', 'Finlay Roth'],
    );
    my @rows;
    for my $name (@names) {
        my $password = Helper->_random_string(32, [map chr, 0x21 .. 0x7e]);
        $password = Helper->gen_hashed_password($name->[1], $password);
        push @rows, {
            user_id      => $name->[0],
            username     => $name->[1],
            screen_name  => $name->[2],
            password     => $password,
            ident_qq9ed7 => Helper->gen_ident($name->[0], $name->[2]),
            money        => 100000 + int rand 100000,
            last_login   => time() - int rand 100000,
        };
    }
    $self->app->db->bulk_insert('user', \@rows);
}

sub create_dummy_register {
    my $self = shift;
    my $db = $self->app->db;
    my @rows;
    my @times = (1..100, 1..100, 1..100, 1..100, 1..100); # 5 times / user
    @times = shuffle @times;
    for my $user_id (@times) {
        my $user = $db->single('user' => {user_id => $user_id});
        my $rand_id = int(rand 100) + 1;
        my $to_user = $db->single('user' => {user_id => $rand_id});
        $user->transfer($to_user->username, int rand 50000);
    }
}

1;
