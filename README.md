# NAME

mselect - a text filter extension of select that allows
multiple selections.  Depending on options, menu items
can be selected more than once and output defaults to order
of user selection but can be in order of menu items.  '\*'
specifies selecting all menu items and consecutive menu
items can be selected with dash '-' separated ranges. The **-n**
option disallows '\*' and range selection.

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

- **-s**

    Sort output in menu order.  By default selections are output in the
    order specified by the item numbers provided at the prompt.  This option
    specifies that selected items are output in the same order as items
    in the menu.

- **-u**

    Require that item selections be unique.  Prints an error and presents
    the menu again if an item is selected more than once.  By default
    the same item can be selected more than once.

- **-n**

    Disallow '\*' selection of all items and range selection.  Require
    that selections be individually specified items by number.

- **-t**

    Read menu selections from stdin even if stdin is a pipe.  Used
    for testing or automation.
