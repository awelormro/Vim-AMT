import vim


def amt_pairing_quotes(sq: bool):
    vf = vim.Function
    # Verificar si es delete o backspace:
    close_char = '"' if sq else "'"
    auxchar = vim.Function('getchar')()
    if type(auxchar) is bytes:
        if auxchar == b'\x80kb' or auxchar == b'\x80kD':
            vim.command('call feedkeys("\\<Backspace>")')
            return ''
    # verificar si el char es espacio. enter, cierre
    if auxchar == 13:
        str_char = '\\<CR>\\<CR>\\<Up>'
        vim.command('call feedkeys("\\<CR>\\<CR>\\<Up>")')
        return close_char
    elif auxchar == 27:
        str_char = '\\<Esc>'
        return
    elif auxchar == 32:
        str_char = '\\<Space>\\<Space>\\<Left>'
    elif auxchar == 39:
        str_char = '\\<Right>'
    else:
        str_char = vim.Function('nr2char')(auxchar).decode('utf-8')
    if str_char == '"':
        vim.command('call feedkeys(\'"\')')
        vim.vars['object_realized'] = 1
        return
    elif str_char == "'":
        vim.command("call feedkeys(\"'\")")
        vim.vars['object_realized'] = 1
        return
    vim.command('call feedkeys("' + str_char + '"\\<Right>)')
    vim.vars['object_realized'] = 0


def amt_pairing_brackets(key: str):
    vf = vim.Function
    # Verificar si es delete o backspace:
    auxchar = vim.Function('getchar')()
    if type(auxchar) is bytes:
        if auxchar == b'\x80kb' or auxchar == b'\x80kD':
            vim.command('call feedkeys("\\<Backspace>\\<Del>")')
    # verificar si el char es espacio. enter, cierre
    if auxchar == 13:
        str_char = '\\<CR>\\<CR>\\<Up>'
    elif auxchar == 27:
        str_char = '\\<Esc>'
    elif auxchar == 32:
        str_char = '\\<Space>\\<Space>\\<Left>'
    else:
        str_char = vim.Function('nr2char')(auxchar).decode('utf-8')
    if str_char == '"':
        vim.command('call feedkeys(\'"\')')
        vim.vars['object_realized'] = 1
        return
    elif str_char == "'":
        vim.command("call feedkeys(\"'\")")
        vim.vars['object_realized'] = 1
        return
    # vim.command('call feedkeys("' + str_char + '\\<Right>")')
    vim.command('call feedkeys("' + str_char + '")')
    vim.vars['object_realized'] = 0


def auto_pair_start():
    vc = vim.command
    vc('py3 import amt.autopairs as ap')
    a = 'imap { {}<Left><C-o>:py3 ap.amt_pairing_brackets("{")<CR>'
    b = 'imap [ []<Left><C-o>:py3 ap.amt_pairing_brackets("[")<CR>'
    c = 'imap ( ()<Left><C-o>:py3 ap.amt_pairing_brackets("(")<CR>'
    # d = 'imap <expr> ) getline(\'.\')[col(\'.\')-1] == \')\' ? "\\<Right>" : \')\''
    # e = 'imap <expr> ] getline(\'.\')[col(\'.\')-1] == \']\' ? "\\<Right>" : \']\''
    # f = 'imap <expr> } getline(\'.\')[col(\'.\')-1] == \'}\' ? "\\<Right>" : \'}\''
    g = 'inoremap " ""<Left>'
    h = "inoremap ' ''<Left>"
    vc(a)
    vc(b)
    vc(c)
    # vc(d)
    # vc(e)
    # vc(f)
    vc(g)
    vc(h)


def auto_pair_bracket(pair: str, close: str, invoked: bool):
    vf = vim.Function
    auxchar = vim.Function('getchar')()
    if type(auxchar) is bytes:
        if auxchar == b'\x80kb':
            vim.command('call feedkeys("\\<Backspace>")')
            return
        else:
            vim.command('call feedkeys("' + close + '")')
            return
    vf('feedkeys')(close)
    vim.command('call feedkeys("\\<Left>")')
    # Enter = 13
    # Escape = 27
    if auxchar == 13:
        str_char = '\\<CR>\\<CR>\\<Up>'
    elif auxchar == 27:
        str_char = '\\<Esc>'
    elif auxchar == 32:
        str_char = '\\<Space>\\<Space>\\<Left>'
    elif auxchar == 41 or auxchar == 93 or auxchar == 125:
        str_char = '\\<Right>'
    else:
        str_char = vim.Function('nr2char')(auxchar).decode('utf-8')
    if str_char == '"' or str_char == "'":
        vim.command('call feedkeys("' + str_char + '")')
        vim.command('call feedkeys("\\<Left>")')
        return
    if str_char == '(':
        vim.command('call feedkeys("(")')
        vim.command('call feedkeys("\\<Left>")')
        return
    if str_char == '[':
        vim.command('call feedkeys("[")')
        vim.command('call feedkeys("\\<Left>")')
        return
    if str_char == '{':
        vim.command('call feedkeys("}")')
        vim.command('call feedkeys("\\<Left>")')
        return
    vim.command('call feedkeys("' + str_char + '")')


def auto_pair_quote(dquote):
    vc = vim.command
    close = '"' if dquote else "'"
    auxchar = vim.Function('getchar')()
    if type(auxchar) is bytes:
        if auxchar == b'\x80kb':
            vim.command('call feedkeys("\\<Backspace>")')
            return
        else:
            vim.command('call feedkeys("' + close + "')")
            return
    if auxchar == 13:
        str_char = '\\<CR>\\<Up>'
    elif auxchar == 27:
        str_char = '\\<Esc>'
    elif auxchar == 32:
        str_char = '\\<Space>\\<Space>\\<Left>'
    else:
        str_char = vim.Function('nr2char')(auxchar).decode('utf-8')
    if dquote:
        return '"'
    else:
        return "'"
