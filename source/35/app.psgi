use strict;
use warnings;
use DBI;
use Data::Section::Simple qw/get_data_section/;
use Digest::MD5 qw/md5_hex/;
use File::Basename;
use File::Spec;
use Plack::Builder;
use Plack::Request;

my $dbh = DBI->connect(
    "dbi:SQLite:dbname=q35.db",
    '',
    '',
    +{
        RaiseError     => 1,
        sqlite_unicode => 1,
    }
);

$dbh->do("DROP TABLE IF EXISTS admin;");
$dbh->do(
    q{
        CREATE TABLE admin (
            name   VARCHAR(16) NOT NULL PRIMARY KEY,
            digest CHAR(13) NOT NULL
        );
    }
);

my $PASSWORD = $ENV{Q35_PASSWORD};
my $SALT = $ENV{Q35_SALT};

{
    my $digest = calc_digest($PASSWORD);
    $dbh->do("INSERT INTO admin VALUES ('admin', '$digest');");
}

my $source = do {
    open my $fh, '<', __FILE__ or die $!;
    local $/; <$fh>;
};

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    if ($req->path_info eq '/') {
        return [
            200,
            ['Content-Type' => 'text/html; charset=utf-8'],
            [get_data_section('index.html')]
        ];
    } elsif ($req->path_info eq '/source') {
        return render_text($source);
    } elsif ($req->path_info eq '/login') {
        if ($req->method eq 'POST') {
            my $name = $req->param('name');
            my $password = $req->param('password');
            die unless validate($name, $password);
            warn "login: $name $password\n";

            if (!is_exists($name)) {
                return render_text("$name does not exist.");
            }
            my ($digest) = $dbh->selectrow_array("SELECT digest FROM admin WHERE name = ?", undef, $name);
            if (calc_digest($password) eq $digest) {
                if ($name eq 'admin') {
                    return render_text("congratz! the flag is: ${PASSWORD}_$SALT");
                } else {
                    return render_text("login succeeded.");
                }
            } else {
                return render_text("login failed...");
            }
        }
    } elsif ($req->path_info eq '/register') {
        if ($req->method eq 'POST') {
            my $name = $req->param('name');
            my $password = $req->param('password');
            die unless validate($name, $password);
            warn "register: $name $password\n";

            if (is_exists($name)) {
                return render_text("$name exists.");
            }
            my $digest = calc_digest($password);
            $dbh->do("INSERT INTO admin VALUES (?, ?);", undef, $name, $digest);
            return render_text("done.");
        }
    }

    return [404, [], []];
};

builder {
    enable 'Plack::Middleware::ReverseProxy';
    enable 'Plack::Middleware::Static',
        path => qr{^/js/},
        root => File::Spec->catdir(dirname(__FILE__));
    $app;
};

sub render_text {
    [
        200,
        ['Content-Type' => 'text/plain; charset=utf-8'],
        [$_[0]]
    ]
}

sub validate {
    my ($name, $password) = @_;
    return 0 if !$name && $name !~ /^[\x21-\x7e]$/;
    return 0 if !$password && $password !~ /^[\x21-\x7e]$/;
    return 1;
}

sub is_exists {
    my $name = shift;
    my ($exists) = $dbh->selectrow_array("SELECT 1 FROM admin WHERE name = '$name'");
    return $exists;
}

sub calc_digest {
    my $password = shift;
    return crypt(md5_hex($password), $SALT);
}

__DATA__

@@ index.html
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title>q35</title>
    <style>body{background:#333;margin:0;padding:0}#term{color:#fff;padding:1em;font-family:monospace}</style>
    <script src="js/termlib.js"></script>
</head>
<body>
    <div id="term"></div>
    <script>
eval(function(f,u,c,k,e,r){e=function(c){return(c<u?'':e(parseInt(c/u)))+((c=c%u)>35?String.fromCharCode(c+29):c.toString(36))};if(!''.replace(/^/,String)){while(c--)r[e(c)]=k[c]||e(c);k=[function(e){return r[e]}];e=function(){return'\\w+'};c=1};while(c--)if(k[c])f=f.replace(new RegExp('\\b'+e(c)+'\\b','g'),k[c]);return f}('(h(){i 7=P O({x:L,y:K,n:\'7\',G:\'F D %+z%-b t r? q o B)\',H:m});7.p();h m(){5.k();i 4=5.u.v(/\\s+/);w(4[0]){6\'A\':6\'C\':g(4.E===3){5.f({e:\'/\'+4[0],d:\'I\',J:{c:4[1],a:4[2]},});9}M{5.8(\'N: \'+4[0]+\' c a\')}l;6\'j\':5.f({e:\'/j\',d:\'Q\',});9;6\'R\':5.S();l;T:g(4[0]!=""){5.8(\'U V W: \'+4[0]);5.k()}}5.X()}})();',60,60,'||||argv|this|case|term|type|return|password||name|method|url|send|if|function|var|source|newLine|break|termHandler|termDiv|luck|open|good|admin||as|lineBuffer|split|switch|||blogin|login||register|you|length|can|greeting|handler|post|data|24|80|else|usage|Terminal|new|get|exit|close|default|command|not|found|prompt'.split('|'),0,{}))
</script>
</body>
</html>
