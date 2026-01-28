import vim


def amt_nrrow_part(line_start, line_end):
    section_nrrow = vim.current.buffer[line_start:line_end]
    ftype = vim.eval("&filetype")
    amt_nrrow_open(section_nrrow, ftype)


def amt_nrrow_open(section_nrrow, ftype):
    vim.command(':enew')
    vim.current.buffer.append(section_nrrow, 0)
    vim.command("set filetype=" + ftype + ".amtnrrow")
