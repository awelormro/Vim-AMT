if has('vim9script')
  finish
endif
" AMT commands   {{{
command! AMToldfiles call AMT_start_Oldfiles()
command! AMTColors call AMT_start_colors()
command! AMTBuffers call AMT_start_buffers()
command! AMTCommands call AMT_start_commands()
command! AMTNerd call AMT_start_nerdpicker()
command! AMTSessions call AMT_start_sessions()
command! AMTClosesession call AMT_close_session()
command! AMTSaveSession call AMT_save_session()
command! AMTDeleteSession call AMT_delete_sessions()
command! AMTCreateSession call AMT_create_session()
" }}}
" AMT core  󰋑 {{{
function! AMT_start_default_mappings() "{{{
  inoremap <buffer><expr> <Backspace> col('.') > 9 && line('.') == 1 ? '<Backspace>' : ''
  inoremap <buffer><expr> <Left> col('.') > 9 ? '<Left>' : ''
  inoremap <buffer><expr> <Del> col('.') != col('$') && line('.') == 1 && col('.') > 9 ? '<Del>' : ''
  nnoremap <buffer> q :q!<CR>
  let b:updating_line1 = ''
  inoremap <buffer> <C-q> <Esc>:q!<CR>
  inoremap <buffer> <Up> <Esc>:call AMT_Cursor_Up()<CR>:echo ' '<CR>A
  inoremap <buffer> <Down> <Esc>:call AMT_Cursor_Down()<CR>:echo ' '<CR>A
  nnoremap <buffer> <Up> :call AMT_Cursor_Up()<CR>:echo ' '<CR>$
  nnoremap <buffer> <Down> :call AMT_Cursor_Down()<CR>:echo ' '<CR>$
endfunction " }}}
function! AMT_Cursor_Up() " {{{
  let idx_search = search('->', 'n')
  if idx_search == 2 && b:counter == 1 && b:change_values == 1
    :2,11delete
    let b:counter = len(b:search_values)
    call append(1, b:search_values[-1])
    call setline(2, '->'.getline(2))
    call cursor(1, col('.'))
    return
  endif
  if idx_search == 2 && b:change_values == 0
    let b:counter = len(b:search_values)
    call setline(2, getline(2)[2:])
    call setline(line('$'), '->'.getline('$'))
    call cursor(1, col('.'))
    return
  endif
  if idx_search == 2 && line('$') < 11
    let b:counter = b:counter - 1
    call append(1, b:search_values[b:counter - 1])
    call setline(2, '->'.getline(2))
    call setline(3, getline(3)[2:])
    call cursor(1, col('.'))
    return
  endif
  if idx_search == 2
    let b:counter = b:counter - 1
    call append(1, b:search_values[b:counter - 1])
    call setline(2, '->'.getline(2))
    call setline(3, getline(3)[2:])
    call cursor(1, col('.'))
    return
  endif
  call setline(idx_search - 1, '->'.getline(idx_search - 1))
  call setline(idx_search, getline(idx_search)[2 :])
  let b:counter = b:counter - 1
  call cursor(1, col('.'))
endfunction " }}}
function! AMT_Cursor_Down() " {{{
  let idx_search = search('->', 'n')
  if len(b:search_values) == b:counter && b:change_values == 0
    call setline(2, '->' . getline(2))
    call setline(line('$'), getline('$')[2:])
    let b:counter = 1
    call cursor(1, col('$'))
    echo ' '
    return
  elseif idx_search == 11 && b:change_values == 1
    :2delete
    call append(10, b:search_values[b:counter - 1])
    call setline(11, '->'.getline(11))
    call setline(10, getline(10)[2 :])
    let b:counter = b:counter + 1
    call cursor(1, col('$'))
    echo ' '
    return
  elseif line('$') <= 10 && idx_search == line('$')
    let b:counter = 1
    " call append(1, b:search_values[0:9])
    call setline(2, '->'.getline(2))
    call setline(line('$'), getline('$')[2:])
    call cursor(1, col('$'))
    echo ' '
    echo 'Will append line and start new line '
    return
  endif
  call setline(idx_search + 1, '->'.getline(idx_search + 1))
  call setline(idx_search, getline(idx_search)[2 :])
  let b:counter = b:counter + 1
  call cursor(1, col('.'))
  echo ' '
endfunction " }}}
function! AMT_Change_Search(len_ignore) abort " {{{
  "  Verify if first line is different from the flag {{{
  if b:updating_line1 == getline(1)
    return
  endif
  " }}}"
  "  Delete lines and update{{{
  let b:updating_line1 = getline(1)
  let line_result = getline(1)[a:len_ignore :]
  silent! execute ':2,$delete _'
  " }}}"
  "  if first line is zero, update values {{{
  if len(trim(line_result)) == 0
    let b:search_values = b:main_values
    let b:change_values = len(b:search_values) > 10 ? 1 : 0
    let list_values = b:change_values == 1 ? b:search_values[0 : 9] : b:search_values
    let b:counter = 1
    call append(1, list_values)
    call setline(2, '->'.getline(2))
    call cursor(1, col('$'))
    return
  endif
  " }}}"
  "  if not, starts to search {{{
  let search_result = matchfuzzy(copy(b:main_values), line_result, {'limit': 200 })
  let b:search_values = search_result
  let b:change_values = len(b:search_values) > 10 ? 1 : 0
  let list_values = b:change_values == 1 ? b:search_values[0 : 9] : b:search_values
  let b:counter = 1
  call append(1, list_values)
  call setline(2, '->'.getline(2))
  call cursor(1, col('$'))
  " }}}"
endfunction " }}}
function! AMT_Execute_Action(command) " {{{
  let search_result = getline(search('->', 'n'))[2:]
  :q!
  execute a:command . ' ' . search_result
endfunction " }}}
function! AMT_start_buffer(first_line, list_values, ) abort " Open the buffer below with general mappings and settings {{{
  let split_setting = &splitbelow
  if split_setting == 0
    execute 'set splitbelow'
  endif
  :11new
  :e search.amtsearch
  if split_setting == 0
    execute 'set nosplitbelow'
  endif
  setlocal filetype=amtsearch modifiable nonumber norelativenumber buftype=nofile bufhidden=wipe  noswapfile nospell
  call setline(1, a:first_line)
  let b:main_values = a:list_values
  let b:search_values = b:main_values
  let b:change_values = len(b:search_values) > 10 ? 1 : 0
  let list_values = b:change_values == 1 ? b:main_values[0 : 9] : b:main_values
  let b:counter = 1
  call append(1, list_values)
  call cursor(1, col('$'))
  call setline(2, '->'.getline(2))
endfunction " }}}
function! Generate_nerd_font_symbols() abort "{{{
  if !exists('g:amt_nerdfonts_keys')
    call nerdpickers#read_nerd_glyphs()
  endif
  let g:amt_nerdfonts_keys = keys(g:main_fonts)
  let g:amt_symbols = []
  let g:amt_nerd_display = []
  for [key, symbol] in items(g:main_fonts)
    call add(g:amt_symbols, symbol["char"])
    call add(g:amt_nerd_display, symbol["char"] .. " : " .. key)
  endfor
endfunction "}}}
function! AMT_save_session() " {{{
  "   save session if not loaded
  let g:amt_session_folder = resolve(expand(g:amt_session_folder))
  if len(v:this_session) == 0
    let save_session = input('Not a session loaded, Save? (y/n) ')
    if save_session == 'y'
      let save_session = input('Session name: ')
      let prev_pos = getcwd()
      execute 'cd'
      execute 'mks!' . expand(g:amt_session_folder) . '/' . save_session
      execute 'cd ' . prev_pos
      return
    else
      echo 'Not a valid option'
      return
    endif
  " Move to the AMT folder 󰛂
  elseif fnamemodify(v:this_session, ":h") != expand(g:amt_session_folder)
    let save_in_folder = input('Session not in folder session, Save it? (y/n): ')
    if save_in_folder == 'y'
      let prev_pos = getcwd()
      execute 'cd'
      let file_name = expand(g:amt_session_folder) . '/' . fnamemodify(v:this_session, ":t")
      execute 'mks!' . file_name
      execute 'cd ' . prev_pos
    endif
  else
    let prev_pos = getcwd()
    execute "cd"
    execute "mks! " . v:this_session
    execute 'cd' . prev_pos
  endif
endfunction
" }}}
function! AMT_start_session(path_sessions) " {{{
  let search_result = getline(search('->', 'n'))[2:]
  :q!
  execute   'so '. expand( a:path_sessions ) . '/' . search_result
endfunction " }}}
" }}}
" AMT call functions   {{{
function! AMT_Close_session() " {{{
  let v:this_session = ""
  :bufdo! bw!
  execute 'AMTDash'
endfunction "}}}
function! AMT_start_nerdpicker() " {{{
  call Generate_nerd_font_symbols()
  call AMT_start_buffer('Symbol: ', g:amt_nerd_display)
  call AMT_start_default_mappings()
  "   Generate mappings {{{
  inoremap <buffer> <CR> <Esc>:call AMT_insert_text_nerd()<CR>:echo ' '<CR>
  nnoremap <buffer> <CR> :call AMT_insert_text_nerd()<CR>:echo ' '<CR>
  " }}}"
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
endfunction " }}}
function! AMT_insert_text_nerd() " {{{
  let selected_value = trim(split(getline((search('->', 'n'))), ':')[0][2:])
  :q!
  let cur_line = line('.')
  let cur_col = col('.')
  let line_content = getline(cur_line)
  if cur_col == 1
    call setline(cur_line, line_content[0].selected_value.line_content[1:])
  elseif cur_col == col('$') - 1
    call setline(cur_line, line_content.selected_value)
  else 
    call setline(cur_line, line_content[:cur_col-1].selected_value.line_content[cur_col:])
  endif
endfunction " }}}
function! AMT_start_Oldfiles() "{{{
  call AMT_start_buffer('Search: ', v:oldfiles)
  call AMT_start_default_mappings()
  inoremap <buffer> <CR> <Esc>:call AMT_Execute_Action('e')<CR>
  nnoremap <buffer> <CR> :call AMT_Execute_Action('e')<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
endfunction " }}}
function! AMT_start_buffers() " {{{
  let completion_list = getcompletion('', 'buffer')
  call AMT_start_buffer('Search: ', completion_list)
  call AMT_start_default_mappings()
  inoremap <buffer> <CR> <Esc>:call AMT_Execute_Action('b')<CR>
  nnoremap <buffer> <CR> :call AMT_Execute_Action('b')<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
endfunction "}}}
function! AMT_start_colors() "{{{
  let completion_list = getcompletion('', 'color')
  call AMT_start_buffer('Search: ', completion_list)
  call AMT_start_default_mappings()
  inoremap <buffer> <CR> <Esc>:call AMT_Execute_Action('colorscheme ')<CR>
  nnoremap <buffer> <CR> :call AMT_Execute_Action('colorscheme ')<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
endfunction "}}}
function! AMT_start_help() "{{{
  let completion_list = getcompletion('', 'help')
  call AMT_start_buffer('Search: ', completion_list)
  call AMT_start_default_mappings()
  inoremap <buffer> <CR> <Esc>:call AMT_Execute_Action('colorscheme ')<CR>
  nnoremap <buffer> <CR> :call AMT_Execute_Action('colorscheme ')<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 | call AMT_Change_Search(9) | endif
endfunction "}}}
function! AMT_start_commands() "{{{
  let completion_list = getcompletion('', 'command')
  call AMT_start_buffer('Search: ', completion_list)
  call AMT_start_default_mappings()
  inoremap <buffer> <CR> <Esc>:call AMT_Execute_Action(' ')<CR>
  nnoremap <buffer> <CR> :call AMT_Execute_Action(' ')<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
endfunction "}}}
function! AMT_start_sessions() " {{{
  " let session_name_prev = v:this_session
  " let v:this_session = ""
  "   Verify if session folder exists {{{
  if !exists("g:amt_session_folder")
    let g:amt_session_folder = '~/sessions'
  endif
  let g:amt_session_folder = resolve(expand(g:amt_session_folder))
  " }}}
  "   Folder creation if not generated {{{
  if !isdirectory(expand(g:amt_session_folder))
    if input('Session folder not created, want to create?\n y/n') == 'y'
      mkdir(expand(g:amt_session_folder))
    endif
  endif " }}}
  " 󰕲  Generation of list files with .vim generated{{{
  let completion_list = filter(readdir(expand(g:amt_session_folder)), 'v:val =~ "\.vim$"' )
  " echo completion_list
  " }}}
  "  start filter keys and commands {{{
  call AMT_start_buffer('Search: ', completion_list)
  call AMT_start_default_mappings()
  inoremap <buffer> <CR> <Esc>:call AMT_start_session(g:amt_session_folder)<CR>
  nnoremap <buffer> <CR> :call AMT_start_session(g:amt_session_folder)<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
  " }}}

endfunction " }}}
function! AMT_delete_sessions() " {{{
  "   Verify if session folder exists {{{
  if !exists("g:amt_session_folder")
    let g:amt_session_folder = '~/sessions'
  endif
  let g:amt_session_folder = resolve(expand(g:amt_session_folder))
  " }}}
  "   Folder creation if not generated {{{
  if !isdirectory(expand(g:amt_session_folder))
    if input('Session folder not created, want to create?\n y/n') == 'y'
      mkdir(expand(g:amt_session_folder))
    endif
  endif " }}}
  " 󰕲  Generation of list files with .vim generated{{{
  let completion_list = filter(readdir(expand(g:amt_session_folder)), 'v:val =~ "\.vim$"' )
  " echo completion_list
  " }}}
  "  start filter keys and commands {{{
  call AMT_start_buffer('Search: ', completion_list)
  call AMT_start_default_mappings()
  nnoremap <buffer> <CR> :call AMT_delete_session()<CR>
  inoremap <buffer> <CR> <Esc>:call AMT_delete_session()<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 && b:updating_line1 != getline(1) | call AMT_Change_Search(9) | endif
  " }}}
endfunction " }}}
function! AMT_delete_session() " {{{
  let file_name = getline( search('->', 'n') )[2:]
  call delete(g:amt_session_folder.'/'.file_name)
  echo " "
  echo 'Session ' . file_name . ' deleted'
  call AMT_Change_Search(9)
endfunction " }}}
function! AMT_create_session() " {{{
  let session_name = input('Session name: ')
  let session_path = resolve(expand(g:amt_session_folder)) . '/' . session_name
  execute 'mks! ' . session_path
  echo ''
  echo 'Session ' . session_path . ' saved'
endfunction "}}}
" }}}
