import vim


# Starters to commands and mappings {{{
def start():
    AMT_Finders_commands()
    AMT_Finders_mappings()


def AMT_Finders_commands():
    vim.command("command! AMTOldfiles py3 amtfinders.AMT_Oldfiles()")


def AMT_Finders_mappings():
    pass


# }}}
# AMT Core {{{
def amt_open_buffer(all_values, title):
    """
    open the buffer with all the specifications and generate the mappings
    b:search_values: values in current search status
    b:main values: list of all values in search mode
    b:curr_search: value of current search
    """
    # Open and generate buffer {{{
    sp_below = int(vim.eval("&splitbelow"))
    if sp_below == 0:
        vim.command("set splitbelow")
        vim.command(":11split")
        vim.command("e search.amtsearch")
        vim.command("set nosplitbelow")
    else:
        vim.command(":split")
        vim.command("e search.amtsearch")
    vim.command("set filetype=amtsearch")
    # }}}
    vim.command(":1,$delete")
    b = vim.current.buffer
    bvar = vim.current.buffer.vars
    b[0] = title
    bvar["main_values"] = all_values
    if len(bvar["main_values"]) > 10:
        bvar["search_values"] = bvar["main_values"][:10]
        print("more than 10 values, only show first ten values")
        b.append(list(bvar["search_values"]))
    else:
        b.append(list(bvar["search_values"]))
    print("values shown")
    b[1] = "->" + b[1]
    bvar["counter"] = 1


def amt_cursor_down():
    search_val = vim.Function("search")("^->")
    b = vim.current.buffer
    bvar = vim.current.buffer.vars
    len_vals = len(b[:])
    if search_val == len_vals:
        vim.command(":2delete")
        vim.current.buffer[-1] = vim.current.buffer[-1][2:]
        vim.current.buffer.append(0)


def amt_cursor_up():
    pass


def amt_start_buffer():
    pass


# }}}
# AMT functions for commands {{{
def AMT_Oldfiles():
    amt_open_buffer(vim.vvars['oldfiles'], "Search")
# }}}
