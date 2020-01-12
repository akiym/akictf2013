package Q23::Server;
use 5.008005;
use strict;
use warnings;
use parent qw/Net::Server::PreFork/;
use Data::Dumper;
use POSIX::AtFork;

POSIX::AtFork->add_to_child(sub { srand });

use constant DEBUG        => $ENV{Q23_DEBUG} || 0;
use constant CHUNKSIZE    => 64 * 1024;
use constant READ_TIMEOUT => 5;

our $VERSION = "0.01";

our ($PROBLEM, $PROBLEM_NUM);

# Most of code taken from Starman::Server

sub process_request {
    my $self = shift;
    my $conn = $self->{server}->{client};

    my $peeraddr = $self->{server}->{peeraddr};
    my $peerport = $self->{server}->{peerport};

    my $problem_num = int rand $PROBLEM_NUM;
    warn "$peeraddr:$peerport connected [$problem_num]\n";
    my $problem = $PROBLEM->[$problem_num];
    my $count = 0;
    my ($statement, $answer) = @{$problem->[$count]};

    syswrite $conn, <<'...';
    ____  ______________  ____  __________
   / __ \/  _/ ____/ __ \/ __ \/ ___/ ___/
  / /_/ // // /   / /_/ / / / /\__ \\__ \ 
 / ____// // /___/ _, _/ /_/ /___/ /__/ / 
/_/   /___/\____/_/ |_|\____//____/____/  

...

    my $picross = $self->_gen_picross_map();
    while (1) {
        syswrite $conn, $statement;

        last if !$conn->connected;
        last if !$self->_read;

        my ($x, $y) = eval { $self->_parse_and_pick($picross) };
        if ($@) {
            if ($@ =~ /Format error/) {
                syswrite $conn, "format: [0-9]{1,2}\\s[0-9]{1,2}\n";
            } elsif ($@ =~ /Out of range/) {
                syswrite $conn, "0..18\n";
            } elsif ($@ =~ /Picked/) {
                syswrite $conn, "picked.\n";
            }
            last;
        }

        $statement = $self->_pick_statement($x, $y, $statement);

        if ($self->_check_correct($picross, $answer)) {
            $count++;
            warn "$peeraddr:$peerport was correct $count times\n";
            if ($count == 9) {
                # end of game
                syswrite $conn, "Correct! You've done all problems!\n";
                last;
            } else {
                syswrite $conn, "Correct! Let's challenge next problem:\n";
                ($statement, $answer) = @{$problem->[$count]};
                $picross = $self->_gen_picross_map();
            }
        }
    }

    warn "$peeraddr:$peerport closed\n";
}

sub _read {
    my $self = shift;

    eval {
        local $SIG{ALRM} = sub { die "Timed out\n"; };

        alarm(READ_TIMEOUT);

        while (1) {
            last if defined $self->{client}->{inputbuf};

            my $read = sysread $self->{server}->{client}, my $buf, CHUNKSIZE;

            if (!defined $read || $read == 0) {
                die "Read error: $!\n";
            }

            if (DEBUG) {
                warn "[$$] Read $read bytes: " . CORE::dump($buf) . "\n";
            }

            $self->{client}->{inputbuf} .= $buf;
        }
    };

    alarm(0);

    if ($@) {
        if ($@ =~ /Timed out/) {
            DEBUG && warn "[$$] Client connection timed out\n";
            syswrite $self->{server}->{client}, "timed out...\n";
        } elsif ($@ =~ /Read error/) {
            DEBUG && warn "[$$] Read error: $!\n";
        }
        return;
    }

    return 1;
}

sub _gen_picross_map {
    my $self = shift;
    my @picross;
    for (0..18) {
        my @row;
        for (0..18) {
            push @row, 0;
        }
        push @picross, \@row;
    }
    return \@picross;
}

sub _parse_and_pick {
    my ($self, $picross) = @_;
    my $buf = delete $self->{client}->{inputbuf};
    my ($x, $y) = $buf =~ /([0-9]{1,2})\s([0-9]{1,2})/ or die 'Format error';
    die 'Out of range' if $x > 18 || $y > 18;
    die 'Picked' if $picross->[$x][$y] == 1;
    $picross->[$x][$y] = 1;
    return ($x, $y);
}

sub _pick_statement {
    my ($self, $x, $y, $statement) = @_;

    my $width = length((split /\n/, $statement)[0]);
    my $plus = index $statement, '+';
    my $margin_top = int($plus / $width);
    my $margin_left = ($plus % $width) - $margin_top;

    my $offset = ($width + 1) * ($x + $margin_top + 1) + $y + $margin_left + 1;
    substr($statement, $offset, 1) = '*';
    return $statement;
}

sub _check_correct {
    my ($self, $picross, $answer) = @_;
    local $Data::Dumper::Terse = 1;
    local $Data::Dumper::Indent = 0;
    local $Data::Dumper::Sortkeys = 1;
    return Dumper($picross) eq Dumper($answer);
}

1;
