import vim


def generate_mapping(kind, mapping, action, opts):
    a = kind  # Check if normal, insert, etc.
    args = ''
    if a == 'm':
        st = 'map '
    elif a == 'n':
        st = 'nnoremap '
    elif a == 'v':
        st = 'vnoremap '
    elif a == 'i':
        st = 'inoremap '
    elif a == 'x':
        st = 'xnoremap'
    elif a == 'c':
        st = 'cnoremap '
    elif a == 's':
        st = 'snoremap '
    if opts['buffer']:
        args += '<buffer>'
    if opts['silent']:
        args += '<silent>'
    if opts['expr']:
        args += '<expr>'
    args = ' ' + args + ' '
    command = st + args + action
    vim.command(command)


def generate_command():
    pass


def import_command_library():
    pass
