if !has('vim9script')
  finish
endif
vim9script

export def AMT_Buffer_start()
enddef

def AMT_Fill_buffer(data: list<any>, header: string, header_aux: string)
  var len_data = len(data)
  b:total_data = data
  b:search_data = data
  b:finished_search = 0
  b:first_search_value = 2
  if len_data <= 10
    b:buffer_data = data
  else
    b:buffer_data = data[0 : 10]
  endif
  if len(header_aux) > 0
    b:first_search_value = 3
    append(1, header_aux)
  endif
  var data_fill = b:buffer_data
  append(b:first_search_value - 1, data_fill)
  b:counter = 0
  b:search_value = ''
  setline(b:first_search_value, '->' .. getline(b:first_search_value))
  cursor(1, col('$'))
enddef

def AMT_Aux_generate_mappings(comm_start: string, comm_end: string)
  command! -buffer AMTCursorUp call <SNR>AMT_Cursor_up()
  command! -buffer AMTCursorDown call <SNR>AMT_cursor_down()
  command! -buffer AMTChangeSearch call <SNR>AMT_reload_Search()
  command! -buffer AMTConfirmSelection call <SNR>AMT_confirm_buffer(comm_start, comm_end)
  command! -buffer AMTExit :q!<CR>
  autocmd TextChangedI *.amtsearch execute 'AMTChangeSearch'
enddef

def AMT_Aux_change_tick(line_prev: number, line_new: number)
  setline(line_prev, getline(line_prev[2 :]))
  setline(line_new, '->' .. getline(line_new))
enddef

def AMT_aux_first_row_up()
  var len_total_data =  len(b:total_data)
  if len_total_data == 1
    b:finished_search = 1
    return
  endif
  if b:counter == 0
    if len_total_data <= 10
      AMT_Aux_change_tick(b:first_search_value, '$')
      b:counter = len_total_data
      b:finished_search = 1
      return
    endif
    deletebufline('%', b:first_search_value, '$')
    b: counter = len_total_data - 1
    var new_pos = b:counter - 1
    append(b:first_search_value - 1, b:total_data[new_pos])
    setline(b:first_search_value, '->' .. getline(b:first_search_value))
    b:finished_search = 1
    return
  endif
  len_total_buffer = getline('$')
  if len_total_buffer > 10
    if len_total_buffer > 11
      var new_pos = b:counter - 1
      var new_line = '->' .. b:total_data[new_pos]
      call append(1, new_line)
      b:counter b:counter - 1
      b:finished_search = 1
      return
    endif
    if len_total_buffer == 11
      deletebufline('%', '$')
      var new_pos = b:counter - 1
      var new_line = b:total_data[new_pos]
      append(b:first_search_value, new_line)
      b:counter = new_pos
      b:finished_search = 1
      return
    endif
  endif
  if len_total_buffer < 11
    var new_pos = b:counter - 1
    var new_line = '->' .. b:total_data[new_pos]
    append(b:first_search_value - 1, new_line)
    b:counter -= 1
    b:finished_search = 1
    return 
  endif
  AMT_Aux_change_tick(b:first_search_value, line('$'))
  b:finished_search = 1
  b:counter -= 1
enddef

def AMT_aux_last_row_down()
  var len_total_data = len(b:total_data) - 1
  if b:counter == len_total_data
    if len_total_data >= 10
      deletebufline('%', b:first_search_value, '$')
      var insert_new_data = b:total_data[:10]
      b:counter = 0
      append(b:first_search_value - 1, insert_new_data)
      setline(b:first_search_value, '->' .. getline(b:first_search_value))
      return
    elseif len_total_data < 10
      setline(b:first_search_value, '->' .. getline(b:first_search_value))
      setline('$', getline('$')[2:])
      b:counter = 0
      b:finished_search = 1
      return
    endif
  endif
  deletebufline('%', 2)
  setline('$', getline('$')[2:])
  b:counter = b:counter + 1
  var new_append = '->' .. b:total_data[b:counter]
  call append('$', new_append)
  let b:finished_search = 1
  return
enddef

def Amt_generate_buffer(data: list<any>, comm_beg: string, comm_end: string, header_aux: string)
  :belowright 11new
  :e ~/srch.amtsearch
  deletebufline('%', 1, '$')
  setlocal bufhidden=wipe nobuflisted noautocomplete filetype=amtsearch
  setline(1, 'Search: ')
  AMT_Fill_buffer_data(data, header)
  b:prev_srch = ''
  AMT_aux_generate_mappings(comm_beg, comm_end)
enddef

def AMT_Confirm_buffer(command: string, extras: string)
  var pos_search  = search('^->')
  var cont_string = getline(pos_search)
  :q!
  execute(command .. ' ' .. cont_string[2 :]ii .. ' ' .. extras)
enddef

export def AMT_Cursor_up()
  var search_pos = search('^->', 'n')
  if search_pos == b:first_search_value
    AMT_aux_first_row_up()
    if b:finished_search == 1
      b:finished_search = 0
      return
    endif
  endif
  AMT_Aux_change_tick(search_pos, search_pos - 1)
  b:counter -= 1
enddef

export def AMT_Cursor_down()
  var search_pos = search('^->', 'n')
  if search_pos == line('$')
    AMT_aux_last_row_down()
    if b:finished_search == 1
      b:finished_search = 0
      return
    endif
  endif 
  AMT_Aux_change_tick(search_pos, search_pos + 1)
  b:counter += 1
enddef

export def AMT_reload_Search()
  var word_start = 'Search: '
  var search_value = trim(getline(1)[len(word_start):])
  var fuzzy_search: list<any> 
  if search_value != b:search_value
    if search_value == ''
      fuzzy_search = b:search_values
    else
      fuzzy_search = matchfuzzy(b:total_data, search_value, { 'limit': 100 })
    endif
    deletebufline('%', b:first_search_value, '$')
    b:counter = 0
    if len(fuzzy_search) == 0
      return
    endif
    if len(fuzzy_search) <= 10
      append('$', fuzzy_search)
    else
      append('$', fuzzy_search[:10])
    endif
    b:search_data = fuzzy_search
    setline(b:first_search_value, '->'.getline(b:first_search_value))
    cursor(1, col('$'))
  endif
enddef

export def AMT_insert_nerd()
  var search_line = search('^->', 'n')
  var split_line = split(getline(search_line), '-')
  var cont_line = split_line[0][1 :]
  :bw!
  var curr_line_content = getline('.')
  var curr_line_num = line('.')
  var curr_pos = col('.')
  var new_line_content: string
  if curr_pos == 0
    new_line_content = cont_line.curr_line_content
  elseif curr_pos == col('$')
    new_line_content = curr_line_content .. cont_line
  else
    new_line_content = curr_line_content[: curr_pos - 1].cont_line .. curr_line_content[curr_pos:]
  endif 
  setline(curr_line_num, new_line_content)
enddef

export def AMT_Nerd()
  var root_path = fnamemodify(g:amt_json_nerdpicker_file_root, ':h')
  var simple_header = root_path . '/autoload/glifos_simples.txt'
  var nerd_file = readfile(simple_header)
  # echo nerd_file
  Amt_generate_buffer(nerd_file, 'call AMT_insert_nerd()', '')
  command! -buffer AMTConfirmSelection call AMT_insert_nerd()
enddef

export def AMT_Searching_file(path_search: string)
  var path: string
  if a:0 > 0 && !empty(a:1)
    path = expand(path_search)
    if !isdirectory(path)
      path = fnamemodify(path, ':p:h')
    endif
    if !isdirectory(path)
      return []
    endif
  else
    path = getcwd()
  endif
  echo path
  path_content = readdir(path)
  path_content
endfunction
command! -nargs=? AMTFileExplorer call AMT_Searching_file(<q-args>)
enddef
