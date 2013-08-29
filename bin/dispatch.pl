#!/usr/bin/env perl
use strict;
use warnings;

App::Dispatch->new(
    "/etc/dispatch.conf",
    "$ENV{HOME}/.dispatch.conf",
)->dispatch(@ARGV);

BEGIN {

    package App::Dispatch;

    sub programs { shift->{programs} }
    sub config   { shift->{config} }

    sub new {
        my $class = shift;

        my $self = bless {
            config   => {},
            programs => {},
        } => $class;

        $self->read_config($_) for @_;

        return $self;
    }

    sub read_config {
        my $self = shift;
        my ($file) = @_;
        unless ( -e $file ) {
            $self->config->{$file} = "No such file: '$file'.";
            return;
        }
        $self->config->{$file} = 1;

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
                $self->programs->{$program}->{$1} = $2;
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

        return $self->debug if $program eq 'DEBUG';

        die "No program specified\n" unless $program;

        my @cascade;

        push @cascade => shift @argv while @argv && $argv[0] ne '--';
        shift @argv;

        @cascade = ( 'DEFAULT', 'SYSTEM' ) unless @cascade;

        my $conf = $self->programs->{$program} || die "No program '$program' configured\n";

        for my $alias (@cascade) {
            next unless $conf->{$alias};
            next unless -x $conf->{$alias};
            exec( $conf->{$alias}, @argv );
        }

        die "Could not find path for any alias: " . join( ', ', @cascade ) . "\n";
    }

    sub debug {
        my $self = shift;
        require Data::Dumper;
        print Data::Dumper::Dumper($self);
    }
}
