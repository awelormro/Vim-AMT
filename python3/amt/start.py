def start_amt():
    import vim
    from amt.finders import amt_finders_start
    from amt.movefiles import movefiles_start
    from amt.autopairs import auto_pair_start
    amt_finders_start()
    movefiles_start()
    amt_simple()
    vim.vars['pair_start'] = 0
    auto_pair_start()


def amt_simple():
    print('start AMT, be happy')
