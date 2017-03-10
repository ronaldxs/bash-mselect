#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin qw($Bin);
use File::Basename;

use Test::Expect;
use Test::More tests => 2;

my $script_run_dir = dirname $Bin;

print "$script_run_dir/selected\n";

expect_run(
#    command => [ "$script_run_dir/selected", qw/one two three four five/ ],
    command => "$script_run_dir/selected",
    prompt => 'choice number: ',
    quit => "quit",
);

expect_like(qr/four/, 'printed menu option four');
expect_send('2');
expect_like(qr/^two$/mi, 'got two on a line by itself');
expect_quit;
