#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/lib";
use Shell::Bash::Selected::UnitTest::Common qw(:all);

test_menu_to_three(
    'select all from menu', '*', [ qw(one two three) ],
    'selected menu items one through three'
);

test_menu_to_three(
    'select all from menu and two twice', '2 *', [ qw(two one two three) ],
    'selected menu items two then one through three'
);

test_menu_to_three(
    'refuse select * with -n option', '2 *',
    'Invalid choice: * disallowed by -n numeric only option. Try again.',
    'menu choice correctly rejected',
    { optarg => '-n' } 
);

test_menu_to_five(
    'select with valid range', '1,3-5', [ qw(one three four five) ],
    'selected menu items matched range'
);

test_menu_to_five(
    'select with invalid range', '1,3-7', 'Invalid range: 3-7. Try again.',
    'invalid range rejected'
);

test_menu_to_five(
    'select with invalid reverse range', '1,5-3',
    'Invalid range: 5-3. Try again.', 'invalid reverse range rejected'
);

test_menu_to_three(
    'refuse range with -n option', '2-3',
    'Invalid choice: range disallowed by -n numeric only option. Try again.',
    'range with -n option correctly rejected',
    { optarg => '-n' } 
);

foreach my $exit_command ('quit', '0') {
    my $exp = new_menu_to_three();
    subtest "say $exit_command and exit", sub {
        plan tests => 3;

        my $pat_idx;
        $exp->prompt_reply($exit_command);
        my (undef, $expect_error) =
            $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);
        like(   $expect_error, qr/\bEOF\b|\bChild\b.*\bexited\b/i,
                "selected exited after $exit_command"
        );
        is($exp->exitstatus, 0, 'exit status of 0');
    };
}

done_testing();

