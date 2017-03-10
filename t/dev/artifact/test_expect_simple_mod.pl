#!/usr/bin/perl -w

use strict;
use warnings;

# use lib './lib';

use FindBin qw($Bin);
use File::Basename;

use Test::Expect;
use Test::More;

my $script_run_dir = $Bin;

$|++;

my $to_monkey_patch = \&Expect::Simple::send;

*Expect::Simple::send = sub {
    print "monkey patched by rws\n";
    $to_monkey_patch->(@_)
};



print "$script_run_dir/selected_simple.bash\n";

my $obj = Expect::Simple->new(
    {   Cmd           => "$script_run_dir/selected_simple.bash one two",
        Prompt        => [ -re => 'choice number:\s*'],
        DisconnectCmd => "0",
        Verbose       => 0,
        Debug         => 0,
        Timeout       => 3
    }
);
die $obj->error if $obj->error;

print "before send\n";
$obj->send('2');
print "after send\n";
my ($b, $a) = ($obj->before, $obj->after);
print 'before: ', length($b) ? $b : $/;
print 'after: ', length($a) ? $a : $/;
print 'match str: ', $obj->match_str, "\n";
print 'match idx: ', $obj->match_idx, "\n";
print 'error from expect: ', $obj->error_expect // 'no expect error', $/;
print 'error: ', $obj->error // 'no error', $/;

