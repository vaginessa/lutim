# vim:set sw=4 ts=4 sts=4 ft=perl expandtab:
package Mounter;
use Mojo::Base 'Mojolicious';
use Mojo::File;
use FindBin qw($Bin);
use File::Spec qw(catfile);

# This method will run once at server start
sub startup {
    my $self = shift;

    push @{$self->commands->namespaces}, 'Lutim::Command';

    my $cfile = Mojo::File->new($Bin, '..' , 'lutim.conf');
    if (defined $ENV{MOJO_CONFIG}) {
        $cfile = Mojo::File->new($ENV{MOJO_CONFIG});
        unless (-e $cfile->to_abs) {
            $cfile = Mojo::File->new($Bin, '..', $ENV{MOJO_CONFIG});
        }
    }
    my $config = $self->plugin('Config' =>
        {
            file    => $cfile,
            default => {
                prefix => '/',
                theme  => 'default',
            }
        }
    );

    $self->plugin('Lutim::Plugin::Helpers');

    $config->{prefix} = $config->{url_sub_dir} if (defined($config->{url_sub_dir}) && $config->{prefix} eq '/');

    $self->app->log->warn('"url_sub_dir" configuration option is deprecated. Use "prefix" instead. "url_sub_dir" will be removed in the future') if (defined($config->{url_sub_dir}));

    # Themes handling
    shift @{$self->static->paths};
    if ($config->{theme} ne 'default') {
        my $theme = $self->home->rel_file('themes/'.$config->{theme});
        push @{$self->static->paths}, $theme.'/public' if -d $theme.'/public';
    }
    push @{$self->static->paths}, $self->home->rel_file('themes/default/public');

    $self->hook(after_static => sub {
        my $c = shift;
        $c->res->headers->cache_control('max-age=2592000, must-revalidate');
    });
    $self->plugin('Mount' => {$config->{prefix} => File::Spec->catfile($Bin, '..', 'script', 'application')});
}

1;
