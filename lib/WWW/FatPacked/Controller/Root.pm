package WWW::FatPacked::Controller::Root;
use strictures 1;
use Moose;
extends 'Catalyst::Controller';
use MooseX::Types::Moose qw[ HashRef ];
use aliased 'WWW::FatPacked::AppMetaData';

my $class = __PACKAGE__;

has site_name => ( is => 'ro', required => 1 );

has application_dispatch => (
    is       => 'ro',
    required => 1,
    isa      => HashRef,
    trigger  => sub { shift->subdomain_app },    #construct ASAP
);

has subdomain_app => ( 
    is => 'ro',
    lazy_build => 1,
);

$class->config(
    action => {
        root => {
            Path => '/',
            Args => 0
        },
        doc => {
            Path => '/doc',
            Args => 0
        }
    }
);

sub _build_subdomain_app {
    my $dispatch = shift->application_dispatch;
    return +{
        map {
            my $app = AppMetaData->new( canonical_name => $_, %{ $dispatch->{$_} } ); #validate
            map { lc($_) => $app } @{ $app->subdomains_to_resolve }
        } keys %$dispatch
    };
}

around [qw/root doc/] => sub {
    my $orig = shift;
    my $self = shift;
    my ($ctx) = @_;

    my ($subdomain) =
      split( $self->site_name, $ctx->req->uri->host );    #$subdomain.x.y.z
    return $self->github_homepage($ctx) unless $subdomain; #fatpacked.pl
    $subdomain =~ s/\.$//g;
    return $self->github_homepage($ctx) if $subdomain =~ /www/i; #www.fatpacked.pl

    my $app = $self->subdomain_app->{lc($subdomain)}
      or return $self->error_404($ctx);

    return $self->$orig(@_,$app);
};

sub github_homepage {
    my ( $self, $c ) = @_;
    return $c->res->redirect(
        $self->github_repository_url . "/tree/" . $self->VERSION );
}

sub root {
    my ( $self, $ctx, $app ) = @_;
    return $ctx->res->redirect( $app->source_url );
}

sub doc {
    my($self,$ctx,$app) = @_;
    return $self->error_404($ctx) unless $app->doc_url;
    return $ctx->res->redirect( $app->doc_url );
}

sub error_404 {
    shift->_error_x( shift, 404, "404 Not Found" );
}

sub error_500 {
    my ( $self, $c ) = @_;
    shift->_error_x( shift, 500, "500 Internal Server Error" );
}

sub _error_x {
    my($self,$c,$error_code,$msg) = @_;
    $c->response->code(0+$error_code);
    $c->response->body($msg);
    $c->detach;
}
$class->meta->make_immutable;

1;

__END__

=head1 METHODS

=head2 root

=over 2

=item matches "/"

=item redirects to matching application source code

=back

=cut 
