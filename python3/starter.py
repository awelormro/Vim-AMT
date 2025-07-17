def start():
    import vim
    print('python core started')
    vim.vars['amt_core_python'] = 1
    vim.command("py3 import amtfinders")
    vim.command("py3 amtfinders.start()")
