use strict;
use warnings;
use utf8;
use AnySan;
use AnySan::Provider::IRC;
use DBI;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=bot.db", '', '',
    +{
        sqlite_unicode => 1,
    }
);
$dbh->do(
    q{
        CREATE TABLE IF NOT EXISTS user (
            name  VARCHAR(255) NOT NULL PRIMARY KEY,
            score INT NOT NULL
        )
    }
);
$dbh->do(q{DROP TABLE fl4g});
$dbh->do(
    q{
        CREATE TABLE fl4g (
            flag     TEXT,
            fl4g     TEXT,
            realFLAG TEXT
        )
    }
);
$dbh->do(q{INSERT INTO fl4g VALUES ('http://www.youtube.com/watch?v=oHg5SJYRHA0', 'http://www.youtube.com/watch?v=oHg5SJYRHA0', "the flag is...
I <3 SQLite!")});

my $irc;
my $create_session; $create_session = sub {
    irc
        'irc.freenode.net',
        nickname => 'akictf-q36',
        on_connect => sub {
            my ($con, $err) = @_;
            if (defined $err) {
                warn "connect error: $err";
                sleep 60;
                $con->disconnect('try reconnect');
            }
        },
        on_disconnect => sub {
            # XXX
            warn "disconnected";
            undef $irc->{client};
            undef $irc->{SEND_TIMER};
            undef $irc;
            $irc = $create_session->();
        },
        channels => {
            '#akictf-meeting' => {},
        };
};
$irc = $create_session->();

AnySan->register_listener(
    echo => {
        cb => sub {
            my $receive = shift;
            my $nick = $receive->from_nickname;
            my $message = $receive->message;
            my ($name, $sign) = $message =~ m!^([\x21-\x7e]{1,255})(\+\+|--)$!;
            unless (defined $name) {
                warn "[$nick] message: $message\n";
                return;
            }
            warn "[$nick] name: $name\n";

            my ($score) = $dbh->selectrow_array(
                "SELECT score FROM user WHERE name = '$name'"
            );
            unless (defined $score) {
                $dbh->do("INSERT INTO user VALUES ('$name', 0)");
            }
            $dbh->do("UPDATE user SET score = " . ($score + ($sign eq '++' ? 1 : -1)) . " WHERE name = '$name'");

            ($score) = $dbh->selectrow_array(
                "SELECT score FROM user WHERE name = '$name'"
            );
            $receive->send_reply("$name: $score");
        },
    },
);

AnySan->run;
