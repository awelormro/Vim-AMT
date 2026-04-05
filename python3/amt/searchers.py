# searchers for vim. Helps to make the main filter file
import vim


# --------------------------------------------
# Aux amt_functions
# --------------------------------------------


def _fill_buffer(data: list) -> None:
    len_data = len(data)
    vim.current.buffer.vars['total_data'] = data
    # Se va a rascar de aquí para llenar total_data y llenar
    vim.current.buffer.vars['search_data'] = data
    vim.current.buffer.vars['finished_search'] = 0
    if len_data <= 10:
        vim.current.buffer.vars['buffer_data'] = data
    else:
        vim.current.buffer.vars['buffer_data'] = data[0:10]
    data_fill = vim.eval('b:buffer_data')
    vim.current.buffer.append(data_fill)
    vim.current.buffer.vars['counter'] = 0
    vim.current.buffer.vars['search_value'] = ''
    vim.current.buffer[1] = '->' + vim.current.buffer[1]
    vim.current.window.cursor = [1, len(vim.current.buffer[0])]


def _change_tick(line_prev: int, line_new: int) -> None:
    vim.current.buffer[line_prev] = vim.current.buffer[line_prev][2:]
    vim.current.buffer[line_new] = '->' + vim.current.buffer[line_new]


def _generate_mappings(comm_start: str, comm_end: str) -> None:
    vc = vim.command
    com_start = 'command! -buffer '
    com_0 = 'py3 import amt.searchers as srch'
    com_1 = 'AMTCursorUp py3 srch.amt_cursor_up()'
    com_2 = 'AMTCursorDown py3 srch.amt_cursor_down()'
    com_3 = 'AMTConfirmSelection py3 srch.amt_confirm_buffer("' + comm_start +\
            '", "' + comm_end + '")'
    com_4 = 'AMTChangeSearch py3 srch.amt_reload_search()'
    com_modify = 'autocmd TextChangedI *.amtsearch execute "AMTChangeSearch"'
    vc(com_0)
    vc(com_start + com_1)
    vc(com_start + com_2)
    vc(com_start + com_3)
    vc(com_start + com_4)
    vc(com_modify)


def _first_row_up() -> None:
    len_total_data = len(vim.current.buffer.vars['total_data'])
    if len_total_data == 1:
        vim.current.buffer.vars['finished_search'] = 1
        return
    if vim.current.buffer.vars['counter'] == 0:
        if len_total_data <= 10:
            _change_tick(1, -1)
            len_data = len(vim.current.buffer.vars['total_data'])
            vim.current.buffer.vars['counter'] = len_data - 1
            vim.current.buffer.vars['finished_search'] = 1
            return
        del vim.current.buffer[1:]
        vim.current.buffer.vars['counter'] = len_total_data - 1
        new_pos = vim.current.buffer.vars['counter']
        new_line = '->' + vim.current.buffer.vars['total_data'][new_pos].decode('utf-8')
        vim.current.buffer.append(new_line)
        vim.current.buffer.vars['finished_search'] = 1
        return
    len_total_buffer = len(vim.current.buffer)
    if len_total_data > 10:
        if len_total_buffer > 11:
            new_pos = vim.current.buffer.vars['counter'] - 1
            new_line = '->' + vim.current.buffer.vars['total_data'][new_pos]
            vim.current.buffer.append(new_line, 1)
            vim.current.buffer.vars['counter'] -= 1
            vim.current.buffer.vars['finished_search'] = 1
            return
        if len_total_buffer == 11:
            del vim.current.buffer[-1]
            new_pos = vim.current.buffer.vars['counter'] - 1
            new_line = vim.current.buffer.vars['total_data'][new_pos]
            vim.current.buffer.append(new_line, 1)
            vim.current.buffer.vars['counter'] = new_pos
            vim.current.buffer.vars['finished_search'] = 1
            return
        if len_total_buffer < 11:
            new_pos = vim.current.buffer.vars['counter'] - 1
            new_line = '->' + vim.current.buffer.vars['total_data'][
                    new_pos].decode('utf-8')
            vim.current.buffer[1] = vim.current.buffer[1][2:]
            vim.current.buffer.append(new_line, 1)
            vim.current.buffer.vars['counter'] -= 1
            vim.current.buffer.vars['finished_search'] = 1
            return
    _change_tick(1, -1)
    vim.current.buffer.vars['finished_search'] = 1
    vim.current.buffer.vars['counter'] -= 1
    return


def _last_row_down() -> None:
    len_total_data = len(vim.current.buffer.vars['total_data']) - 1
    counter = vim.current.buffer.vars['counter']
    if counter == len_total_data:
        if len_total_data >= 10:
            del vim.current.buffer[1:]
            insert_new_data = vim.current.buffer.vars['total_data'][:10]
            vim.current.buffer.vars['counter'] = 0
            vim.current.buffer.append(insert_new_data)
            vim.current.buffer[1] = '->' + vim.current.buffer[1]
            vim.current.buffer.vars['finished_search'] = 1
            return
        if len_total_data < 10:
            vim.current.buffer[1] = '->' + vim.current.buffer[1]
            vim.current.buffer[-1] = vim.current.buffer[-1][2:]
            vim.current.buffer.vars['counter'] = 0
            vim.current.buffer.vars['finished_search'] = 1
            return
    vim.current.buffer[-1] = vim.current.buffer[-1][2:]
    vim.current.buffer.vars['counter'] += 1
    vim.current.buffer.vars['finished_search'] = 1
    return


# --------------------------------------------
# Main AMT Functions
# --------------------------------------------
def amt_generate_buffer(data: list, comm_beg: str, comm_end: str) -> None:
    vim.command('belowright 11new')
    vim.command('e srch.amtsearch')
    del vim.current.buffer[:]
    vim.command('setlocal bufhidden=wipe')
    vim.command('setlocal nobuflisted')
    vim.command('setlocal noautocomplete')
    vim.command('set filetype=amtsearch')
    vim.current.buffer[0] = 'Search: '
    _fill_buffer(data)
    vim.current.buffer.vars['prev_srch'] = ''
    _generate_mappings(comm_beg, comm_end)


def amt_confirm_buffer(command: str, extras: str) -> None:
    pos_search = vim.Function('search')('^->') - 1
    cont_string = vim.current.buffer[pos_search]
    # vim.command('bw!')
    vim.command('q!')
    vim.command(command + ' ' + cont_string[2:] + ' ' + extras)


def amt_cursor_up() -> None:
    # Generar los datos del contador, los archivos visibles y los archivos totales
    search_pos = vim.Function('search')('^->', 'n') - 1
    if search_pos == 1:
        _first_row_up()
        if vim.current.buffer.vars['finished_search'] == 1:
            vim.current.buffer.vars['finished_search'] = 0
            return
    _change_tick(search_pos, search_pos - 1)
    vim.current.buffer.vars['counter'] -= 1


def amt_cursor_down() -> None:
    search_pos = vim.Function('search')('^->', 'n')
    if search_pos == len(vim.current.buffer):
        _last_row_down()
        if vim.current.buffer.vars['finished_search'] == 1:
            print(vim.current.buffer.vars['counter'])
            vim.current.buffer.vars['finished_search'] = 0
            return
    _change_tick(search_pos - 1, search_pos)
    vim.current.buffer.vars['counter'] += 1


def amt_reload_search() -> None:
    # total_data será de donde se llena el buffer
    # search_data es donde se deposita toda la data para buscar con el matchfuzzy
    word_start = 'search: '
    search_value = vim.current.buffer[0][len(word_start):].strip()
    if search_value != vim.eval('b:search_value'):
        if search_value == '':
            fuzzy_search = vim.current.buffer.vars['search_values']
        else:
            fuzzy_search = vim.eval('matchfuzzy(b:total_data, "' +
                                    search_value +
                                    '̈́", {\'limit\': 100})')
        del vim.current.buffer[1:]
        vim.current.buffer.vars['counter'] = 0
        vim.current.buffer.vars['search_data'] = search_value
        if len(fuzzy_search) <= 10:
            vim.current.buffer.append(fuzzy_search)
        else:
            vim.current.buffer.append(fuzzy_search[:10])
        if len(fuzzy_search) == 0:
            print('empty list')
            return
        vim.current.buffer.vars['search_data'] = fuzzy_search
        vim.current.buffer[1] = '->' + vim.current.buffer[1]
        vim.current.window.cursor = [1, len(vim.current.buffer[0])]


def amt_exit_buffer() -> None:
    vim.command('bw!')
    vim.command('q!')


# --------------------------------------------
# Main AMT Searchers
# --------------------------------------------
def amt_oldfiles() -> None:
    oldfiles = vim.vvars['oldfiles']
    amt_generate_buffer(oldfiles, 'e ', '')


def amt_colors() -> None:
    colors = vim.eval('getcompletion("colo ", "cmdline")')
    amt_generate_buffer(colors, 'colo ', '')


def amt_buffers() -> None:
    buffers = vim.eval('getcompletion("buffer ", "cmdline")')
    amt_generate_buffer(buffers, 'b ', '')


def start_amt_searching() -> None:
    vc = vim.command
    vc('py3 import amt.searchers as srch')
    vc('command! AMToldfiles py3 srch.amt_oldfiles()')
    vc('command! AMTcolors py3 srch.amt_colors()')
    vc('command! AMTbuffers py3 srch.amt_buffers()')
    vc('command! AMTOpenSession py3 srch.amt_session_choose_open()')
    vc('command! AMTCloseSession py3 srch.amt_close_session()')
    vc('command! AMTSaveSession py3 srch.amt_save_session()')


# --------------------------------------------
# Session aux functions
# --------------------------------------------
def _read_sessions() -> list:
    sessions_dir = vim.eval('expand(g:amt_sessions_dir)')
    sessions = vim.eval('readdir("' + sessions_dir +
                        '", {n -> n =~ \'.vim$\'})')
    return sessions


def _generate_dir_sessions() -> None:
    # Not exists directory in g:, add it
    if 'amt_sessions_dir' not in vim.vars:
        vim.vars['amt_sessions_dir'] = '~/sessions'
    # Verify directory exists
    session_dir_path = vim.eval('g:amt_sessions_dir')
    session_dir_path_ex = vim.Function('expand')(
            session_dir_path).decode('utf-8')
    verify_directory = vim.Function('isdirectory')(session_dir_path_ex)
    if verify_directory != 1:
        vim.Function('mkdir')(session_dir_path_ex, 'p')
    vim.vars['valid_session_path_exists'] = 1


def verify_session_exists() -> list:
    _generate_dir_sessions()
    aviable_sessions = _read_sessions()
    return aviable_sessions


# --------------------------------------------
# Session management commands
# --------------------------------------------
def amt_session_choose_open() -> None:
    amt_sessions = verify_session_exists()
    p1 = 'py3 srch.amt_open_session(\"'
    p2 = '\")'
    amt_generate_buffer(amt_sessions, p1, p2)
    vim.command('command! -buffer AMTConfirmSelection py3 srch.amt_open_session()')


def amt_open_session() -> None:
    pos_search = vim.Function('search')('^->') - 1
    cont_string = vim.current.buffer[pos_search][2:]
    # vim.command('bw!')
    vim.command('q!')
    session_path = vim.eval('g:amt_sessions_dir')
    vim.command(f'so {session_path}/{cont_string}')


def amt_close_session() -> None:
    vim.command('bufdo bd!')
    vim.command('let v:this_session=\'\'')
    vim.command('AMTDash')


def amt_save_session() -> None:
    _generate_dir_sessions()
    session_path = vim.eval('g:amt_sessions_dir')
    session_path_extended = vim.eval(f'expand("{session_path}")')
    session_current = vim.eval('v:this_session')
    session_current_ext = vim.eval(f'fnamemodify("{session_current}", ":h")')
    if session_current != '':
        if session_current_ext == session_path_extended:
            generated_session = vim.eval("input('Save current session? y/n')")
            if generated_session == 'y':
                vim.command(f'mks! {session_current}')
        else:
            pass_session = vim.eval("input('Session not in dir, add? y/n')")
            if pass_session == 'y':
                file_name = vim.eval(f'fnamemodify("{session_current}", ":t")')
                vim.command(f'mks  {session_path}/{file_name}')
        return
    generated_session = vim.eval("input('Save current session? y/n')")
    if generated_session == 'y':
        session_name = vim.eval('input(\'Session name: \')')
        total_path = session_path + '/' + session_name
        extended_path = vim.eval('expand("' + total_path + '")')
        verifier = vim.Function('filereadable')(extended_path)
        if verifier == 1:
            vim.command('mks! ' + session_path + '/' + session_name)
        else:
            vim.command('mks ' + session_path + '/' + session_name)
        print('session ' + session_name + ' saved in ' + session_path)
        return
