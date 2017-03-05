#!/usr/bin/perl -w

use strict;
use warnings;

use FindBin qw($Bin);

use Test::More;

use lib "$Bin/lib";
use Test::Expect::Raw;
use Shell::Bash::Selected::UnitTest::Common qw(:all);

my $exp = Test::Expect::Raw->new(
    timeout => $SHELL_CMD_TO,
    prompt => $DEFAULT_MENU_PROMPT
);
$exp->spawn("/usr/bin/env bash -c '$RUN_CMD -a<(cd $Bin/ls-menu;ls)'");
subtest 'get menu from file names', sub {
    plan tests => 2;

    $exp->expect_prompt_reply_lines(
        '1 5', [ 'a file name with spaces.txt', 'source-file.C' ],
        'selected menu items one and five from directory'
    );
};

$exp = Test::Expect::Raw->new(
    timeout => $SHELL_CMD_TO,
    prompt => $DEFAULT_MENU_PROMPT
);
$exp->spawn(qq!/usr/bin/env bash -c "echo 1 5 | xargs -a<(cd $Bin/ls-menu;ls) -d'\\n' $RUN_CMD -x"!);

$exp->expect_lines(
    [ 'a file name with spaces.txt', 'source-file.C' ],
    'automated drive of menu with xargs and pipe'
);

done_testing();
