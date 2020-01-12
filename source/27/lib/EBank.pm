package EBank;
use Mojo::Base 'Mojolicious';

use HTML::FillInForm::Lite;
use Model;

sub startup {
    my $self = shift;

    push @{$self->commands->namespaces}, 'CLI';

    my $config = $self->plugin(Config => {file => 'config/ebank.conf'});

    my $model = Model->new(
        connect_info => $config->{'Teng'},
    );
    $model->setup_schema;
    $self->helper(db => sub { $model });

    $self->helper(user => sub {
        my $self = shift;
        return undef
            unless $self->session->{user_id} && $self->session->{ident};
        return $self->db->single(user => {
            user_id      => $self->session->{user_id},
            ident_qq9ed7 => $self->session->{ident},
        });
    });
    $self->helper(render_fill => sub {
        my ($self, $template, $params) = @_;
        my $html = $self->render($template, partial => 1);
        return $self->render(
            text   => HTML::FillInForm::Lite->fill(\$html, $params),
            format => 'html',
        );
    });

    $self->hook(before_dispatch => sub {
        my $c = shift;
        if ($c->req->url->path =~ m!^/user! && !$c->user) {
            return $c->redirect_to('/login');
        }
        $c->stash->{user} = $c->db->user($c->session->{user_id});
    });

    # Router
    my $r = $self->routes;

    # Normal route to controller
    $r->get('/')->to('root#index');
    $r->get('/signup')->to('root#signup_page');
    $r->post('/signup')->to('root#signup');
    $r->get('/login')->to('root#login_page');
    $r->post('/login')->to('root#login');
    $r->get('/logout')->to('root#logout');

    $r->get('/user/bank_transfer')->to('user#bank_transfer_page');
    $r->post('/user/bank_transfer')->to('user#bank_transfer');
    $r->get('/user/inquiry')->to('user#inquiry_page');
    $r->post('/user/inquiry')->to('user#inquiry');
    $r->get('/user/search')->to('user#search_page');
    $r->post('/user/search')->to('user#search');
    $r->get('/user/history')->to('user#history');
}

1;
