import vim

vim.vars['last_chars'] = ''


def mini_sneak_jump(forward=True, number_chars=2):
    vf = vim.Function
    viv = vim.vars
    ch1 = vf('nr2char')(vf('getchar')())
    if number_chars == 2:
        ch2 = vf('nr2char')(vf('getchar')())
        ch1 += ch2
    viv['last_chars'] = ch1.decode('utf-8')
    mini_sneak_repeat(True)
    return


def mini_sneak_repeat(forward=True):
    if vim.vars['last_chars'] == '':
        return
    if forward:
        vim.Function('search')(vim.vars['last_chars'],
                               'W')
    else:
        vim.Function('search')(vim.vars['last_chars'],
                               'bW')
    return


def movefiles_start():
    vc = vim.command
    vc('py3 import amt.movefiles as mv')
    vc('map <silent> <Plug>amt_sneak_s :py3 mv.mini_sneak_jump(True, 2)<CR>')
    vc('map <silent> <Plug>amt_sneak_S :py3 mv.mini_sneak_jump(False, 2)<CR>')
    vc('map <silent> <Plug>amt_sneak_f :py3 mv.mini_sneak_jump(True, 1)<CR>')
    vc('map <silent> <Plug>amt_sneak_F :py3 mv.mini_sneak_jump(False, 1)<CR>')
    vc('map <silent> <Plug>amt_sneak_nxt :py3 mv.mini_sneak_repeat(True)<CR>')
    vc('map <silent> <Plug>amt_sneak_prv :py3 mv.mini_sneak_repeat(False)<CR>')
    vc('nnoremap s <Plug>amt_sneak_s')
    vc('nnoremap S <Plug>amt_sneak_S')
    vc('nnoremap f <Plug>amt_sneak_f')
    vc('nnoremap F <Plug>amt_sneak_F')
    checker = True if 'remap_semicolon' in vim.vars else False
    if not checker:
        # TODO: Check the syntax
        vc('nnoremap ; <Plug>amt_sneak_nxt')
    vc('nnoremap , <Plug>amt_sneak_prv')
    return



def amt_easy_motion():
    # TODO: Generate a function to overpass and insert all
    pass
