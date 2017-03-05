#!/usr/bin/perl -w

use strict;
use warnings; 
use FindBin qw($Bin);

use Test::Expect;
use Test::More;

use lib "$Bin/lib";
use Shell::Bash::Selected::UnitTest::Common qw(:all);

$|++;

my $to_monkey_patch = *Expect::Simple::send;

*Expect::Simple::send = sub {
    print "monkey patched by rws\n";
    $to_monkey_patch->(@_)
};

my $pat_idx;

my $exp = new_menu_to_five();
$exp->log_stdout(1);
is( $pat_idx = $exp->expect($SHELL_CMD_TO, 'four'), 1,
    'found four on menu'
);

$pat_idx = $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);

die "could not find first prompt" unless (($pat_idx // 0) == 1);

$exp->send("2\n"); # "0\n" essentially works as expected

# idea is to check Expect before and after methonds with eof
my (undef, $expect_error) = $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);
like($expect_error, qr/\bEOF\b/, 'selected exited after output');
is($exp->exitstatus, 0, 'normal exit status 0');

print "**** before ***\n";
print $exp->before;
print "**** after ***\n";
print $exp->after;

done_testing();
