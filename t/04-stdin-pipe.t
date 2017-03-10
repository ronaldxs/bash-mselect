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

$exp->spawn("/usr/bin/env bash -c 'ls $Bin/ls-menu | $RUN_CMD'");
subtest 'get menu from file names', sub {
    plan tests => 2;

    $exp->expect_prompt_reply_lines(
        '1 5', [ 'a file name with spaces.txt', 'source-file.C' ],
        'selected menu items one and five from directory'
    );
};

#die qq!/usr/bin/env bash -c \$'IFS="\\n"; echo 1 5 | $RUN_CMD -t `ls ./ls-menu`'!;
$exp = Test::Expect::Raw->new(
    timeout => $SHELL_CMD_TO,
    prompt => $DEFAULT_MENU_PROMPT
);
# list form of spawn, which calls exec,
# to prevent /bin/sh -c from interfering with quotes
$exp->spawn(
    '/usr/bin/env', 'bash', '-c',
    qq!IFS=\$'\\n'; echo 1 5 | $RUN_CMD -t `ls $Bin/ls-menu`!
);

$exp->expect_lines(
    [ 'a file name with spaces.txt', 'source-file.C' ],
    'automated drive of menu with xargs and pipe'
);

done_testing();
