package P;

use Readonly;

Readonly our $qux => 'ting';
Readonly my $qux2 => 'tang';
our $shared_var = 'walla';

sub qux2_sub {
    return $qux2;
}

package main;
use feature 'say';

say $P::qux;
say $P::shared_var;
say P::qux2_sub;
