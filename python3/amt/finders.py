import vim


def amt_buffer_start():
    # Check if splitbelow is generated and temporary gen if not
    sb = int(vim.eval('&splitbelow'))
    if sb == 0:
        vim.command('set splitbelow')

    # Start buffer in split with enew
    vim.command(':11split')
    vim.command(':enew')
    vim.command(":e search.amtsearch")
    vim.command('set filetype=amtsearch')
    vim.command('setlocal nobuflisted')
    del vim.current.buffer[:]

    # Return status of splitbelow in case
    if sb == 0:
        vim.command('set nosplitbelow')


def amt_fill_buffer(values: list, header: str, action: list):
    # With new buffer, delete and generate the first values
    vim.command('1,$delete')
    vim.current.buffer[0] = header
    vim.current.buffer.vars['main_values'] = values
    vim.current.buffer.vars['search_values'] = values
    vim.current.buffer.vars['counter'] = 0
    vim.current.buffer.vars['amt_action'] = action
    vim.current.buffer.vars["title_len"] = len(header)
    vim.current.buffer.vars["updating_line1"] = header

    # With the values generated, fill the buffer for first time
    if len(vim.current.buffer.vars['search_values']) <= 10:
        append_vals = vim.current.buffer.vars['search_values'][:10]
    else:
        append_vals = vim.current.buffer.vars['search_values'][:10]
    vim.current.buffer.append(append_vals, 1)
    vim.current.buffer[1] = '->' + vim.current.buffer[1]
    vim.current.window.cursor = (1, 100000)


def amt_gen_buf_search():
    pass


def amt_move_up():

    # Vim plugin standards
    b = vim.current.buffer
    bv = vim.current.buffer.vars
    vf = vim.Function

    # Search parts and generate conditions for loops
    srch_pos = vf('search')('->', 'n') - 1
    cond_1 = True if len(bv['search_values']) <= 10 else False
    cond_2 = True if bv['counter'] == 0 else False
    cond_3 = True if srch_pos == 1 else False
    cond_4 = True if len(b[:]) <= 11 else False

    if cond_1 and cond_2 and cond_3 and cond_4:
        b[1] = b[1][2:]
        b[-1] = '->' + b[-1]
        bv['counter'] = len(bv['search_values']) - 1
        return

    if not cond_1 and cond_2 and cond_3 and cond_4:
        del b[1:]
        b.append('->' + bv['search_values'][-1].decode('utf-8'))
        bv['counter'] = len(bv['search_values']) - 1
        return

    if not cond_1 and not cond_2 and cond_3 and cond_4:
        b.append(bv['search_values'][bv['counter'] - 1].decode('utf-8'), 1)
        b[1] = '->' + b[1]
        b[2] = b[2][2:]
        bv['counter'] -= 1
        del b[-1]
        return

    if not cond_1 and not cond_2 and cond_3 and not cond_4:
        del b[-1]
        bv['counter'] -= 1
        b.append(bv['search_values'][bv['counter']], 1)
        b[2] = b[2][2:]
        b[1] = '->' + b[1]
    else:
        bv['counter'] -= 1
        b[srch_pos - 1] = '->' + b[srch_pos - 1]
        b[srch_pos] = b[srch_pos][2:]


def amt_move_down():

    # Vim plugin standards
    b = vim.current.buffer
    bv = vim.current.buffer.vars
    vf = vim.Function

    # Search parts and generate conditions for loops
    len_buf = len(b[:])
    srch_pos = vf('search')('->', 'n') - 1
    len_search = len(bv['search_values'])

    if len_buf <= 11 and srch_pos == len(b[:]) and \
            bv['counter'] == len_search - 1 and \
            len_search <= 10:
        b[-1] = b[-1][2:]
        bv['counter'] = 0
        b[1] = '->' + b[1]
        return

    if bv['counter'] == len_search - 1:
        del b[1:]
        b.append(bv['search_values'][:10])
        b[1] = '->' + b[1]
        bv['counter'] = 0
        return

    if srch_pos == len_buf - 1:
        del b[1]
        b.append(bv['search_values'][bv['counter'] - 1])
        b[-2] = b[-2][2:]
        b[-1] = '->' + b[-1]
        bv['counter'] += 1
        return

    else:
        b[srch_pos + 1] = '->' + b[srch_pos + 1]
        b[srch_pos] = b[srch_pos][2:]
        bv['counter'] += 1
        return


def amt_maps_and_buffer(func):
    def amt_wrap(vals_eval, header, action):
        amt_buffer_start()
        resultado = func(vals_eval, header, action)
        amt_gen_maps_search()
        return resultado
    return amt_wrap


def amt_gen_maps_search():
    vc = vim.command
    vc("py3 from amt.finders import amt_move_up," +
       " amt_move_down, amt_confirm_selection, amt_reload_search")

    a = "command! -buffer "
    moves = ["amt_move_up()", "amt_move_down()", "amt_confirm_selection()", "amt_reload_search()"]
    command = ["AMTMoveUp", "AMTMoveDown", "AMTConfirm", "AMTReloadSearch"]

    i = 0
    len_moves = len(moves)
    while i < len_moves:
        vc(a + command[i] + " py3 " + moves[i])
        i += 1
    mapping = ["<Up>", "<Down>", "j", "k", "<CR>"]
    command = ["AMTMoveUp", "AMTMoveDown", "AMTMoveDown",
               "AMTMoveUp", "AMTConfirm"]
    i = 0
    len_moves = len(command)
    a = "nnoremap <buffer><silent> "
    b = "<CR>"
    while i < len_moves:
        vc(a + mapping[i] + " :" + command[i] + b)
        i += 1
    vc("inoremap <buffer><silent> <Up> <C-o>:AMTMoveUp<CR>")
    vc("inoremap <buffer><silent> <Down> <C-o>:AMTMoveDown<CR>")
    vc("inoremap <buffer><silent> <CR> <C-o>:AMTConfirm<CR>")
    vc("autocmd TextChangedI *.amtsearch if line('.') == 1 &&" +
       " b:updating_line1 != getline(1) | execute 'AMTReloadSearch' | endif")
    a2 = 'inoremap <buffer>'
    vc(a2 + "<expr>  <Backspace> col('.') > 9 && line('.') == 1 ? " +
       " '<Backspace>' : ''")
    vc(a2 + "<expr> <Left> col('.') > 9 ? '<Left>' : ''")
    vc(a2 + "<expr> <Del> col('.') != col('$') && line('.') == 1 " +
       " && col('.') > 9 ? '<Del>' : ''")
    a3 = 'nnoremap <buffer><silent>'
    vc(a3 + " q :bw!<CR>q!<CR>")


def amt_reload_search():
    b = vim.current.buffer
    bv = vim.current.buffer.vars
    bv["updating_line1"] = b[0]
    search_expression = b[0][bv["title_len"]:].strip()
    if search_expression == "":
        return
    bv["search_values"] = vim.Function("matchfuzzy")(bv["main_values"], search_expression, {"limit": 200})
    vim.command("2,$delete")
    if len(bv["search_values"]) >= 10:
        b.append(list(bv["search_values"]))
    else:
        b.append(list(bv["search_values"][:10]))
    b[1] = "->" + b[1]
    bv["counter"] = 0
    vim.Function("cursor")(1, vim.Function("col")("$"))


def amt_confirm_selection():
    action = vim.current.buffer.vars['amt_action']
    srch_pos = vim.Function('search')('->')
    line_content = vim.current.buffer[srch_pos - 1][2:]
    vim.command(':q!')
    vim.command(action[0].decode('utf-8') + ' ' + line_content + ' ' + action[1].decode('utf-8'))


@amt_maps_and_buffer
def generate_buffer(header: str, vals_eval: list, action: list):
    amt_fill_buffer(vals_eval, header, action)


def amt_Oldfiles():
    print('start oldfiles')
    generate_buffer('search: ', vim.vvars['oldfiles'], ['e ', ''])


def amt_Buffers():
    generate_buffer('search: ', vim.Function('getcompletion')('b ', 'cmdline'),
                    ['b ', ''])


def amt_colors():
    generate_buffer('search: ', vim.Function('getcompletion')('colo ',
                                                              'cmdline'),
                    ['colorscheme ', ''])


def amt_help():
    generate_buffer('search: ', vim.Function('getcompletion')('h ',
                                                              'cmdline'),
                    ['h ', ''])


def amt_session_directory_valid():
    # Verify if exists a path with valid
    if 'amt_sessions_dir' not in vim.vars:
        vim.vars['amt_sessions_dir'] = '~/sessions'
    print('session path located')
    session_folder = vim.vars['amt_sessions_dir'].decode('utf-8')
    print(session_folder)
    expand_path = vim.Function('expand')(session_folder).decode('utf-8')
    print(expand_path)
    session_valid = vim.Function('isdirectory')(expand_path)
    print(session_valid)
    if session_valid == 0:
        gen_sessions = vim.eval("input('Generate the folder? y/n: ')")
        if gen_sessions == 'y':
            vim.Function('mkdir')(vim.Function('expand')(
                vim.vars['amt_sessions_dir'].decode('utf-8')))
        elif gen_sessions == 'n':
            print('abort')
            vim.vars['amt_session_folder_exists'] = 0
            return
        else:
            print('not valid sequence. Abort')
            vim.vars['amt_session_folder_exists'] = 0
            return
    vim.vars['amt_session_folder_exists'] = 1
    vim.vars['amt_generate_buffer_sessions'] = 1
    print('valid session manager')


def amt_sessions():
    amt_session_directory_valid()
    if vim.vars['amt_session_folder_exists'] == 1:
        sessions_list = vim.Function('getcompletion')('so ' +
                          vim.vars['amt_sessions_dir'].decode('utf-8') +
                         "/*.vim", 'cmdline')
        if len(sessions_list) == 0:
            session_name = vim.eval("input('add a new session " +
                                    "file')")
            vim.command('mks ' + vim.vars['amt_sessions_dir'].decode('utf-8') +
                        "/" + session_name)
            return
        if vim.vars['amt_generate_buffer_sessions'] == 1:
            generate_buffer('session: ', sessions_list, ['so ', ''])


def amt_finders_start():
    vc = vim.command
    vc("py3 import amt.finders as find")
    a = "command! "

    actions = [
            "py3 find.amt_Buffers()",
            "py3 find.amt_colors()",
            "py3 find.amt_Oldfiles()",
            "py3 find.amt_sessions()",
            "py3 find.amt_help()",
            ]

    commands = [
            "AMTBuffers",
            "AMTColors",
            "AMTOldfiles",
            "AMTSessions",
            "AMTHelp",
            ]

    i = 0
    len_commands = len(commands)
    while i < len_commands:
        vc(a + " " + commands[i] + " " + actions[i])
        i += 1
