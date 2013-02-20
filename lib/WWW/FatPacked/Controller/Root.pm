package WWW::FatPacked::Controller::Root;
use strictures 1;

our $VERSION = '0.63';

$VERSION = eval $VERSION;

use Moose;
use YAML;
extends 'Catalyst::Controller';
use MooseX::Types::Moose qw[ HashRef Str ArrayRef ];
use MooseX::AttributeShortcuts;
use aliased 'WWW::FatPacked::AppMetaData';

my $class = __PACKAGE__;

has [qw/site_name github_repository_url/] => ( is => 'ro', required => 1, isa => Str );


has application_dispatch => (
    is       => 'ro',
    required => 1,
    isa      => HashRef,
    trigger  => sub { shift->subdomain_app },    #construct ASAP
);

has apps => (
    is => 'lazy',
    isa => ArrayRef,
);

has subdomain_app => ( 
    is => 'ro',
    lazy_build => 1,
);

sub _build_apps {
    my $dispatch = shift->application_dispatch;
    return [
        map {
            AppMetaData->new( canonical_name => $_, %{ $dispatch->{$_} } )
        } keys %$dispatch
    ];
}
sub _build_subdomain_app {
    my $self = shift;
    my $apps = $self->apps;
    return +{
        map {
            my $app = $_;
            (
                map { lc($_) => $app }
                  @{ $app->subdomains_to_resolve } )
        } @$apps
    };
}

$class->config(
    namespace => "",
    action    => {
        root => {
            Path => "/",
            Args => 0,
        },
        doc => {
            Local => 1,
            Args  => 0,
        },
        list => {
            LocalRegex => 'list|yml',
            Args       => 0,
        },
    } );
sub default_redirect {
    my($self,$ctx) = @_;
    my $redirect = $ctx->uri_for('/list');
    warn $redirect;
    $ctx->res->redirect($redirect);
    $ctx->detach;
    return;
}

around [qw/root doc/] => sub {
    my $orig = shift;
    my $self = shift;
    my ($ctx) = @_;

    my ($subdomain) =
      split( $self->site_name, $ctx->req->uri->host );    #$subdomain.x.y.z
    return $self->default_redirect($ctx) unless $subdomain; #fatpacked.pl
    $subdomain =~ s/\.$//g;
    return $self->default_redirect($ctx) if $subdomain =~ /www/i; #www.fatpacked.pl

    my $app = $self->subdomain_app->{lc($subdomain)}
      or return $self->error_404($ctx);

    return $self->$orig(@_,$app);
};

sub github_homepage {
    my ( $self, $c ) = @_;
    return $c->res->redirect(
        $self->github_repository_url . "/tree/v" . $self->VERSION );
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

sub list {
    my ( $self, $ctx ) = @_;
    my $res = [
        map {
            my $app_redirect =
              "http://${\ $_->canonical_name }.${\ $self->site_name }";
            ( $app_redirect, ( $_->doc_url ? "$app_redirect/doc" : () ) )
        } @{ $self->apps } ];
    $ctx->res->body( YAML::Dump($res) );
    $ctx->response->headers->{ContentType} = "text/plain";
    $ctx->response->status(200);
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
