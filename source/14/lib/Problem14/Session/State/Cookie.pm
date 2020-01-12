package Problem14::Session::State::Cookie;
use strict;
use HTTP::Session::State::Base;
use Carp ();
use Scalar::Util ();

our $COOKIE_CLASS = 'CGI::Cookie';

__PACKAGE__->mk_accessors(qw/name path domain expires secure/);

{
    my $required = 0;
    sub _cookie_class {
        my $class = shift;
        unless ($required) {
            (my $klass = $COOKIE_CLASS) =~ s!::!/!g;
            $klass .= ".pm";
            require $klass;
            $required++;
        }
        return $COOKIE_CLASS
    }
}

sub new {
    my $class = shift;
    my %args = ref($_[0]) ? %{$_[0]} : @_;
    # set default values
    $args{name} ||= 'http_session_sid';
    $args{path} ||= '/';
    bless {%args}, $class;
}

sub get_session_id {
    my ($self, $req) = @_;

    my $cookie_header = $ENV{HTTP_COOKIE} || (Scalar::Util::blessed($req) ? $req->header('Cookie') : $req->{HTTP_COOKIE});
    return unless $cookie_header;

    my %jar    = _cookie_class()->parse($cookie_header);
    my $cookie = $jar{$self->name};
    return $cookie ? $cookie->value : undef;
}

sub response_filter {
    my ($self, $session_id, $res) = @_;
    Carp::croak "missing session_id" unless $session_id;

    $self->header_filter($session_id, $res);
}

sub header_filter {
    my ($self, $session_id, $res) = @_;
    Carp::croak "missing session_id" unless $session_id;

    my $cookie = _cookie_class()->new(
        sub {
            my %options = (
                -name   => $self->name,
                -value  => $session_id,
                -path   => $self->path,
            );
            $options{'-domain'} = $self->domain if $self->domain;
            $options{'-expires'} = $self->expires if $self->expires;
            $options{'-secure'} = $self->secure if $self->secure;
            %options;
        }->()
    );
    if (Scalar::Util::blessed($res)) {
        $res->header( 'Set-Cookie' => $cookie->as_string );
        $res;
    } else {
        push @{$res->[1]}, 'Set-Cookie' => $cookie->as_string;
        $res;
    }
}

1;
