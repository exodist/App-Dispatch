#!/usr/bin/env perl
use strict;
use warnings;

use Test::More;

eval {
    for my $path ( 'bin/dispatch.pl', '../bin/dispatch.pl', 'dispatch.pl' ) {
        next unless -e $path;
        do $path;
        last;
    }
};

can_ok( 'App::Dispatch', 'new' );

my $one = App::Dispatch->new( 't/sample.conf', 'sample.conf' );

is_deeply(
    $one->programs,
    {
        test => {
            'sample' => 't/sample.pl',
            'bar'    => '/bin/bar',
            'baz'    => '/bin/baz',
            'foo'    => '/bin/foo'
        }
    },
    "Read config"
);

done_testing;
