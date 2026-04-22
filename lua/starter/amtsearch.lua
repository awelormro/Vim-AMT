local M = {}

local function slice(t, startidx, endidx)
  local result = {}
  local start_idx = startidx or 1
  local end_idx = endidx or #t
  for i = start_idx, end_idx do
    table.insert(result, t[i])
  end
  return result
end

M.generate_extensions = function()
  vim.g.amt_search_file_extensions = {
    'wav', 'mp3', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt',
    'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp',
    'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v',
    'ogg', 'flac', 'aac', 'm4a', 'wma',
    'zip', 'tar', 'gz', 'bz2', 'xz', '7z', 'rar', 'iso',
    'exe', 'msi', 'bin', 'appimage', 'deb', 'rpm', 'dmg',
    'dwg', 'dxf',
    'ttf', 'otf', 'woff', 'woff2',
    'db', 'sqlite', 'mdb', 'accdb',
    'epub', 'mobi', 'azw3'
  }
  vim.g.amt_json_nerdpicker_file_root = vim.fn.expand("<sfile>:h:p")
end

M.AMT_Fill_buffer_data = function(data)
  local len_data = #data
  vim.b.total_data = data
  vim.b.search_data = data
  vim.b.finished_search = 0
  if len_data <= 10 then
    vim.b.buffer_data = data
  else
    vim.b.buffer_data = data:sub(1, 10)
  end
  local data_fill = vim.b.buffer_data
  vim.fn.append(1, data_fill)
  vim.b.search_value = ''
  vim.fn.setline(2, '->' .. vim.fn.getline(2))
  vim.fn.cursor(1, vim.fn.col('$'))
end

M.AMT_aux_generate_mappings = function(comm_start, comm_end)

end

local function AMT_aux_change_tick(line_prev, line_new)
  vim.fn.setline(line_prev, vim.fn.getline(line_prev):sub(3))
  vim.fn.setline(line_new, '->' .. vim.fn.getline(line_new))
end

M.AMT_aux_first_row_up = function()
  local len_total_data = #vim.b.total_data
  if len_total_data == 1 then
    vim.b.finished_search = 1
    return
  end
  if vim.b.counter == 0 then
    if len_total_data <= 10 then
      AMT_aux_change_tick(2, '$')
      vim.b.counter = len_total_data - 1
      vim.b.finished_search = 1
      return
    end
    vim.fn.deletebufline( '%', 2, '$' )
    vim.b.counter = len_total_data - 1
    local new_pos = vim.b.counter
    vim.fn.append( 1, vim.b.total_data:sub(new_pos) )
    vim.fn.append(2, '->' .. vim.fn.getline(2))
    vim.b.finished_search = 1
    return
  end
  local len_total_buffer = vim.fn.getline('$')
  if len_total_buffer > 10 then
    if len_total_buffer > 11 then
      local new_pos = vim.b.counter
      local new_line = '->' .. vim.b.total_data:sub(new_pos)
      vim.fn.append(1, new_line)
      vim.b.counter = vim.b.counter - 1
      vim.b.finished_search = 1
      return
    elseif len_total_buffer == 11 then
      vim.fn.deletebufline('%', '$')
      local new_pos = vim.b.counter - 1
      local new_line vim.b.total_data:sub(new_pos)
      vim.fn.append(1, new_line)
      vim.b.counter = new_pos
      vim.b.finished_search = 1
      return
    end
  end
  AMT_aux_change_tick(1, vim.fn.line('$') )
  vim.b.finished_search = 1
  vim.b.counter = vim.b.counter - 1
end

M.AMT_aux_last_row_down = function()
  local len_total_data = #vim.b.total_data
  if vim.b.counter == len_total_data then
    if len_total_data >= 10 then
      vim.fn.deletebufline('%', 2, '$')
      local insert_new_data = slice(vim.b.total_data, 1, 10)
      vim.b.counter = 1
      vim.fn.append(1, insert_new_data)
      vim.fn.setline(2, '->' .. vim.fn.getline(2))
      return
    elseif len_total_data < 10 then
      vim.fn.setline(2, '->' .. slice(vim.fn.getline(2), 3, #vim.fn.getline(2)))
      vim.b.counter = 0
      vim.b.finished_search = 1
      return
    end
  end
  vim.fn.deletebufline('%', 2)
  local ln = vim.fn.getline(2)
  vim.fn.setline('$', require('utils.slice')(ln, 2, #ln))
  vim.b.counter = vim.b.counter + 1
  local new_append = '->' .. vim.b.total_data:sub(vim.b.counter)
  vim.fn.append('$', new_append)
  vim.b.finished_search = 1
  return
end

M.AMT_generate_buffer = function(data, comm_beg, comm_end)
  vim.cmd(':belowright 11new')
  vim.cmd(':e ~/srch.amtsearch')
  vim.fn.deletebufline('%', 1, '$')
  vim.cmd('setlocal bufhidden=wipe nobuflisted noautocomplete filetype=amtsearch')
  vim.fn.setline(1, 'Search: ')
  require('amtsearch').AMT_Fill_buffer_data(data)
  vim.b.prev_srch = ''
  require('amtsearch').AMT_aux_generate_mappings(comm_beg, comm_end)
end

M.AMT_confirm_buffer = function(command, extras)
  local pos_search = vim.fn.search('^->')
  local cont_string = vim.fn.getline(pos_search)
  vim.cmd(':q!')
  local new_line = require('utils').slice(cont_string, 2, #cont_string)
  vim.cmd(command .. ' ' .. new_line .. ' ' .. extras)
end

M.AMT_cursor_up = function()
  local search_pos = vim.fn.search('^->', 'n')
  if search_pos == 2 then
    M.AMT_aux_first_row_up()
    if vim.b.finished_search == 1 then
      vim.b.finished_search = 0
      return
    end
  end
  M.AMT_aux_change_tick(search_pos, search_pos - 1)
  vim.b.counter = vim.b.counter - 1
end

M.AMT_cursor_down = function()
  local search_pos = vim.fn.search('^->', 'n')
  if search_pos == vim.fn.line('$') then
    M.AMT_aux_last_row_down()
    if vim.b.finished_search == 1 then
      vim.b.finished_search = 0
      return
    end
  end
  M.AMT_aux_change_tick(search_pos, search_pos + 1)
  vim.b.counter = vim.b.counter + 1
end


M.AMT_reload_Search = function()
  local word_start = 'Search: '
  local search_value = require'utils'.trim(require('utils').slice(vim.fn.getline(1), #word_start, #vim.fn.getline(1)))
  local fuzzy_search = {}
  if search_value ~= vim.b.search_values then
    if search_value == '' then
      fuzzy_search = vim.b.search_values
    else
      fuzzy_search = vim.fn.matchfuzzy(vim.b.total_data, search_value, { 'limit' = 100 })
    end
    vim.fn.deletebufline('%', 2, '$')
    vim.b.counter = 0
    if #fuzzy_search == 0 then
      return
    end
    if #fuzzy_search <= 10 then
    end
  end
end
return M
