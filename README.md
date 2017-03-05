# NAME

mselect - a text filter extension of select that allows
multiple selections.  Depending on options menu items
can be selected more than once and output defaults to order
of user selection but can be in order of menu items.  '\*'
specifies selecting all menu items unless disallowed with **-n**.

# SYNOPSIS

    $ mselect giggle gaggle bargle waggle
    1) giggle
    2) gaggle
    3) bargle
    4) waggle
    #? 2 3
    gaggle
    bargle

## Switches

- **-a**

    Get list of menu items as lines of file or subprocess
    specified by -a option.  Since menu selections are read
    from stdin the command

        ls -1 | xargs mselect

    doesn't do what you expect.  Menu selection tries to read
    from the closed pipe and no menu item is selected.  Instead do:

        mselect -a<(ls -1)

    to get the menu from the output of the ls command (or some other).
    Menu items are separated by end of line to allow embedded horizontal
    space.

- **-n**

    Disallow '\*' selection of all items and require that selections
    be individually specified items by number.

- **-s**

    Sort output in menu order.  By default selections are output in the
    order specified by the item numbers provided at the prompt.  This option
    specifies that selected items are output in the same order as items
    in the menu.

- **-u**

    Require that item selections be unique.  Prints an error and presents
    the menu again if an item is selected more than once.  By default
    the same item can be selected more than once.

- **-x**

    Allow mselect to run under xargs.  As explained with the **-a** option,
    running mselect the usual way with xargs doesn't work since the menu
    selection is read from stdin which is being used by xargs.  If, for
    some reason, you must use xargs try

        echo 2 | xargs -a<(ls -1) -d$'\n' mselect -x

    and now xargs reads the arguments that become menu selections from \`ls\`
    and mselect reads the menu selection from the pipe.  This should rarely
    be needed and the **-a** option of mselect is more likely to provide a
    good solution to menu options from a program or file.
