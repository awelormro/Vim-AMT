import vim
import re
import os


def vim_search(search: str, args: str = ''):
    cont_buffer = vim.current.buffer[:]
    exp = re.compile(search)
    i = vim.current.window.cursor[0]
    if 'b' in args:
        srch_follow = -1
        last_path = 0
    else:
        srch_follow = 1
        last_path = len(cont_buffer) - 1
    if srch_follow == 1:
        while i < last_path:
            if exp.match(cont_buffer[i]):
                return i
            else:
                i += 1
    else:
        while i >= 0:
            if exp.match(cont_buffer[i]):
                return i
            else:
                i -= 1
    pass


def vim_replace(prev, post, str_replace):
    pass


def generate_docx_file():
    pass
