package Q34::M::Host;
use strict;
use warnings;
use utf8;
use Amon2::Declare;
use Log::Minimal;

sub new {
    my ($class, $address) = @_;
    return bless \$address, $class;
}

sub captcha {
    my ($self, $id, $key) = @_;
    my $i = $self->get_id();
    my $k = $self->get_key();
    infof('%s: id:%s => "%s", key:%s => "%s"', $$self, $i, $id, $k, $key);
    return ($i && $i eq $id) && ($k && $k eq $key);
}

sub count {
    my $self = shift;
    my $c = c();
    my $count = $c->memd->get("host:$$self:count");
    unless (defined $count) {
        $count = 0;
        $self->reset_count;
    }
    debugf('%s: count => %d', $$self, $count);
    return $count;
}

sub incr_count {
    my $self = shift;
    my $c = c();
    my $count = $c->memd->incr("host:$$self:count");
    infof('%s: %d times', $$self, $count);
    return $count;
}

sub reset_count {
    my $self = shift;
    my $c = c();
    $c->memd->set("host:$$self:count", 0);
}

sub next_id {
    my ($self, $timeout) = @_;
    my $c = c();

    $self->reset_count if !$self->has_next || not defined $self->get_id();

    # XXX Do not return the same id.
    $self->end;

    my $id = $self->gen_captcha_id();
    $c->memd->set_multi(
        ["host:$$self:id", $id, $timeout + 1],
        ["host:$$self:key", $self->gen_captcha_key(), $timeout + 1],
    );
    return $id;
}

sub get_id {
    my $self = shift;
    my $c = c();
    return $c->memd->get("host:$$self:id");
}

sub get_key {
    my $self = shift;
    my $c = c();
    return $c->memd->get("host:$$self:key");
}

sub has_next {
    my $self = shift;
    my $c = c();
    return $c->memd->get("host:$$self:next");
}

sub next {
    my $self = shift;
    my $c = c();
    debugf('%s: next', $$self);
    $c->memd->set("host:$$self:next", 1);
}

sub end {
    my $self = shift;
    my $c = c();
    debugf('%s: end', $$self);
    $c->memd->delete("host:$$self:next");
}

sub gen_captcha_id {
    my $self = shift;
    return $self->_random_string(32);
}

sub gen_captcha_key {
    my $self = shift;
    return $self->_random_string(16);
}

sub _random_string {
    my ($self, $len) = @_;
    my @chars = ('a'..'f', '0'..'9');
    my $ret;
    for (1 .. $len) {
        $ret .= $chars[int rand @chars];
    }
    return $ret;
}

1;
