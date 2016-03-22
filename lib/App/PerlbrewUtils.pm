package App::PerlbrewUtils;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

our %common_args = (
    include => {
        summary => 'Include perl(s) by name',
        schema => ['array*', of=>'str*'],
        tags => ['category:filtering'],
    },
    exclude => {
        summary => 'Exclude perl(s) by name',
        schema => ['array*', of=>'str*'],
        tags => ['category:filtering'],
    },
    include_version => {
        summary => 'Include perl(s) by version',
        description => <<'_',

You can specify e.g. `5.22` to include all 5.22.* version.

_
        schema => ['array*', of=>'str*'],
        tags => ['category:filtering'],
    },
    exclude_version => {
        summary => 'Exclude perl(s) by version',
        description => <<'_',

You can specify e.g. `5.22` to exclude all 5.22.* version.

_
        schema => ['array*', of=>'str*'],
        tags => ['category:filtering'],
    },
    min_version => {
        summary => 'Minimum perl version to include',
        schema => ['str*'],
        tags => ['category:filtering'],
    },
    max_version => {
        summary => 'Maximum perl version to include',
        schema => ['str*'],
        tags => ['category:filtering'],
    },
    xmin_version => {
        summary => 'Only include perl version greater than this',
        schema => ['str*'],
        tags => ['category:filtering'],
    },
    xmax_version => {
        summary => 'Only include perl version lesser than this',
        schema => ['str*'],
        tags => ['category:filtering'],
    },
    exclude_dev => {
        summary => 'Exclude dev perl(s)',
        schema => ['bool'],
        tags => ['category:filtering'],
    },
);

sub _version_eq {
    my ($v, $spec) = @_;

    if ($spec =~ s/^v?(\d+)$/v$1/) {
        $v =~ s/^v?(\d+).+/v$1/;
    } elsif ($spec =~ s/^v?(\d+\.\d+)$/v$1/) {
        $v =~ s/^v?(\d+\.\d+).+/v$1/;
    }
    version->parse($v) == version->parse($spec);
}

sub _version_gt {
    my ($v, $spec) = @_;

    if ($spec =~ s/^v?(\d+)$/v$1/) {
        $v =~ s/^v?(\d+).+/v$1/;
    } elsif ($spec =~ s/^v?(\d+\.\d+)$/v$1/) {
        $v =~ s/^v?(\d+\.\d+).+/v$1/;
    }
    my $res = version->parse($v) > version->parse($spec);
    #say "D:comparing version $v vs $spec: $res";
    $res;
}

sub _version_lt {
    my ($v, $spec) = @_;

    if ($spec =~ s/^v?(\d+)$/vv$1/) {
        $v =~ s/^v?(\d+).+/v$1/;
    } elsif ($spec =~ s/^v?(\d+\.\d+)$/v$1/) {
        $v =~ s/^v?(\d+\.\d+).+/v$1/;
    }
    my $res = version->parse($v) < version->parse($spec);
    #say "D:comparing version $v vs $spec: $res";
    $res;
}

sub _version_dev {
    my ($v) = @_;

    $v =~ /^v?\d+\.(\d+)/ or return 0;
    $1 % 2 ? 1:0;
}

sub _filter_perl {
    my ($perl, $args) = @_;

    #say "D:filtering perl $perl->{version} ...";

  FILTER_INCLUDE:
    {
        last unless $args->{include} && @{ $args->{include} };
        for (@{ $args->{include} }) {
            last FILTER_INCLUDE if $perl->{name} eq $_;
        }
        return 0;
    }

  FILTER_EXCLUDE:
    {
        last unless $args->{exclude} && @{ $args->{exclude} };
        for (@{ $args->{exclude} }) {
            return 0 if $perl->{name} eq $_;
        }
    }

  FILTER_INCLUDE_VERSION:
    {
        last unless $args->{include_version} && @{ $args->{include_version} };
        for (@{ $args->{include_version} }) {
            last FILTER_INCLUDE_VERSION if _version_included($perl->{version}, $_);
        }
        return 0;
    }

  FILTER_EXCLUDE_VERSION:
    {
        last unless $args->{exclude_version} && @{ $args->{exclude_version} };
        for (@{ $args->{exclude_version} }) {
            return 0 if _version_included($perl->{version}, $_);
        }
    }

  FILTER_MIN_VERSION:
    {
        last unless $args->{min_version};
        return 0 if _version_lt($perl->{version}, $args->{min_version});
    }

  FILTER_MAX_VERSION:
    {
        last unless $args->{max_version};
        return 0 if _version_gt($perl->{version}, $args->{max_version});
    }

  FILTER_XMIN_VERSION:
    {
        last unless $args->{xmin_version};
        return 0 if !_version_gt($perl->{version}, $args->{xmin_version});
    }

  FILTER_XMAX_VERSION:
    {
        last unless $args->{xmax_version};
        return 0 if !_version_lt($perl->{version}, $args->{xmax_version});
    }

  FILTER_EXCLUDE_DEV:
    {
        last unless $args->{exclude_dev};
        return 0 if _version_dev($perl->{version});
    }

    1;
}

1;
# ABSTRACT: More utilities for perlbrew

=head1 DESCRIPTION

This distribution contains the following utilities:

# INSERT_EXECS_LIST


=head1 SEE ALSO

L<App::perlbrew>, L<perlbrew>
