package WWW::FatPacked::Controller::Root;
use strictures 1;
use Moose;
extends 'Catalyst::Controller';
use MooseX::Types::Moose qw[ HashRef ];
use aliased 'WWW::FatPacked::AppMetaData';

my $class = __PACKAGE__;

has application_dispatch => (
    is       => 'ro',
    required => 1,
    isa      => HashRef,
    trigger  => sub { shift->application_dispatch_idx },    #construct ASAP
);

has application_dispatch_idx => ( 
    is => 'ro',
    lazy_build => 1,
);

$class->config(
    action => {
        root => {
            Path => '/',
            Args => 0
        }
    }
);

sub _build_application_dispatch_idx {
    my $dispatch = shift->application_dispatch;
    return +{
        map {
            my $app = AppMetaData->new( name => $_, %{ $dispatch->{$_} } ); #validate
            my $source_url = $app->source_url;
            map { $_ => $source_url } @{ $dispatch->{$_}{subdomains_to_resolve} }
        } keys %$dispatch
    };
}

sub root {
    my ( $self, $ctx ) = @_;
    if ( my $redirect =
        $self->application_dispatch_idx->{ [ split( /\./ => $ctx->req->uri->host ) ]
            ->[0] } )
    {
        return $ctx->res->redirect($redirect);
    }

    return $self->error_404($ctx);
}

sub error_404 {
    my($self,$c) = @_;
    $c->response->code(404);
    $c->response->body("404 Not Found");
}
sub error_500 {
    my($self,$c) = @_;
    $c->response->code(500);
    $c->response->body("500 Internal Server Error");
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
