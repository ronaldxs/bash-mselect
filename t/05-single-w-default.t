#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use Test::More;

use lib "$Bin/lib";
use Shell::Bash::Selected::UnitTest::Common qw(:all);

sub new_menu_to_one {
    Shell::Bash::Selected::UnitTest::Common::new_menu_to_n(1, @_)
}

sub test_menu_to_one {
    Shell::Bash::Selected::UnitTest::Common::test_menu_to_n(1, @_)
}

test_menu_to_one(
    'one item without option', '', [ '1) one' ],
    'without option empty reprompts'
);

test_menu_to_one(
    'one item blank selection default Y', '', [ 'one' ],
    'empty with -SY accepts', { optarg => '-SY', exit_status => 0 }
);

my $exp = new_menu_to_one( '-SN' );
subtest 'one item blank selection default N', sub {
    plan tests => 3;

    $exp->prompt_reply('');
    my (undef, $expect_error) =
        $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);
    like(   $expect_error, qr/\bEOF\b|\bChild\b.*\bexited\b/i,
            'selected exited after blank selection'
    );
    is($exp->exitstatus, 0, 'exit status of 0');
};

$exp = new_menu_to_one( '-SQ' );
subtest 'invalid singe default-SQ', sub {
    plan tests => 3;

    $exp->expect_like(
        'must either be Y or N',
        'Error message for wrong -S option'
    );
    my (undef, $expect_error) =
        $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);
    like(   $expect_error, qr/\bEOF\b|\bChild\b.*\bexited\b/i,
            'exited after wrong option'
    );
    is($exp->exitstatus, 1 << 8, 'invalid option exit status of 1');
};

test_menu_to_one(
    'Invalid choose 2 with 1 option', '2',
    "Invalid choice: 2. Try again.",
    'menu choice correctly rejected', { optarg => '-SY' }
);

test_menu_to_one(
    'one item select twice', '1 1', [ 'one', 'one' ],
    'item selected twice', { optarg => '-SY', exit_status => 0 }
);

test_menu_to_one(
    'one item select twice with unique', '1 1',
    qr/selected more than once.*unique/,
    'unique error found', { optarg => '-uSY' }
);

$exp = Test::Expect::Raw->new(
    timeout     =>      $SHELL_CMD_TO,
    prompt      =>      $DEFAULT_MENU_PROMPT,
);
$exp->spawn($RUN_CMD, '-Sy', 'choice with spaces');
subtest 'one item with spaces default Y', sub {
    plan tests => 4;

    $exp->expect_prompt_reply_lines(
        '', 'choice with spaces', 'selected item with spaces by default'
    );
    my (undef, $expect_error) =
        $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);
    like(   $expect_error, qr/\bEOF\b|\bChild\b.*\bexited\b/i,
            'selected exited after blank selection'
    );
    is($exp->exitstatus, 0, 'exit status of 0');
};


done_testing();

