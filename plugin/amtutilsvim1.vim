" vim:set foldmethod=marker:
" vim:set nospell:
if !has('vim9script')
  finish
endif
vim9script
import autoload "nerdpickers.vim" as nerdpick

# AMT commands   {{{
command! AMTOlfiles           AMT_Open_Oldfiles()
command! AMTColors            AMT_Select_Colorscheme()
command! AMTBuffers           AMT_Select_Buffer()
command! AMTNerd              AMT_insert_nerd_glyph()
command! AMTStartSession      AMT_start_sessions()
command! AMTDeleteSessions    AMT_delete_sessions()
command! AMTSaveSession       AMT_save_session()
command! AMTCloseSession      AMT_Close_session()
# }}}
# AMT core  󰋑 {{{
def Generate_nerd_font_symbols() # {{{
  if !exists('g:amt_nerdfonts_keys')
    g:amt_nerdfonts_keys = keys(g:main_fonts)
    g:amt_symbols = []
    g:amt_nerd_display = []
    for [key, symbol] in items(g:main_fonts)
      add(g:amt_symbols, symbol["char"])
      add(g:amt_nerd_display, symbol["char"]." : ".key)
    endfor
  endif
enddef # }}}
def AMT_Cursor_Up() # {{{
  var idx_search = search('->', 'n')
  if idx_search == 2 && b:counter == 1 && b:change_values == 1
    :2,11delete
    b:counter = len(b:search_values)
    append(1, b:search_values[-1])
    setline(2, '->' .. getline(2))
    cursor(1, col('.'))
    return
  endif
  if idx_search == 2 && b:change_values == 0
    b:counter = len(b:search_values)
    setline(2, getline(2)[2 :])
    setline(line('$'), '->' .. getline('$'))
    cursor(1, col('.'))
    return
  endif
  if idx_search == 2 && line('$') < 11
    b:counter = b:counter - 1
    append(1, b:search_values[b:counter - 1])
    setline(2, '->' .. getline(2))
    setline(3, getline(3)[2 :])
    cursor(1, col('.'))
    return
  endif
  if idx_search == 2
    b:counter = b:counter - 1
    append(1, b:search_values[b:counter - 1])
    setline(2, '->' .. getline(2))
    setline(3, getline(3)[2 :])
    cursor(1, col('.'))
    return
  endif
  setline(idx_search - 1, '->' .. getline(idx_search - 1))
  setline(idx_search, getline(idx_search)[2 :])
  b:counter -= 1
  cursor(1, col('.'))
enddef # }}}
def AMT_cursor_down() # {{{
  var idx_search = search('->', 'n')
  if len(b:search_values) == b:counter && b:change_values == 0
    setline(2, '->' .. getline(2))
    setline(line('$'), getline('$')[2 :])
    b:counter = 1
    cursor(1, col('$'))
    echo ' '
    return
  elseif idx_search == 11 && b:change_values == 1
    :2delete
    append(10, b:search_values[b:counter - 1])
    setline(11, '->' .. getline(11))
    setline(10, getline(10)[2 :])
    b:counter = b:counter + 1
    cursor(1, col('$'))
    echo ' '
    return
  elseif line('$') <= 10 && idx_search == line('$') && len(b:search_values) < 10
    b:counter = 1
    # append(1, b:search_values[0 : 9])
    setline(2, '->' .. getline(2))
    setline(line('$'), getline('$')[2 :])
    cursor(1, col('$'))
    echo ' '
    return
  elseif line('$') <= 10 && idx_search == line('$')
    b:counter = 1
    :2,$delete
    append(1, b:search_values[0 : 9])
    # append(1, b:search_values[0 : 9])
    setline(2, '->' .. getline(2))
    cursor(1, col('$'))
    echo ' '
    echo 'Will append line and start new line '
    return
  endif
  setline(idx_search + 1, '->' .. getline(idx_search + 1))
  setline(idx_search, getline(idx_search)[2 :])
  b:counter = b:counter + 1
  cursor(1, col('.'))
  echo ' '
enddef # }}}
def AMT_Open_browser(list_values: list<any>, first_line: string) # {{{
  # Description: Opens the buffer filetype amtsearch {{{
  # Process: 
  # - Check if splitbelow is activated and toggle it
  # - Generate the file with the filetypes
  # - Appends the values for search and puts the general 
  # Variables_Generated:
  # - b:main_values = the whole list of values to future search
  # - b:search_values = the list according to search in the current state
  # - b:counter = the position of the current search value, starts at 1
  # - b:change_values = indicates if the values can be modified
  # }}}
  var split_setting = &splitbelow
  if !split_setting
    execute 'set splitbelow'
  endif
  :11new
  :e search.amtsearch
  if !split_setting
    execute 'set nosplitbelow'
  endif
  setlocal filetype=amtsearch modifiable nonumber norelativenumber buftype=nofile bufhidden=wipe  noswapfile nospell
  setline(1, first_line)
  b:main_values = list_values
  b:search_values = b:main_values
  b:change_values = len(b:search_values) > 10 ? 1 : 0
  var list_values_append = b:change_values == 1 ? b:main_values[0 : 9] : b:main_values
  b:counter = 1
  append(1, list_values_append)
  cursor(1, col('$'))
  setline(2, '->' .. getline(2))
enddef # }}}
def AMT_Change_Search(len_ignore: number) # {{{
  #  Verify if first line is different from the flag {{{
  if b:updating_line1 == getline(1)
    return
  endif
  # }}}"
  #  Delete lines and update{{{
  b:updating_line1 = getline(1)
  var line_result = getline(1)[len_ignore :]
  silent! execute ':2,$delete _'
  # }}}"
  #  if first line is zero, update values {{{
  if len(trim(line_result)) == 0
    b:search_values = b:main_values
    b:change_values = len(b:search_values) > 10 ? 1 : 0
    var list_values = b:change_values == 1 ? b:search_values[0 : 9] : b:search_values
    b:counter = 1
    append(1, list_values)
    setline(2, '->' .. getline(2))
    cursor(1, col('$'))
    return
  endif
  # }}}"
  #  if not, starts to search {{{
  var search_result = matchfuzzy(copy(b:main_values), line_result, {'limit': 200 })
  b:search_values = search_result
  b:change_values = len(b:search_values) > 10 ? 1 : 0
  var list_values = b:change_values == 1 ? b:search_values[0 : 9] : b:search_values
  b:counter = 1
  append(1, list_values)
  setline(2, '->' .. getline(2))
  cursor(1, col('$'))
  # }}}"
enddef # }}}
def AMT_Execute(action: string) # {{{
  var selected_value = getline(search('->', 'n'))[2 :]
  :q!
  execute action .. ' ' .. selected_value
enddef # }}}
def AMT_start_default_mappings(len_ignore: number, action: string) # {{{
  b:updating_line1 = ''
  command! -buffer AMTCursorUp AMT_Cursor_Up()
  command! -buffer AMTCursorDown AMT_cursor_down()
  execute 'command! -buffer AMTExecute AMT_Execute("' .. action .. '")'
  execute 'command! -buffer AMTChangesearch AMT_Change_Search(' .. len_ignore .. ')'
  inoremap <buffer><expr> <Backspace> col('.') > 9 && line('.') == 1 ? '<Backspace>' : ''
  inoremap <buffer><expr> <Left> col('.') > 9 ? '<Left>' : ''
  inoremap <buffer><expr> <Del> col('.') != col('$') && line('.') == 1 && col('.') > 9 ? '<Del>' : ''
  nnoremap <buffer> q :q!<CR>
  inoremap <buffer> <C-q> <Esc>:q!<CR>
  inoremap <buffer> <Up> <Esc>:AMTCursorUp<CR>:echo ' '<CR>A
  inoremap <buffer> <Down> <Esc>:AMTCursorDown<CR>:echo ' '<CR>A
  nnoremap <buffer> <Up> :AMTCursorUp<CR>:echo ' '<CR>A
  nnoremap <buffer> <Down> :AMTCursorDown<CR>:echo ' '<CR>$
  nnoremap <buffer> <CR> :AMTExecute<CR>:echo ' '<CR>
  inoremap <buffer> <CR> <Esc>:AMTExecute<CR>:echo ' '<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | execute 'AMTChangesearch' | endif
enddef # }}}
def AMT_Nerd_Glyphs() # {{{
  if !exists('g:amt_nerdfonts_keys')
    nerdpick.AMT_read_nerd_glyphs()
    g:amt_nerdfonts_keys = keys(g:main_fonts)
    g:amt_symbols = []
    g:amt_nerd_display = []
    for [key, symbol] in items(g:main_fonts)
      add(g:amt_symbols, symbol["char"])
      add(g:amt_nerd_display, symbol["char"] .. " : " .. key)
    endfor
  endif
enddef # }}}
def AMT_insert_text_nerd() # {{{
  var selected_value = trim(split(getline((search('->', 'n'))), ':')[0][2 :])
  :q!
  var cur_line = line('.')
  var cur_col = col('.')
  var line_content = getline(cur_line)
  if cur_col == 1
    setline(cur_line, line_content[0] .. selected_value .. line_content[1 :])
  elseif cur_col == col('$') - 1
    setline(cur_line, line_content .. selected_value)
  else 
    setline(cur_line, line_content[: cur_col - 1] .. selected_value .. line_content[cur_col :])
  endif
enddef # }}}
# }}}
# AMT functions   {{{
def AMT_insert_nerd_glyph() # {{{
  AMT_Nerd_Glyphs()
  AMT_Open_browser(g:amt_nerd_display, 'Search: ')
  AMT_start_default_mappings(9, '')
  #   Generate mappings {{{
  command! -buffer AMTInsertNerd AMT_insert_text_nerd()
  inoremap <buffer> <CR> <Esc>:AMTInsertNerd<CR>:echo ' '<CR>
  nnoremap <buffer> <CR> :AMTInsertNerd<CR>:echo ' '<CR>
  # }}}"
enddef # }}}
def AMT_Open_Oldfiles() # {{{
  AMT_Open_browser(v:oldfiles, 'Search: ')
  AMT_start_default_mappings(9, 'e')
enddef # }}}
def AMT_Select_Colorscheme() # {{{
  var completion_list = getcompletion('', 'color')
  AMT_Open_browser(completion_list, 'Search: ')
  AMT_start_default_mappings(9, 'colorscheme')
enddef # }}}
def AMT_Select_Buffer() # {{{
  var completion_list = getcompletion('', 'buffer')
  AMT_Open_browser(completion_list, 'Search: ')
  AMT_start_default_mappings(9, 'b')
  command! -buffer AMTInsert AMT_insert_nerd_glyph()
enddef # }}}
#  Session management {{{
def AMT_start_sessions() # {{{
  # var session_name_prev = v:this_session
  # var v:this_session = ""
  #   Verify if session folder exists {{{
  if !exists("g:amt_session_folder")
    g:amt_session_folder = '~/sessions'
  endif
  g:amt_session_folder = resolve(expand(g:amt_session_folder))
  # }}}
  #   Folder creation if not generated {{{
  if !isdirectory(expand(g:amt_session_folder))
    if input('Session folder not created, want to create? y/n') == 'y'
      mkdir(expand(g:amt_session_folder))
    endif
  endif # }}}
  # echo 'Generated folder'
  # 󰕲  Generation of list files with .vim generated{{{
  var completion_list = filter(readdir(expand(g:amt_session_folder)), 'v:val =~ "\.vim$"' )
  # echo completion_list
  # echo 'Generated list'
  # }}}
  #  start filter keys and commands {{{
  AMT_Open_browser(completion_list, 'Search: ')
  AMT_start_default_mappings(9, '')
  # echo 'Generated mappings'
  command -buffer AMTStartSes AMT_start_session(g:amt_session_folder)
  inoremap <buffer> <CR> <Esc>:AMTStartSes<CR>
  nnoremap <buffer> <CR> :AMTStartSes<CR>
  # echo 'Success'
  # }}}
enddef # }}}
def AMT_delete_sessions() # {{{
  #   Verify if session folder exists {{{
  if !exists("g:amt_session_folder")
    g:amt_session_folder = '~/sessions'
  endif
  g:amt_session_folder = resolve(expand(g:amt_session_folder))
  # }}}
  #   Folder creation if not generated {{{
  if !isdirectory(expand(g:amt_session_folder))
    if input('Session folder not created, want to create?\n y/n') == 'y'
      mkdir(expand(g:amt_session_folder))
    endif
  endif # }}}
  # 󰕲  Generation of list files with .vim generated{{{
  var completion_list = filter(readdir(expand(g:amt_session_folder)), 'v:val =~ "\.vim$"' )
  # echo completion_list
  # }}}
  #  start filter keys and commands {{{
  AMT_Open_browser(completion_list, 'Search: ')
  AMT_start_default_mappings(9, '')
  command! buffer AMTDeleteSession AMT_delete_session()
  nnoremap <buffer> <CR> :AMTDeleteSession<CR>
  inoremap <buffer> <CR> <Esc>:AMTDeleteSession<CR>
  # }}}
enddef # }}}
def AMT_delete_session() # {{{
  var file_name = getline( search('->', 'n') )[2:]
  delete(g:amt_session_folder.'/'.file_name)
  echo " "
  echo 'Session ' . file_name . ' deleted'
  AMT_Change_Search(9)
enddef # }}}
def AMT_create_session() # {{{
  var session_name = input('Session name: ')
  var session_path = resolve(expand(g:amt_session_folder)) . '/' . session_name
  execute 'mks! ' .. session_path
  echo ''
  echo 'Session ' .. session_path .. ' saved'
enddef # }}}
def AMT_save_session() # {{{
  #   Generate session if not loaded {{{
  g:amt_session_folder = resolve(expand(g:amt_session_folder))
  if len(v:this_session) == 0
    var save_session = input('Not a session loaded, Save? (y/n) ')
    if save_session == 'y'
      save_session = input('Session name: ')
      var prev_pos = getcwd()
      execute 'cd'
      execute 'mks!' .. expand(g:amt_session_folder) .. '/' .. save_session
      execute 'cd ' .. prev_pos
      return
    else
      echo 'Not a valid option'
      return
    endif
  # }}}
  # Move to the AMT folder 󰛂 {{{
  elseif fnamemodify(v:this_session, ":h") != expand(g:amt_session_folder)
    var save_in_folder = input('Session not in folder session, Save it? (y/n): ')
    if save_in_folder == 'y'
      var prev_pos = getcwd()
      execute 'cd'
      var file_name = expand(g:amt_session_folder) .. '/' .. fnamemodify(v:this_session, ":t")
      execute 'mks!' .. file_name
      execute 'cd ' .. prev_pos
    endif
  # }}}
  else
  #   save session {{{
    var prev_pos = getcwd()
    execute "cd"
    execute "mks! " .. v:this_session
    execute 'cd ' .. prev_pos
  endif
  # }}}
enddef # }}}
def AMT_Close_session() # {{{
  v:this_session = ""
  :bufdo! bw!
  execute 'AMTDash'
enddef # }}}
def AMT_start_session(path_sessions: string) # {{{
  var search_result = getline(search('->', 'n'))[2 :]
  :q!
  execute   'so ' .. expand( path_sessions ) .. '/' .. search_result
enddef # }}}
# }}}
# }}}
