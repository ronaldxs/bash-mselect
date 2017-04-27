#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/lib";
use Shell::Bash::Selected::UnitTest::Common qw(:all);

test_menu_to_three(
    'refuse select * with -s -n option', '2 *',
    qr/Invalid.*\* disallowed by -n.*/,
    'multi options menu choice correctly rejected',
    { optarg => [ '-s', '-n'] } 
);

test_menu_to_three(
    'refuse select * with -sn option', '2 *',
    qr/Invalid.*\* disallowed by -n.*/,
    'multi combined options menu choice correctly rejected',
    { optarg => '-sn' } 
);

test_menu_to_three(
    'sort with -s -n option', '3 1', [ qw(one three) ],
    'multi options sorts as expected',
    { optarg => [ '-s', '-n'] } 
);

test_menu_to_three(
    'refuse select * with -sn option', "3,1\t2", [ qw(one two three) ],
    'multi combined options with tab response sorts as expected',
    { optarg => '-sn' } 
);

done_testing();

