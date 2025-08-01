local M = {}

vim = vim

local is_nvim = vim.fn.has('nvim') == 1

M.cmd = is_nvim and vim.cmd or vim.command
M.b_content = is_nvim and vim.api.nvim_buf_get_lines(0,0,-1,false) or vim.buffer()
M.b_currline = is_nvim and vim.api.nvim_get_current_line() or vim.fn.getline('.')
M.b_cursorpos = is_nvim and vim.api.nvim_win_get_cursor(0) or {vim.fn.line('.'), vim.fn.col('.')}

M.gen_cmd = function(command)
  if is_nvim then
    return vim.cmd(command)
  else
    return vim.command(command)
  end
end

M.get_bcontent = function()
  if is_nvim then
    return vim.api.nvim_buf_get_lines(0,0,-1,false)
  else
    return vim.buffer()
  end
end

M.gen_mapping = function(mode, lhs, rhs, opts)
  if is_nvim then
    return vim.keymap.set(mode, lhs, rhs, opts)
  else
    print('not aviable until update, at the moment use one of the other cores')
  end
end

M.gen_map_vim = function(mode, lhs, rhs, opts)
  local a = '' -- decide if is normal, visual or mixed
  local b = lhs -- decide mapping
  local c = rhs -- decide commands
  local d = opts -- decide extra args, such as expr, buffer, etc

  if mode == 'n' then
    a = 'nnoremap'
  elseif mode == 'i' then
    a = 'inoremap'
  elseif mode == 'v' then
    a = 'vnoremap'
  elseif mode == 'x' then
    a = 'xnoremap'
  else
    a = 'nnoremap'
  end
  return a .. ' ' .. b ' ' .. ' ' .. c .. ' ' .. d
end

M.gen_user_command = function(name, command, opts)
  if is_nvim then
    vim.api.nvim_create_user_command(name, command, opts)
  else
    print('not aviable yet, try another framework')
  end

end

M.gen_command_vim = function(name, command, opts)
  local a = ''
  if opts['bang'] then
    a = a .. ' -bang '
  end
  if opts['bar'] then
    a = a .. ' -bar'
  end
  return 'command! ' .. name .. ' '.. a .. ' ' .. command 
end

M.gen_autocmd_vim = function(event, opts)
  return event .. opts
end

return M
