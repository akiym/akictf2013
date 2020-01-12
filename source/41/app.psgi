use strict;
use warnings;
use DBI;
use Data::Section::Simple qw/get_data_section/;
use Encode;
use Plack::Builder;
use Plack::Request;
use Text::MicroTemplate qw/render_mt/;

my $db_config = [
    'dbi:SQLite:dbname=./pokemon.db', '', '',
    +{
        RaiseError     => 1,
        sqlite_unicode => 1,
    }
];
my $dbh = DBI->connect(@$db_config) or die $DBI::errstr;

package Pokemon {
    sub new {
        my ($class, %args) = @_;
        my $HP = $class->parameter(100, 110);
        return bless {
            name    => $class,
            HP      => $HP,
            MAX_HP  => $HP,
            attack  => $class->parameter(10, 30),
            defense => $class->parameter(10, 30),
            speed   => $class->parameter(10, 30),
            %args,
            halloffame => 0,
            level      => 1,
            money      => $class->parameter(100, 300),
            items      => [],
        }, $class;
    }

    sub parameter {
        my ($self, $a, $b) = @_;
        return int(rand($b - $a + 1)) + $a;
    }

    sub rename {
        my ($self, $name) = @_;
        if ($name !~ /FLAG/) {
            $self->{name} = $name;
        }
    }

    sub recover {
        my ($self, $regen) = @_;
        $self->{HP} += $regen;
        if ($self->{HP} > $self->{MAX_HP}) {
            $self->{HP} = $self->{MAX_HP};
        }
    }

    sub damage {
        my ($self, $attack, $defense, $HP) = @_;
        my $d = $attack - $defense;
        $d = 0 if $d < 0;
        my $damage = int($d + $attack * rand(0.5));
        $self->{HP} -= $damage;
        if ($self->{HP} < 0) {
            $self->{HP} = 0;
        }
        return $damage;
    }

    sub is_alive {
        my ($self) = @_;
        return $self->{HP} > 0;
    }

    sub levelup {
        my ($self) = @_;
        $self->{level}++;
        for my $key (qw/MAX_HP attack defense speed/) {
            $self->{$key} += $self->parameter(5, 10);
        }
    }

    sub buy {
        my ($self, $item) = @_;
        my %items = (
            'recover'      => 10,
            'potion'       => 50,
            'monster ball' => 1,
            'super ball'   => 10,
            'hyper ball'   => 100,
            'master ball'  => 1000,
        );
        my $money = $items{$item};
        if ($money && $self->{money} >= $money) {
            $self->{money} -= $money;
            push @{$self->{items}}, $item;
            return 1;
        } else {
            return 0;
        }
    }

    sub use {
        my ($self, $item) = @_;
        for my $i (0..@{$self->{items}} - 1) {
            if ($item eq $self->{items}[$i]) {
                splice @{$self->{items}}, $i, 1;
                return 1;
            }
        }
        return 0;
    }

    sub flag {
        my ($self) = @_;
        return $ENV{$self->{name}};
    }
}

package Fushigidane {
    use parent -norequire, qw/Pokemon/;

    sub new {
        my ($class, %args) = @_;
        return $class->SUPER::new(
            %args,
            type  => 'Grass',
            color => 'green',
            id    => 1,
        );
    }
}

package Hitokage {
    use parent -norequire, qw/Pokemon/;

    sub new {
        my ($class, %args) = @_;
        return $class->SUPER::new(
            %args,
            type  => 'Fire',
            color => 'red',
            id    => 4,
        );
    }
}

package Zenigame {
    use parent -norequire, qw/Pokemon/;

    sub new {
        my ($class, %args) = @_;
        return $class->SUPER::new(
            %args,
            type  => 'Water',
            color => 'blue',
            id    => 7,
        );
    }
}

package Poppo {
    use parent -norequire, qw/Pokemon/;

    sub new {
        my ($class, %args) = @_;
        return $class->SUPER::new(
            %args,
            type  => 'Flying',
            color => 'antiquewhite',
            id    => 16,
        );
    }
}

package Marumain {
    use parent -norequire, qw/Pokemon/;

    sub new {
        my ($class, %args) = @_;
        return $class->SUPER::new(
            %args,
            type  => 'Electric',
            color => 'red',
            id    => 101,
        );
    }
}

package Mewtwo {
    use parent -norequire, qw/Pokemon/;

    sub new {
        my ($class, %args) = @_;
        return $class->SUPER::new(
            %args,
            type  => 'Psychic',
            color => 'purple',
            id    => 150,
        );
    }
}

# here is your flag!
package FLAG {
    #use parent -norequire, qw/Pokemon/;

    sub flag {
        my ($self) = @_;
        return $ENV{$self->{name}};
    }
}

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    my $pokemon = $req->session->{pokemon};

    my $method = $req->method;
    my $path_info = $req->path_info;
    if ($path_info eq '/') {
        if ($pokemon && $req->session->{battle}) {
            return redirect('/battle');
        }
        return render('index.html', $pokemon);
    } elsif ($path_info eq '/source') {
        return get_source();
    } elsif ($path_info eq '/choose') {
        my $name = $req->param('pokemon') || '';
        if (!$pokemon) {
            $pokemon = $name->new();
            $req->session->{pokemon} = $pokemon;
            delete $req->session->{battle};
        }
        return redirect('/');
    } elsif (!$pokemon) {
        delete $req->session->{battle};
        return redirect('/');
    } elsif ($path_info eq '/menu') {
        my $action = $req->param('action') || '';
        if ($action eq 'recover') {
            if ($pokemon->buy('recover')) {
                $pokemon->recover(999);
                $pokemon->use('recover');
            }
            return redirect('/');
        } elsif ($action eq 'rename_confirm') {
            return message(<<'...');
<form action="/menu">
    <input type="hidden" name="action" value="rename" />
    name: <input type="text" name="name" />
    <input type="submit" value="rename!" />
</form>
...
        } elsif ($action eq 'rename') {
            my $name = $req->param('name') || '';
            $pokemon->rename($name);
            return redirect('/');
        } elsif ($action eq 'shopping_confirm') {
            return render('shopping.html', $pokemon);
        } elsif ($action eq 'shopping') {
            my $item = $req->param('item') || '';
            if ($pokemon->buy($item)) {
                return message('thank you! <a href="/">back</a>');
            } else {
                return message(q{you couldn't buy it~ <a href="/">back</a>});
            }
        } elsif ($action eq 'bye_confirm') {
            return message('bye? <a href="/menu?action=bye">YES</a> or <a href="/">NO</a>');
        } elsif ($action eq 'bye') {
            delete $req->session->{pokemon};
            delete $req->session->{battle};
            return redirect('/');
        } else {
            return redirect('/');
        }
    } elsif ($path_info eq '/battle') {
        my $action = $req->param('action') || '';
        my $enemy = $req->session->{battle}{enemy};
        if (!$enemy) {
            if ($pokemon->{money} >= 600) {
                # explode!!
                $enemy = Marumain->new(
                    HP      => 1,
                    MAX_HP  => 1,
                    attack  => 9999999,
                    defense => 1,
                    speed   => 9999999,
                );
            } elsif (int(rand(10)) == 0) {
                # strongest!!
                $enemy = Mewtwo->new(
                    HP      => 9999999,
                    MAX_HP  => 9999999,
                    attack  => 9999999,
                    defense => 9999999,
                    speed   => 9999999,
                );
            } else {
                $enemy = Poppo->new();
            }
            $req->session->{battle}{enemy} = $enemy;
            $req->session->{battle}{status} = 1;
        }
        my $battle = $req->session->{battle};
        if ($action eq 'fight') {
            my $status = $req->session->{battle}{status};
            if ($status >= 4) {
                delete $req->session->{battle};
                if ($status == 5 && $enemy->{name} eq 'Mewtwo') {
                    $pokemon->{halloffame} = 1;
                    $dbh->do(
                        q{INSERT INTO winner VALUES (?, ?)},
                        undef,
                        $pokemon->{name}, time(),
                    );
                    return redirect('/halloffame');
                }
                return redirect('/');
            }

            if (!$pokemon->is_alive) {
                $req->session->{battle}{message} = "you lose... bye!";
                $req->session->{battle}{status} = 4;
                delete $req->session->{pokemon};
                return render('battle_confirm.html', $pokemon, $battle);
            } elsif (!$enemy->is_alive) {
                $pokemon->levelup;
                $pokemon->{money} += int($enemy->{money} / 2);
                $req->session->{battle}{message} = "you win! level up!";
                $req->session->{battle}{status} = 5;
                return render('battle_confirm.html', $pokemon, $battle);
            }

            if ($status == 0) {
                $req->session->{battle}{status} = 1;
                return render('battle.html', $pokemon, $battle);
            } elsif ($status == 1) {
                if ($pokemon->{speed} > $enemy->{speed}) {
                    my $damaged = $enemy->damage($pokemon->{attack}, $enemy->{defense}, $enemy->{MAX_HP});
                    $req->session->{battle}{message} = "$enemy->{name}: HP - $damaged";
                    $req->session->{battle}{status} = 2;
                } else {
                    my $damaged = $pokemon->damage($enemy->{attack}, $pokemon->{defense}, $pokemon->{MAX_HP});
                    $req->session->{battle}{message} = "$pokemon->{name}: HP - $damaged";
                    $req->session->{battle}{status} = 3;
                }
                return render('battle_confirm.html', $pokemon, $battle);
            } elsif ($status == 2) {
                my $damaged = $pokemon->damage($enemy->{attack}, $pokemon->{defense}, $pokemon->{MAX_HP});
                $req->session->{battle}{message} = "$pokemon->{name}: HP - $damaged";
                $req->session->{battle}{status} = 0;
                return render('battle_confirm.html', $pokemon, $battle);
            } elsif ($status == 3) {
                my $damaged = $enemy->damage($pokemon->{attack}, $enemy->{defense}, $enemy->{MAX_HP});
                $req->session->{battle}{message} = "$enemy->{name}: HP - $damaged";
                $req->session->{battle}{status} = 0;
                return render('battle_confirm.html', $pokemon, $battle);
            }
        } elsif ($action eq 'item_confirm') {
            return render('battle_items.html', $pokemon);
        } elsif ($action eq 'item') {
            my $item = $req->param('item') || '';
            if ($pokemon->use($item)) {
                $req->session->{battle}{message} = "$pokemon->{name} used $item!";
                $req->session->{battle}{status} = 2;
                if ($item =~ /ball/) {
                    if ($item eq 'master ball') {
                        $req->session->{battle}{message} .= " ......$enemy->{name} was caught!";
                        $req->session->{battle}{status} = 5;
                    } else {
                        $req->session->{battle}{message} .= ' ......sorry, failed!';
                    }
                } elsif ($item eq 'potion') {
                    $pokemon->recover(50);
                    $req->session->{battle}{message} .= " $pokemon->{name}: HP + 50";
                }
                return render('battle_confirm.html', $pokemon, $battle);
            } else {
                return redirect('/battle');
            }
        } elsif ($action eq 'run') {
            return message('<img src="https://i.ytimg.com/vi/v3OddCwvpkQ/hqdefault.jpg" />');
        } else {
            return render('battle.html', $pokemon, $battle);
        }
    } elsif ($path_info eq '/flag') {
        if ($pokemon->{halloffame}) {
            return message($pokemon->flag);
        } else {
            return message('^_^');
        }
    } elsif ($path_info eq '/halloffame') {
        my $winners = $dbh->selectall_arrayref(
            q{SELECT name, created_at FROM winner ORDER BY created_at},
            {Slice => {}}
        );
        return render('halloffame.html', $winners);
    } else {
        return [404, [], ['not found']];
    }
};

builder {
    enable 'Plack::Middleware::Session::Cookie',
        secret => $ENV{SECRET};
    $app;
};

sub render {
    my ($tmpl, @vars) = @_;
    my $html = render_mt(get_data_section($tmpl), @vars);
    $html = encode_utf8($html);
    return [
        200,
        [
            'Content-Type'   => 'text/html; charset=utf-8',
            'Content-Length' => length $html,
        ],
        [$html]
    ];
}

sub message {
    my ($message) = @_;
    my $html = render_mt(get_data_section('message.html'), $message);
    $html = encode_utf8($html);
    return [
        200,
        [
            'Content-Type'   => 'text/html; charset=utf-8',
            'Content-Length' => length $html,
        ],
        [$html]
    ];
}

sub redirect {
    my ($location) = @_;
    return [302, [Location => $location], []];
}

sub get_source {
    my $src = do {
        open my $fh, '<', __FILE__ or die $!;
        local $/; <$fh>;
    };
    return [
        200,
        [
            'Content-Type'   => 'text/plain; charset=utf-8',
            'Content-Length' => length $src,
        ],
        [$src]
    ];
};

__DATA__

@@ index.html
? my ($pokemon) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
? if ($pokemon) {
    <p>
        <a href="/battle">battle</a>
        | <a href="/menu?action=recover">recover ($10)</a>
        | <a href="/menu?action=rename_confirm">rename</a>
        | <a href="/menu?action=shopping_confirm">shopping</a>
        | <a href="/halloffame">Hall of Fame</a>
        <!-- | <a href="/flag">flag</a> -->
        | <a href="/menu?action=bye_confirm">bye!</a>
    </p>
    <table border="1">
        <tr>
            <td>name</td>
            <td>
                <span style="color: <?= $pokemon->{color} ?>;"><?= $pokemon->{name} ?></span><? if ($pokemon->{halloffame}) { ?>&#x2605;<? } ?>
                <img src="http://pokeapi.co//media/img/<?= $pokemon->{id} ?>.png" />
            </td>
        </tr>
        <tr>
            <td>type</td>
            <td><?= $pokemon->{type} ?></td>
        </tr>
        <tr>
            <td>Level</td>
            <td style="width: 200px;"><?= $pokemon->{level} ?></div></td>
        </tr>
        <tr>
            <td>HP</td>
            <td style="width: 200px;"><div style="background: red; color: white; width: <?= $pokemon->{HP} / $pokemon->{MAX_HP} * 100 ?>%;"><?= $pokemon->{HP} ?></div></td>
        </tr>
        <tr>
            <td>attack</td>
            <td><?= $pokemon->{attack} ?></td>
        </tr>
        <tr>
            <td>defense</td>
            <td><?= $pokemon->{defense} ?></td>
        </tr>
        <tr>
            <td>speed</td>
            <td><?= $pokemon->{speed} ?></td>
        </tr>
        <tr>
            <td>money</td>
            <td>$<?= $pokemon->{money} ?></td>
        </tr>
        <tr>
            <td>items</td>
            <td><?= join ', ', @{$pokemon->{items}} ?></td>
        </tr>
    </table>
? } else {
    <p>choose your pokemon:</p>
    <ul>
        <li><a href="/choose?pokemon=Fushigidane">Fushigidane</a></li>
        <li><a href="/choose?pokemon=Hitokage">Hitokage</a></li>
        <li><a href="/choose?pokemon=Zenigame">Zenigame</a></li>
    </ul>
? }
</body>
</html>

@@ battle.html
? my ($pokemon, $battle) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
    <table style="width: 500px;">
        <tr>
            <td colspan="3">
                <div style="background: red; color: white; width: <?= $battle->{enemy}{HP} / $battle->{enemy}{MAX_HP} * 100 ?>%;"><?= $battle->{enemy}{HP} ?></div>
            </td>
        </tr>
    </table>
    <img src="http://pokeapi.co//media/img/<?= $battle->{enemy}{id} ?>.png" />
    <table style="width: 500px;">
        <tr>
            <td colspan="3">
                <div style="background: red; color: white; width: <?= $pokemon->{HP} / $pokemon->{MAX_HP} * 100 ?>%;"><?= $pokemon->{HP} ?></div>
            </td>
        </tr>
        <tr>
            <td rowspan="2" style="width: 300px;">
                <p>
                    what will <?= $pokemon->{name} ?> do?<br />
                    <img src="http://pokeapi.co//media/img/<?= $pokemon->{id} ?>.png" />
                </p>
            </td>
            <td style="text-align: center; width: 100px;"><a href="/battle?action=fight">FIGHT</a></td>
            <td style="text-align: center; width: 100px;"><a href="/battle?action=item_confirm">ITEM</a></td>
        </tr>
        <tr>
            <td style="text-align: center; width: 100px;">pokemon</td>
            <td style="text-align: center; width: 100px;"><a href="/battle?action=run">RUN</a></td>
        </tr>
    </table>
</body>
</html>

@@ battle_confirm.html
? my ($pokemon, $battle) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
    <table style="width: 500px;">
        <tr>
            <td colspan="3">
                <div style="background: red; color: white; width: <?= $battle->{enemy}{HP} / $battle->{enemy}{MAX_HP} * 100 ?>%;"><?= $battle->{enemy}{HP} ?></div>
            </td>
        </tr>
    </table>
    <img src="http://pokeapi.co//media/img/<?= $battle->{enemy}{id} ?>.png" />
    <table style="width: 500px;">
        <tr>
            <td colspan="3">
                <div style="background: red; color: white; width: <?= $pokemon->{HP} / $pokemon->{MAX_HP} * 100 ?>%;"><?= $pokemon->{HP} ?></div>
            </td>
        </tr>
        <tr>
            <td rowspan="2" style="width: 300px;">
                <p>
                    <?= Text::MicroTemplate::encoded_string($battle->{message}) ?> <a href="/battle?action=fight">&#x25BC;</a><br />
                    <img src="http://pokeapi.co//media/img/<?= $pokemon->{id} ?>.png" />
                </p>
            </td>
            <td style="text-align: center; width: 100px;">FIGHT</td>
            <td style="text-align: center; width: 100px;">ITEM</td>
        </tr>
        <tr>
            <td style="text-align: center; width: 100px;">pokemon</td>
            <td style="text-align: center; width: 100px;">RUN</td>
        </tr>
    </table>
</body>
</html>

@@ battle_items.html
? my ($pokemon) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
    <form action="/battle">
        <input type="hidden" name="action" value="item" />
        <table style="width: 500px;">
? for my $item (@{$pokemon->{items}}) {
            <tr>
                <td><?= $item ?></td>
                <td><input type="radio" name="item" value="<?= $item ?>" /></td>
            </tr>
? }
        </table>
        <input type="submit" value="use" />
    </form>
</body>
</html>

@@ shopping.html
? my ($pokemon) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
    <p>
        <a href="/battle">battle</a>
        | <a href="/menu?action=recover">recover ($10)</a>
        | <a href="/menu?action=rename_confirm">rename</a>
        | <a href="/menu?action=shopping_confirm">shopping</a>
        | <a href="/halloffame">Hall of Fame</a>
        <!-- | <a href="/flag">flag</a> -->
        | <a href="/menu?action=bye_confirm">bye!</a>
    </p>
    <h3>shopping</h3>
    <form action="/menu">
        <input type="hidden" name="action" value="shopping" />
        <table style="width: 500px;">
            <tr>
                <td>potion</td>
                <td>$50</td>
                <td><input type="radio" name="item" value="potion" /></td>
            </tr>
            <tr>
                <td>monster ball</td>
                <td>$1</td>
                <td><input type="radio" name="item" value="monster ball" /></td>
            </tr>
            <tr>
                <td>super ball</td>
                <td>$10</td>
                <td><input type="radio" name="item" value="super ball" /></td>
            </tr>
            <tr>
                <td>hyper ball</td>
                <td>$100</td>
                <td><input type="radio" name="item" value="hyper ball" /></td>
            </tr>
            <tr>
                <td>master ball</td>
                <td>$1000</td>
                <td><input type="radio" name="item" value="master ball" /></td>
            </tr>
        </table>
        <input type="submit" value="buy!" />
    </form>
</body>
</html>

@@ halloffame.html
? my ($winners) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
    <p>
        <a href="/battle">battle</a>
        | <a href="/menu?action=recover">recover ($10)</a>
        | <a href="/menu?action=rename_confirm">rename</a>
        | <a href="/menu?action=shopping_confirm">shopping</a>
        | <a href="/halloffame">Hall of Fame</a>
        <!-- | <a href="/flag">flag</a> -->
        | <a href="/menu?action=bye_confirm">bye!</a>
    </p>
    <h2>Hall of Fame</h2>
    <ol>
? for my $winner (@$winners) {
    <li><?= $winner->{name} ?> (<?= localtime($winner->{created_at}) ?>)</li>
? }
    </ol>
</body>
</html>

@@ message.html
? my ($message) = @_;
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>Pokemon battle</title>
</head>
<body>
    <h1>Pokemon battle</h1>
    <p>be a Pokemon champion! see <a href="/source">source</a>.</p>
    <hr />
    <p><?= Text::MicroTemplate::encoded_string($message) ?></p>
</body>
</html>
