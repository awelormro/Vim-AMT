def start_amt():
    import vim
    from amt.searchers import start_amt_searching
    from amt.movefiles import movefiles_start
    from amt.autopairs import auto_pair_start
    movefiles_start()
    amt_simple()
    vim.vars['pair_start'] = 0
    auto_pair_start()
    start_amt_searching()


def amt_simple():
    print('start AMT, be happy')
