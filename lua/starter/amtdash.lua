vim = vim
local M = {}

-- or not vim.v.progname:match('^[-gmnq]?vimx?%.exe$')
function M.dash_start()
  -- Condicional original en Vimscript convertida a Lua
  if vim.fn.argc() > 0
    or vim.fn.line2byte('$') ~= -1
    or vim.o.insertmode then
    return
  end
  vim.cmd.enew()
  -- vim.cmd('enew')
  local vimsize = vim.fn.winwidth('%')
  vim.cmd('setlocal tw=' .. vimsize)
  vim.cmd('set filetype=amtdash')
  M.generate_header()
  M.Dash_add_commands()
  if vim.fn.exists('g:amt_dash_centering') then
    vim.g.amt_dash_centering = 1
  end
  if vim.g.amt_dash_centering == 1 then
    vim.cmd('%center')
  end
  vim.opt_local.modifiable = false
  vim.opt_local.modified = false
  vim.fn.cursor(vim.b.dash_command_start, 0)
  vim.fn.search('[[')
  local row = vim.fn.line('.')
  local col = vim.fn.col('.')
  vim.fn.cursor(row, col + 3)
end


function M.generate_header()
  vim.opt_local.filetype = 'amtdash'
  local asciiaux = {
         ' $$$$$$\\  $$\\      $$\\ $$$$$$$$\\ $$\\    $$\\ $$$$$$\\ $$\\      $$\\ ',
         '$$  __$$\\ $$$\\    $$$ |\\__$$  __|$$ |   $$ |\\_$$  _|$$$\\    $$$ |',
         '$$ /  $$ |$$$$\\  $$$$ |   $$ |   $$ |   $$ |  $$ |  $$$$\\  $$$$ |',
         '$$$$$$$$ |$$\\$$\\$$ $$ |   $$ |   \\$$\\  $$  |  $$ |  $$\\$$\\$$ $$ |',
         '$$  __$$ |$$ \\$$$  $$ |   $$ |    \\$$\\$$  /   $$ |  $$ \\$$$  $$ |',
         '$$ |  $$ |$$ |\\$  /$$ |   $$ |     \\$$$  /    $$ |  $$ |\\$  /$$ |',
         '$$ |  $$ |$$ | \\_/ $$ |   $$ |      \\$  /   $$$$$$\\ $$ | \\_/ $$ |',
         '\\__|  \\__|\\__|     \\__|   \\__|       \\_/    \\______|\\__|     \\__|',
  }
  local asciiheader = asciiaux
  if vim.fn.exists('g:amt_dashboard_ascii') == 1 then
    asciiheader = vim.g.amt_dashboard_ascii
  end
  vim.fn.setline(1, '{{{')
  vim.fn.append(1, asciiheader)
  vim.fn.append('$', '}}}')
end

function M.generate_dash_variables()
  local i = 1
  local len_dict_keys = #vim.b.commandkeys
  local map_list = {}
  local command_list = {}
  local glyph_list = {}
  local desc_list = {}
  local max_len_desc_str = 0
  local max_len_command_str = 0
  local max_len_map_str = 0
  while i < len_dict_keys do
    if vim.b.commandkeys[i].glyph == nil then
      table.insert(glyph_list, '-1')
    else
      table.insert(glyph_list, vim.b.commandkeys[i]['glyph'])
    end
    if vim.b.commandkeys[i].desc == nil then
      table.insert(desc_list, '-1')
    else
      table.insert(desc_list, vim.b.commandkeys[i]['desc'])
      if #vim.b.commandkeys[i]['desc'] > max_len_desc_str then
        max_len_desc_str = #vim.b.commandkeys[i]['desc']
      end
    end
    if vim.b.commandkeys[i].command == nil then
      table.insert(command_list, '-1')
    else
      table.insert(command_list, vim.b.commandkeys[i]['command'])
      if #vim.b.commandkeys[i]['command'] > max_len_command_str then
        max_len_command_str = #vim.b.commandkeys[i]['command']
      end
    end
    if vim.b.commandkeys[i].map == nil then
      table.insert(map_list, '-1')
    else
      table.insert(map_list, vim.b.commandkeys[i]['map'])
      if #vim.b.commandkeys[i]['map'] > max_len_map_str then
        max_len_map_str = #vim.b.commandkeys[i]['map']
      end
    end
    i = i + 1
  end
  i = 1
  vim.fn.append('$', '  ')
  vim.b.dash_command_start = vim.fn.line('$') + 1
  local map_prev = 'nnoremap <buffer><silent> '
  local len_commandkeys = #vim.b.commandkeys
  vim.b.max_len_map_str = max_len_map_str
  vim.b.max_len_command_str = max_len_command_str
  vim.b.max_len_map_str = max_len_map_str
  local map_str = ''
  local desc_str = ''
  local glyph_str = ''
  while i < len_commandkeys do
    if map_list[i] ~= '-1' and command_list[i] ~= '-1' then
      vim.cmd('exe "' .. map_prev .. map_list[i] .. ' :' .. command_list[i] .. '<CR>"')
    end
    if map_list[i] ~= '-1' then
      map_str = '[[' .. map_list[i] .. string.rep(' ', max_len_map_str + 1 - #map_list[i]) .. ']]'
    else
        map_str = '[[' .. string.rep(' ', max_len_map_str + 1) ..  ']]'
    end
    if glyph_list[i] ~= '-1' then
      glyph_str = '((' .. glyph_list[i] .. ' ))'
    else
      glyph_str = '((  ))'
    end
    if desc_list[i] ~= '-1' then
      desc_str = '([' .. desc_list[i] .. string.rep(' ', max_len_desc_str - #desc_list[i]) .. ' ])'
    else
      desc_str = '([  ])'
    end
    local line_append = glyph_str .. ' ' .. map_str .. ' ' .. desc_str
    vim.fn.append('$', line_append)
    i = i + 1
  end
end

function M.Dash_add_commands()
  if vim.b.amt_dash_keys == nil then
    vim.b.amt_dash_keys = {
      {map = 'e', command = 'enew', glyph = '󰈔', desc = 'New file' },
      {map = 'i', command = 'enew <bar> startinsert', glyph = '', desc = 'New File in Insert mode' },
      {map = 'rf', command = 'AMToldfiles', glyph = '', desc = 'Recent files' },
      {map = 'sm', command = 'AMTStartSession', glyph = '', desc = 'Session manager' },
      {map = 'fm', command = 'Lexplore', glyph = '', desc = 'File Explorer' },
      {map = 'q', command = 'quit', glyph = '󰩈', desc = 'Exit vim' },
    }
    vim.b.commandkeys = vim.b.amt_dash_keys
  else
    vim.b.commandkeys = vim.g.amt_dashboard_keys
  end
  M.generate_dash_variables()
end

function M.Dash_move_cursor_up()
  local idx_row = vim.fn.line('.')
  if idx_row == vim.b.dash_command_start then
    vim.fn.cursor(vim.fn.line('$'), vim.fn.col('.'))
  else
    vim.fn.cursor( vim.fn.line('.') - 1, vim.fn.col('.') )
  end
end

function M.Dash_move_cursor_down()
  local idx_row = vim.fn.line('.')
  if idx_row == vim.fn.line('$') then
    vim.fn.cursor(vim.b.dash_command_start, vim.fn.col('.'))
  else
    vim.fn.cursor(vim.fn.line('.') + 1, vim.fn.col('.'))
  end
end

function M.Dash_execute_command()
  local command_line = vim.fn.line('.')
  local command_execute = vim.b.commandkeys[command_line - vim.b.dash_command_start]['command']
  vim.fn.execute(command_execute)
end
return M
