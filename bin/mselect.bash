#!/bin/bash

: <<'END_OF_DOCS'

=head1 NAME

mselect - a text filter extension of select that allows
multiple selections.  Depending on options, menu items
can be selected more than once and output defaults to order
of user selection but can be in order of menu items.  '*'
specifies selecting all menu items and consecutive menu
items can be selected with dash '-' separated ranges. The B<-n>
option disallows '*' and range selection.

=head1 SYNOPSIS

 $ mselect giggle gaggle bargle waggle
 1) giggle
 2) gaggle
 3) bargle
 4) waggle
 #? 2 3
 gaggle
 bargle

=head2 Switches

=over

=item B<-s>

Sort output in menu order.  By default selections are output in the
order specified by the item numbers provided at the prompt.  This option
specifies that selected items are output in the same order as items
in the menu.

=item B<-u>

Require that item selections be unique.  Prints an error and presents
the menu again if an item is selected more than once.  By default
the same item can be selected more than once.

=item B<-n>

Disallow '*' selection of all items and range selection.  Require
that selections be individually specified items by number.

=item B<-t>

Read menu selections from stdin even if stdin is a pipe.  Used
for testing or automation.

=back

=cut

END_OF_DOCS

# echo in order selected or in order of menu option
# reject duplicates option - (uniq program ?)

_mselect () {
    local dummy choice i
    local -a selected_choices valid_choices

    select dummy in "$@"; do # present numbered choices to user

        # simplify range parsing by removing spaces around dash
        REPLY=`echo "$REPLY" | sed 's/[ \t]*-[ \t]*/-/g'`

        # Parse ,-separated numbers entered into an array.
# Variable $REPLY contains whatever the user entered.
        IFS=', ' read -ra selected_choices <<<"$REPLY"
# Loop over all numbers entered.

        if ! (( ${#selected_choices[*]} )); then
            echo "No selections from menu.  'quit' or '0' for no selection." >&2
            continue 2 # ==> continue to select
        fi

        unset valid_choices
        for choice in "${selected_choices[@]}"; do

# hack to force easier termination
            if [[ $choice = 'quit' || $choice = '0' ]]
            then
                return
            fi

            # Validate the number entered.
            # reject non natural numbers
            if [[ -n ${choice//[0-9]} ]] || ! (( choice >= 1 && choice <= $# ))
            then 
                if [[ $choice = '*' ]] ; then
                    if ! ((is_numeric_choice)) ; then
                        valid_choices+=($(seq -s' ' 1 $#))
                    else
                        echo 'Invalid choice: * disallowed by -n numeric only option. Try again.'
                        continue 2
                    fi
                elif [\
                   -z `echo "$choice" | sed 's/[0-9][0-9]*-[0-9][0-9]*//'` \
                ] ; then
                    if ! ((is_numeric_choice)) ; then

                        local range_start=${choice%-*}
                        local range_end=${choice#*-}
                        if ((   range_start >= 1            &&
                                range_start <= $#           &&
                                range_start <= range_end    &&
                                range_end   <= $#           )) ; then
                            valid_choices+=($(seq -s' ' "$range_start" "$range_end"))
                        else
                            echo "Invalid range: $choice. Try again." >&2
                            continue 2 # ==> continue to select
                        fi

                    else
                        echo 'Invalid choice: range disallowed by -n numeric only option. Try again.'
                        continue 2
                    fi

                else
                    echo "Invalid choice: $choice. Try again." >&2
                    continue 2 # ==> continue to select
                fi
            else
                valid_choices+=("$choice")
            fi
        done

        if ((is_unique)) ; then
#            IFS=$'\n'
            unique_choices=($(printf '%s\n' "${valid_choices[@]}" | sort -un))
            if (( ${#unique_choices[@]} < ${#valid_choices[@]} )) ; then
                echo "Choice selected more than once with unique option enabled." >&2
                continue 2 # ==> continue to select
            fi
        fi

        if ((is_menu_sort)) ; then
            if ((is_unique)) ; then
                valid_choices=("${unique_choices[@]}")
            else
                IFS=$'\n'
                valid_choices=( \
                    $(printf '%s\n' "${valid_choices[*]}" | sort -n) \
                )
            fi
        fi

        if ((is_stdin_select)) ; then
            echo "$REPLY">/dev/tty
        fi

        for choice in "${valid_choices[@]}"; do
# If valid, echo the choice and its number.
#            echo "Choice #$(( ++i )): ${!choice} ($choice)"
            echo "${!choice}"
        done
# All choices are valid, exit the prompt.
        break
    done <&3

    return 0
}

mselect() {
    local is_menu_sort is_unique is_numeric_choice is_stdin_select
    local OPTIND opt

    _usage() {
        cat >&2 <<END_USAGE
Usage: mselect [-nstu] menu-option1 [ menu-option2 ... ]

Text filter extension of select that allows multiple selections.

    $ mselect giggle gaggle bargle waggle
    1) giggle
    2) gaggle
    3) bargle
    4) waggle
    #? 2 3
    gaggle
    bargle

See man page for more documentation.
END_USAGE
        exit 1
    }

    while getopts nsut opt; do
        case $opt in
            n)  is_numeric_choice=1
                shift $((OPTIND-1))
                ;;
            s)  is_menu_sort=1
                shift $((OPTIND-1))
                ;;
            u)  is_unique=1
                shift $((OPTIND-1))
                ;;
            t)  is_stdin_select=1
                shift $((OPTIND-1))
                ;;
        esac
    done

    if [ -t 0 ] || ((is_stdin_select)) ; then
        if [[ $# -eq 0 ]] ; then
            _usage
        else
            exec 3<&0
            _mselect "$@"
        fi
    else
        local -a args=("$@")
        local old_ifs="${IFS}"
        IFS=$'\n'
        args+=($(cat))
        IFS="${old_ifs}"

        if [[ ${#args[*]} -eq 0 ]] ; then
            _usage
        else
            exec 3</dev/tty
            _mselect "${args[@]}"
        fi
    fi
}

