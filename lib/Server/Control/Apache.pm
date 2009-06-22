package Server::Control::Apache;
use Moose;
use strict;
use warnings;

extends 'Server::Control';

has 'httpd_binary' => ( is => 'ro', default    => '/usr/bin/httpd' );
has 'conf_file'    => ( is => 'ro', lazy_build => 1 );
has 'conf_dir'     => ( is => 'ro', lazy_build => 1 );

__PACKAGE__->meta->make_immutable();

sub _build_conf_dir {
    my $self = shift;
    return catdir( $self->root_dir, "conf" );
}

sub _build_conf_file {
    my $self = shift;
    return catdir( $self->conf_dir, 'httpd.conf' );
}

sub do_start {
    my $self = shift;

    $self->send_httpd_command('start');
}

sub do_stop {
    my $self = shift;

    $self->send_httpd_command('stop');
}

sub send_httpd_command {
    my ( $self, $command ) = @_;

    my $httpd_binary = $self->httpd_binary();
    my $conf_file    = $self->conf_file();

    my $cmd = "$httpd_binary -k $command -f $conf_file";
    if ( $self->use_sudo() ) {
        $cmd = "sudo $cmd";
    }
    $self->vmsg("running '$cmd'");
    run($cmd);
}

1;