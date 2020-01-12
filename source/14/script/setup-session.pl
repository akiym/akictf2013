use strict;
use warnings;
use File::Spec;
use File::Basename;
use lib File::Spec->catdir(dirname(__FILE__), '../lib');

use Problem14;
use Problem14::M::User;
use Digest::MD5 ();

my $c = Problem14->bootstrap();
$c->setup_schema();

my $_TIMESTAMP; # for generate session id

# monkey patch!!
use HTTP::Session;
{
    no warnings 'redefine';
    *HTTP::Session::new = sub {
        my $class = shift;
        my %args = ref($_[0]) ? %{$_[0]} : @_;
        # check required parameters
        for my $key (qw/store/) { # state request
            Carp::croak "missing parameter $key" unless $args{$key};
        }
        # set default values
        $args{_data} ||= {};
        $args{save_modified_session_only} ||= 0;
        $args{is_changed} ||= 0;
        $args{is_fresh}   ||= 0;
        $args{sid_length} ||= 32;
        $args{id}         ||= 'HTTP::Session::ID::SHA1';
        my $self = bless {%args}, $class;

        #$self->_load_session();
        my $session_id = substr(Digest::MD5::md5_hex($_TIMESTAMP), 0, $args{sid_length});
        $self->session_id($session_id);
        warn "session: [$_TIMESTAMP] $session_id\n";
        $self->is_fresh(1);

        #Carp::croak "[BUG] we have bug" unless $self->{request};
        $self;
    }
}

Problem14::M::User->_insert(
    name       => 'foo',
    password   => 'hogee',
    last_login => 1319234893,
);
$_TIMESTAMP = 1319234893;
my $session1 = HTTP::Session->new(
    store => HTTP::Session::Store::File->new(
        dir => '/home/ctfq/ctfq14/q14-session',
    ),
    state => HTTP::Session::State::Cookie->new(
        name => 'q14',
    ),
);
$session1->set(name => 'foo');
$session1->finalize;

Problem14::M::User->_insert(
    name       => 'bar',
    password   => 'fuga',
    last_login => 1265926862,
);
$_TIMESTAMP = 1265926862;
my $session2 = HTTP::Session->new(
    store => HTTP::Session::Store::File->new(
        dir => '/home/ctfq/ctfq14/q14-session',
    ),
    state => HTTP::Session::State::Cookie->new(
        name => 'q14',
    ),
);
$session2->set(name => 'bar');
$session2->finalize;

Problem14::M::User->_insert(
    name       => 'baz',
    password   => 'piyopiyopiyo',
    last_login => 1365238423,
);
$_TIMESTAMP = 1365238423;
my $session3 = HTTP::Session->new(
    store => HTTP::Session::Store::File->new(
        dir => '/home/ctfq/ctfq14/q14-session',
    ),
    state => HTTP::Session::State::Cookie->new(
        name => 'q14',
    ),
);
$session3->set(name => 'baz');
$session3->finalize;
