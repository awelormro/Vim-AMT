import vim


# Start core
def start():
    AMT_Finders_commands()
    AMT_Finders_mappings()


def AMT_Finders_commands():
    vim.command("command! AMTOldfiles py3 amtfinders.AMT_Oldfiles()")


def AMT_Finders_mappings():
    pass


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
    vim.command("setlocal bufhidden=wipe")
    b = vim.current.buffer
    bvar = vim.current.buffer.vars
    b[0] = title
    bvar["main_values"] = all_values
    bvar["search_values"] = all_values
    bvar["title_len"] = len(title)
    amt_reload_buffer()
    print("values shown")


def amt_reload_buffer():
    b = vim.current.buffer
    bvar = vim.current.buffer.vars
    if len(b[:]) > 1:
        vim.command(":2,$delete")
    if len(bvar["search_values"]) > 10:
        b.append(bvar["search_values"][:10])
    else:
        b.append(bvar["search_values"])
    b[1] = "->" + b[1]
    bvar["counter"] = 1
    bvar["updating_line1"] = b[0]


def amt_cursor_down():
    search_val = vim.Function("search")("^->")
    b = vim.current.buffer
    bvar = vim.current.buffer.vars
    if bvar["counter"] == len(bvar["search_values"]):
        amt_reload_buffer()
        vim.Function("cursor")(1, vim.Function("col")("$"))
        return
    if search_val == 11:
        b.append("->" + bvar["search_values"][bvar["counter"]].decode("utf-8"))
        b[10] = b[10][2:]
        del b[1]
        bvar["counter"] += 1
        vim.Function("cursor")(1, vim.Function("col")("$"))
        return
    b[search_val - 1] = b[search_val - 1][2:]
    b[search_val] = "->" + b[search_val]
    bvar["counter"] += 1
    vim.Function("cursor")(1, vim.Function("col")("$"))


def amt_cursor_up():
    search_val = vim.Function("search")("^->")
    b = vim.current.buffer
    bvar = vim.current.buffer.vars
    if (search_val == 2 and len(bvar["search_values"]) <= 10):
        b[1] = b[1][2:]
        b[-1] = "->" + b[-1]
        bvar["counter"] = len(bvar["search_values"])
        vim.Function("cursor")(1, vim.Function("col")("$"))
        return
    if search_val == 2 and bvar["counter"] == 1:
        vim.command(":2,$delete")
        b.append(bvar["search_values"][-1])
        b[-1] = "->" + b[-1]
        bvar["counter"] = len(bvar["search_values"])
        vim.Function("cursor")(1, vim.Function("col")("$"))
        return
    if search_val == 2 and len(b[:]) < 11:
        bvar["counter"] -= 1
        b.append(bvar["search_values"][bvar["counter"] - 1], 1)
        b[1] = "->" + b[1]
        b[2] = b[2][2:]
        vim.Function("cursor")(1, vim.Function("col")("$"))
        return
    if search_val == 2:
        bvar["counter"] -= 1
        vim.command(":$delete")
        b[1] = b[1][2:]
        b.append(bvar["search_values"][bvar["counter"] - 1], 1)
        b[1] = "->" + b[1]
        vim.Function("cursor")(1, vim.Function("col")("$"))
        return
    b[search_val - 1] = b[search_val - 1][2:]
    b[search_val - 2] = "->" + b[search_val - 2]
    bvar["counter"] -= 1
    vim.Function("cursor")(1, vim.Function("col")("$"))


def amt_execute(action):
    search_val = vim.Function("search")("^->")
    b = vim.current.buffer
    sel = b[search_val - 1][2:]
    vim.command("q!")
    vim.command(action[0] + " " + sel + " " + action[1])


def amt_reload_search():
    b = vim.current.buffer
    bv = vim.current.buffer.vars
    if b[0] == bv["updating_line1"].decode("utf-8"):
        return
    bv["updating_line1"] = b[0]
    search_expression = b[0][bv["title_len"]:].strip()
    bv["search_values"] = vim.Function("matchfuzzy")(bv["main_values"], search_expression, {"limit": 200})
    vim.command("2,$delete")
    if len(bv["search_values"]) >= 10:
        b.append(list(bv["search_values"]))
    else:
        b.append(list(bv["search_values"][:10]))
    b[1] = "->" + b[1]
    bv["counter"] = 1
    vim.Function("cursor")(1, vim.Function("col")("$"))


def AMT_Oldfiles():
    vc = vim.command
    vim.current.buffer.vars["updating_line1"] = ""
    amt_open_buffer(vim.vvars['oldfiles'], "Search: ")
    a1 = 'command! -buffer '
    a2 = 'inoremap <buffer>'
    a3 = 'nnoremap <buffer>'
    vc(a1 + "AMTCursorUp py3 amtfinders.amt_cursor_up()")
    vc(a1 + " AMTCursorDown py3 amtfinders.amt_cursor_down()")
    vc(a1 + " AMTExecute py3 amtfinders.amt_execute(['e ', ''])")
    vc(a1 + " AMTReloadSearch py3 amtfinders.amt_reload_search()")
    vc(a2 + "<expr> <Backspace> col('.') > 9 && line('.') == 1 ?'" +
       " '<Backspace>' : ''")
    vc(a2 + "<expr> <Left> col('.') > 9 ? '<Left>' : ''")
    vc(a2 + "<expr> <Del> col('.') != col('$') && line('.') == 1 " +
       " && col('.') > 9 ? '<Del>' : ''")
    vc(a3 + " q :q!<CR>")
    vc(a3 + "<silent> <Up> :AMTCursorUp<CR>")
    vc(a3 + "<silent> <Down> :AMTCursorDown<CR>")
    vc(a3 + "<silent> k :AMTCursorUp<CR>")
    vc(a3 + "<silent> j :AMTCursorDown<CR>")
    vc(a3 + "<silent> <CR> :AMTExecute<CR>")
    vc("autocmd TextChangedI *.amtsearch if line('.') == 1 &&" +
       " b:updating_line1 != getline(1) | execute 'AMTReloadSearch' | endif")
