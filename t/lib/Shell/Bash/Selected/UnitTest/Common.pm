package Shell::Bash::Selected::UnitTest::Common;

use strict;
use warnings;

use Test::More;
use Readonly;
use FindBin qw($Bin);
use Carp;

use Test::Expect::Raw;

use parent qw(Exporter); 

our @EXPORT_OK = qw(
    $SHELL_CMD_TO
    $DEFAULT_MENU_PROMPT
    $RUN_CMD
    new_menu_to_three
    new_menu_to_five
    test_menu_to_three
    test_menu_to_five
);

our %EXPORT_TAGS = (
    constants => [qw($SHELL_CMD_TO $DEFAULT_MENU_PROMPT $RUN_CMD)],
    methods => [qw(
        new_menu_to_three new_menu_to_five
        test_menu_to_three test_menu_to_five
    )],
);
push @{$EXPORT_TAGS{'all'}}, @{$EXPORT_TAGS{ $_ }}
    foreach qw(constants methods);

Readonly our $SHELL_CMD_TO => 10;
Readonly our $DEFAULT_MENU_PROMPT => '#? ';
Readonly our $RUN_CMD => "$Bin/../bin/mselect.bash";

sub new_menu_to_n {
    my $n = shift;
    my @other_opts = @_;

    Readonly my @MENU_OPTS => qw(one two three four five);
    croak "Didn't learn to count as high as $n"
        if ($n > @MENU_OPTS);

    my $exp = Test::Expect::Raw->new(
        timeout     =>      $SHELL_CMD_TO,
        prompt      =>      $DEFAULT_MENU_PROMPT,
#        log_stdout  =>      1
    );
    $exp->spawn($RUN_CMD, @other_opts, @MENU_OPTS[0 .. $n -1]);

    return $exp;
}

sub new_menu_to_three { new_menu_to_n(3, @_) }

sub new_menu_to_five { new_menu_to_n(5, @_) }

sub test_menu_to_n {
    my (    $n, $test_description, $menu_selection,
            $selected_lines, $selection_description,
            $opts
    ) = @_;
    my $exp = $opts->{exp} //
        new_menu_to_n($n, $opts->{optarg} // ());
    my $pat_idx;

    subtest $test_description, sub {
        plan tests => 2 + (exists $opts->{exit_status} ? 2 : 0);
        $exp->expect_prompt_reply_lines(
            $menu_selection, $selected_lines, $selection_description
        );
        if (exists $opts->{exit_status}) {
            my (undef, $expect_error) =
                $exp->expect($SHELL_CMD_TO, $DEFAULT_MENU_PROMPT);
            like(   $expect_error, qr/\bEOF\b|\bChild\b.*\bexited\b/i,
                    'selected exited after output'
            );
            is( $exp->exitstatus, $opts->{exit_status},
                'exit status of ' . $exp->exitstatus . ' matched expectations');
        }
    };

    return $exp;
}

sub test_menu_to_three { test_menu_to_n(3, @_) }
sub test_menu_to_five { test_menu_to_n(5, @_) }

1;

