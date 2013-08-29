package App::Dispatch;
use strict;
use warnings;

our $VERSION = '0.003';

# NOTE:
# All code is located in bin/dispatch.pl. No code is here, this is to hep with
# portability, and to allow use of dispatch.pl in any perl installed to the
# system.

1;

__END__

=pod

=head1 NAME

App::Dispatch - Tool to have #! dispatch to the best executable for the job.

=head1 DESCRIPTION

Lately it has been a trend to avoid the system install of programming
languages, Perl, Ruby, Python, etc, in most cases it is recommended that you do
not use the system perl. A result of this is heavy use of C<#!/usr/bin/env> to
lookup the correct binary to execute based on your C<$PATH>. Sometimes though
you cannot control your environment as well as you would like. You cannot
always be sure that the binary in C<$PATH> is the one you want.

App::Dispatch solves the same problem as C</usr/bin/env>, but in a way that
gives you more control. With App::Dispatch you put a configuration file in /etc
(and optionally your home directory) which allows you provide aliases to
specific binaries. In your #! line you specify which program, and a cascade of
aliases to try. If the alias(es) you do not want are missing, or the program is
missing altogether, it will result in an error.

App::Dispatch also has 2 special aliases 'SYSTEM' which should be used to
specify which binary is used by the system, and 'DEFAULT' which should be used
when none is specified. In this way you can have system tools with a #! line
that is very clear on which binary should run it.

=head1 SYNOPSYS

This #! line will run perl, it will find the 'production' perl, if no
production perl is found it will try 'DEFAULT'. Anything after the -- is passed
as arguments to perl.

    #!/usr/local/bin/dispatch perl production DEFAULT -- -w

This will run the default perl.

    #!/usr/local/bin/dispatch perl

=head1 CONFIG FILES

=head2 LOCATIONS

Locations are loaded in this order. All locations that exist are loaded. Later
files can override earlier ones.

=over 4

=item /etc/dispatch.conf

The system wide configuration

=item /etc/dispatch/*

System wide config dir, to have app specific config files for easier management
with system packages.

=item $HOME/.dispatch.conf

User specific overrides or additions.

=back

=head2 EXAMPLE

    [perl]
        SYSTEM     = /usr/bin/perl
        DEFAULT    = /opt/ACME/current/bin/perl
        production = /opt/ACME/stable/bin/perl

    [gcc]
        SYSTEM  = /usr/bin/gcc
        DEFAULT = /usr/bin/gcc
        old     = /opt/legacy/bin/gcc

=head1 NOTE FOR CPAN AUTHORS

This tool is very useful for perl shops in their own scripts. However it most
likely should not be used in any scripts that will be installed with a cpan
distribution. Distributions should use a normal #! line that will be rewritten
by the build tools to use the perl for which the dist was installed. This is
important because of dependency chains and XS modules.

=head1 AUTHORS

Chad Granum L<exodist7@gmail.com>

=head1 COPYRIGHT

Copyright (C) 2013 Chad Granum

App-Dispatch is free software; Standard perl licence.

App-Dispatch is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the license for more details.

=cut
