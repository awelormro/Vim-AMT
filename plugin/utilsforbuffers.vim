" vim: set nospell:
" vim: set foldmethod=marker:

command! AMToldfiles call AMT_launch('oldfiles')


function! AMT_launch(kind) abort " Main AMT function {{{
  if a:kind == 'oldfiles'
    call AMT_start_Oldfiles()
  endif
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
function! AMT_start_Oldfiles() "{{{
  call AMT_start_buffer('Search: ', v:oldfiles)
  call AMT_start_default_mappings()
  inoremap <buffer> <Up> <Esc>:call AMT_Cursor_Up()<CR>A
  inoremap <buffer> <Down> <Esc>:call AMT_Cursor_Down()<CR>A
  nnoremap <buffer> <Up> :call AMT_Cursor_Up()<CR>$
  nnoremap <buffer> <Down> :call AMT_Cursor_Down()<CR>$
  inoremap <buffer> <CR> <Esc>:call AMT_Execute_Action('e')<CR>
  nnoremap <buffer> <CR> :call AMT_Execute_Action('e')<CR>
  autocmd TextChangedI *.amtsearch if line('.') == 1 | call AMT_Change_Search(9) | endif
endfunction " }}}
function! AMT_start_default_mappings() "{{{
  inoremap <buffer><expr> <Backspace> col('.') > 9 && line('.') == 1 ? '<Backspace>' : ''
  inoremap <buffer><expr> <Left> col('.') > 9 ? '<Left>' : ''
  inoremap <buffer><expr> <Del> col('.') != col('$') && line('.') == 1 && col('.') > 9 ? '<Del>' : ''
  nnoremap <buffer> q :q!<CR>
  inoremap <buffer> <C-q> <Esc>:q!<CR>
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
    return
  endif
  if idx_search == 11 && b:change_values == 1
    :2delete
    call append(10, b:search_values[b:counter - 1])
    call setline(11, '->'.getline(11))
    call setline(10, getline(10)[2 :])
    let b:counter = b:counter + 1
    call cursor(1, col('$'))
    return
  endif
  if line('$') < 10
    echo 'Will delete and substitute'
    execute ':2,'.string(line('$')).'delete'
    let b:counter = 1
    call append(1, b:search_values[0:9])
    call setline(2, '->'.getline(2))
    call cursor(1, col('$'))
    return
  endif
  call setline(idx_search + 1, '->'.getline(idx_search + 1))
  call setline(idx_search, getline(idx_search)[2 :])
  let b:counter = b:counter + 1
  call cursor(1, col('.'))
endfunction " }}}
function! AMT_Change_Search(len_ignore) abort " {{{
  let line_result = getline(1)[a:len_ignore :]
  echo line_result
  if len(line_result) == 0
    let b:change_values = b:main_values
    let b:change_values = len(b:search_values) > 10 ? 1 : 0
    let list_values = b:change_values == 1 ? b:search_values[0 : 9] : b:search_values
    let b:counter = 1
    call append(1, list_values)
    call cursor(1, col('$'))
    call setline(2, '->'.getline(2))
    return
  endif
  let search_result = matchfuzzy(copy(b:main_values), line_result)
  let b:search_values = search_result
  execute '2,'.string(line('$')).'delete'
  let b:change_values = len(b:search_values) > 10 ? 1 : 0
  let list_values = b:change_values == 1 ? b:search_values[0 : 9] : b:search_values
  let b:counter = 1
  call append(1, list_values)
  call cursor(1, col('$'))
  call setline(2, '->'.getline(2))
endfunction " }}}
function! AMT_Execute_Action(command) " {{{
  let search_result = getline(search('->', 'n'))[2:]
  :q!
  execute a:command . ' ' . search_result
endfunction " }}}
