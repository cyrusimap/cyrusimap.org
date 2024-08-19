#!/usr/bin/env perl
=head1 NAME

run-gp.pl - rebuild the cyrusimap.org website

=head1 DESCRIPTION

Rebuilds the cyrusimap.org website (aka cyrusimap.github.io) from the RST
documentation in our various repositories and branches

=head1 SYNOPSIS

run-gp.pl [options]

    Options:
    --publish   publish updates to upstream repository
    --help      show usage

=head1 OPTIONS

=over 4

=item B<--publish>

The updated documentation will be published (pushed) to the website
repository.  Without this option, the updates will be commited locally,
but if you want them pushed, you will need to push them yourself (possibly
after amending authorship, commit messages, etc.

You would usually use this option in an automated runner, but skip it when
running manually.

=item B<--help>

Prints the usage information and exits.

=back

=cut

use warnings;
use strict;

use File::Path qw(make_path);
use File::Spec::Functions;
use Getopt::Long;
use Pod::Usage;

# A semi-persistent working directory
# (It's okay if this directory disappears, it will be remade automatically,
# but it's better if it doesn't disappear, so we don't have to do all these
# git clones every time)
my $basedir = '/tmp/CYRUS_DOCS_BUILD_DIR';

# The github.io repository from which the website is hosted
# Must have permission to push to here! Set GIT_SSH_COMMAND in the
# environment such that ssh runs with the correct identity file and
# whatever else it needs
my $target = {
    clonedir    => canonpath("$basedir/cyrusimap.github.io"),
    repo        => 'git@github.com:cyrusimap/cyrusimap.github.io.git',
    branch      => 'master',
    user_name   => 'cyrusdocgen',
    user_email  => 'cyrusdocgen@users.noreply.github.com',
};

# The sources that various parts of the website will be built from, referred
# to by webpaths below
# If no branch name is set, the source name will be used as the branch name
my $sources = {
    'cyrus-sasl' => {
        repo => 'https://github.com/cyrusimap/cyrus-sasl.git',
        branch => 'master',
    },
    'cyrus-imapd' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
        branch => 'master',
    },
    'cyrus-imapd-2.5' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
    'cyrus-imapd-3.0' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
    'cyrus-imapd-3.2' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
    'cyrus-imapd-3.4' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
    'cyrus-imapd-3.6' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
    'cyrus-imapd-3.8' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
    'cyrus-imapd-3.10' => {
        repo => 'https://github.com/cyrusimap/cyrus-imapd.git',
    },
};

# Maps web paths to sources from above
# Each web path is built from a single source, but some sources are used to
# build multiple web paths
# '/' and '/stable' should always be the current stable release,
# '/dev' should always be the cyrus-imapd master,
# '/sasl' should always be the cyrus-sasl master,
# Hopefully the rest is self-evident
my $webpaths = {
    '/'         => 'cyrus-imapd-3.10',
    '/stable'   => 'cyrus-imapd-3.10',
    '/dev'      => 'cyrus-imapd',
    '/sasl'     => 'cyrus-sasl',
    '/2.5'      => 'cyrus-imapd-2.5',
    '/3.0'      => 'cyrus-imapd-3.0',
    '/3.2'      => 'cyrus-imapd-3.2',
    '/3.4'      => 'cyrus-imapd-3.4',
    '/3.6'      => 'cyrus-imapd-3.6',
    '/3.8'      => 'cyrus-imapd-3.8',
    '/3.10'     => 'cyrus-imapd-3.10',
};

sub run_or_die
{
    my ($cmd, @args) = @_;

    print "===> running $cmd @args\n";
    system $cmd $cmd, @args;
    return if $? == 0;

    if ($? == -1) {
        die "could not execute '$cmd': $!\n";
    }
    elsif ($? & 127) {
        my $msg = sprintf "'$cmd' died with signal %d, %s coredump\n",
                          ($? & 127),  ($? & 128) ? 'with' : 'without';
        die $msg;
    }
    else {
        my $msg = sprintf "'$cmd' exited with value %d\n",
                          $? >> 8;
        die $msg;
    }
}

sub run_and_ignore_nonzero
{
    my ($cmd, @args) = @_;

    print "===> running $cmd @args\n";
    system $cmd $cmd, @args;
    return if $? == 0;

    if ($? == -1) {
        die "could not execute '$cmd': $!\n";
    }
    elsif ($? & 127) {
        my $msg = sprintf "'$cmd' died with signal %d, %s coredump\n",
                          ($? & 127),  ($? & 128) ? 'with' : 'without';
        die $msg;
    }
    else {
        # nonzero exit value, ignore it
        return;
    }
}

my $do_publish = '';
my $do_help = '';
GetOptions(
    'publish!' => \$do_publish,
    'help' => \$do_help,
) || pod2usage(2);
pod2usage(0) if $do_help;

# set up PATH
$ENV{PATH} = join(q{:}, qw( /usr/local/bin /usr/bin /bin ));
print "#### \$PATH is \"$ENV{PATH}\"\n";

# set up our basedir
make_path($basedir);
chdir $basedir or die "chdir $basedir: $!\n";

# pull the target
if (-d $target->{clonedir}) {
    print "#### updating website repository...\n";
    run_or_die('git', '-C', $target->{clonedir},
               'checkout', '-q', $target->{branch});
    run_or_die('git', '-C', $target->{clonedir},
               'fetch', 'origin');
    run_or_die('git', '-C', $target->{clonedir},
               'reset', '--hard', '@{u}');
}
else {
    print "#### cloning website repository...\n";
    run_or_die('git', 'clone', $target->{repo},
               '--branch', $target->{branch},
               '--single-branch',
               '--no-tags',
               $target->{clonedir});
    run_or_die('git', '-C', $target->{clonedir},
               'config', '--add', 'user.name', $target->{user_name});
    run_or_die('git', '-C', $target->{clonedir},
               'config', '--add', 'user.email', $target->{user_email});
    run_or_die('git', '-C', $target->{clonedir},
               'checkout', '-q', $target->{branch});
}

# build the docs from each source
foreach my $source (sort keys %{$sources}) {
    my $details = $sources->{$source};
    my $dir = canonpath("$basedir/$source");
    my $branch = $details->{branch} || $source;

    # first make sure we have the source tree
    if (! -d $dir) {
        print "#### cloning repo for $source...\n";
        run_or_die('git', 'clone', $details->{repo},
                   '--branch', $branch,
                   '--single-branch',
                   '--no-tags',
                   $dir);
    }
    else {
        print "#### updating repo for $source...\n";
        run_or_die('git', '-C', $dir,
                   'fetch', 'origin');
    }

    print "#### building docs for $source...\n";
    run_or_die('git', '-C', $dir,
               'checkout', '-q', "origin/$branch");
    run_or_die('make', '-C', canonpath("$dir/docsrc"), 'html');
}

# rsync the generated docs into the target
foreach my $webpath (sort keys %{$webpaths}) {
    my $source = $webpaths->{$webpath};
    my $src = canonpath("$basedir/$source/docsrc/build/html");
    my $dest = canonpath("$target->{clonedir}/$webpath");

    print "#### rsyncing $source docs to $webpath...\n";
    # n.b. trailing / on src argument is load-bearing
    run_or_die('rsync', '-av', "$src/", $dest);
}

# commit the updated docs to the website repo
print "#### committing updated docs...\n";
run_or_die('git', '-C', $target->{clonedir},
           'add', '--all');
# XXX git commit returns non-zero if nothing had changed, but that's fine
run_and_ignore_nonzero('git', '-C', $target->{clonedir},
                       'commit', '-m', 'automatic commit');
if ($do_publish) {
    print "#### publishing to website...\n";
    run_or_die('git', '-C', $target->{clonedir},
               'push');
}
else {
    print "#### (--publish not requested, not publishing to website)\n";
}
