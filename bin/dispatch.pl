#!/usr/bin/env perl
use strict;
use warnings;

App::Dispatch->new->dispatch(@ARGV);

BEGIN {

    package App::Dispatch;

    sub new {
        my $class = shift;
        my $self = bless {} => $class;
        $self->read_config("/etc/dispatch.conf");
        $self->read_config("$ENV{HOME}/.dispatch.conf");
        return $self;
    }

    sub read_config {
        my $self = shift;
        my ($file) = @_;
        return unless -e $file;

        open( my $fh, '<', $file ) || die "Failed to open '$file': $!\n";

        my $program;
        my $ln = 0;
        while ( my $line = <$fh> ) {
            $ln++;
            chomp($line);
            next unless $line;
            next if $line =~ m/^#/;

            if ( $line =~ m/^\s*\[([a-zA-Z0-9_]+)\]\s*$/i ) {
                $program = $1;
                next;
            }

            if ( !$program ) {
                die "Error in '$file', line $ln: '$line'.\nItem is not under a program specification.\n";
            }

            if ( $line =~ m/^\s*([a-zA-Z0-9_]+)\s*=\s*(\S+)\s*$/ ) {
                $self->{$program}->{$1} = $2;
                next unless $1 eq 'SYSTEM' && $file ne '/etc/dispatch.conf';
                die "SYSTEM alias can only be specified in /etc/dispatch.conf.\n";
            }

            die "'$file' line $ln not valid: '$line'\n";
        }

        close($fh);
    }

    sub dispatch {
        my $self = shift;
        my ( $program, @argv ) = @_;

        my @cascade;

        push @cascade => shift @argv while @argv && $argv[0] ne '--';
        shift @argv;

        @cascade = ( 'DEFAULT', 'SYSTEM' ) unless @cascade;

        my $conf = $self->{$program} || die "No program '$program' configured\n";

        for my $alias (@cascade) {
            next unless -x $conf->{$alias};
            exec( $conf->{$alias}, @argv );
        }

        die "Could not find path for any alias: " . join( ', ', @cascade ) . "\n";
    }
}

1;
