" vim: set nospell:
" vim: set foldmethod=marker:

" Main AMT function {{{
function! AMT_launch(kind) abort
  if a:kind == 'oldfiles'
    call AMT_start_Oldfiles()
  endif
endfunction " }}}

function! AMT_start_Oldfiles() abort " Open buffer for Oldfiles {{{
  call AMT_start_buffer('Search: ')
  call AMT_generate_mappings()
  call cursor(1, col('$'))
  let b:counter = 0
  call AMT_fill_lines(v:oldfiles, 0)
endfunction " }}}

function! AMT_fill_lines(list_values, pos) " {{{
  let len_vals = len(a:list_values)
  let vals_from_pos = a:pos + 9
  echo len_vals
  let b:arguments = a:list_values
  if line('$') > 1
    execute ':2,'.string(line('$')).'delete'
  elseif len_vals < 10
    call append(1, a:list_values)
  elseif vals_from_pos <= len_vals - 1
    call append(1, a:list_values[a:pos: a:pos + 9])
  else
    call append(1, a:list_values[a:pos:])
  endif
endfunction " }}}

function! AMT_Change_pos_up(list_values) abort " {{{
  let cursor_pos = search('>', 'n')
  if cursor_pos == 2
    call AMT_fill_lines(a:list_values, len(a:list_values))
    call setline(2, '>'getline(2))
  else
    call setline(cursor_pos, getline(cursor_pos)[1:])
    call setline(cursor_pos + 1, '>'.getline(cursor_pos + 1))
  endif
endfunction " }}}

function! AMT_search_results(list_values, line_search, string_start) abort " {{{
  let line_content = getline(a:line_search)
  let searched_result = line_content[len(a:string_start) - 1:]
  let results = matchfuzzy(a:list_values, searched_result)
  call AMT_fill_lines(results, 0)
endfunction " }}}

function! AMT_generate_mappings() abort " {{{
  inoremap <buffer><expr> <left> line('.') == 1 && col('.') > 8 ? '<left>' : ''
  nnoremap <buffer><expr> <left> line('.') == 1 && col('.') > 8 ? '<left>' : ''
  nnoremap <buffer><expr> <Backspace> line('.') == 1 && col('.') > 8 ? '<Backspace>' : ''
  inoremap <buffer><expr> <Backspace> line('.') == 1 && col('.') > 8 ? '<Backspace>' : ''
  nnoremap <buffer><expr> <Del> line('.') == 1 && col('.') > 8 ? '<Del>' : ''
  inoremap <buffer><expr> <Del> line('.') == 1 && col('.') > 8 ? '<Del>' : ''
  nnoremap <buffer><expr> h line('.') == 1 && col('.') > 8 ? '<left>' : ''
  nnoremap <buffer> q :q!<CR>
  nnoremap <buffer> <C-q> <Esc>:q!
  echo 'mappings generation'
endfunction " }}}

function! AMT_start_buffer(first_line) abort " Open the buffer below with general mappings and settings {{{
  let split_setting = &splitbelow
  if split_setting == 0
    execute 'set splitbelow'
  endif
  :11new
  :e search.amtsearch
  if split_setting == 0
    execute 'set nosplitbelow'
  endif
  setlocal filetype=amtsearch
  setlocal modifiable
  setlocal nonumber norelativenumber
  setlocal buftype=nofile bufhidden=wipe  noswapfile nospell
  call setline(1, a:first_line)
endfunction
" }}}

command! AMToldfiles call AMT_launch('oldfiles')




" autocmd TextChangedI *.amtsearch if exists('*AMTChangeSearchOldfiles') && line('.') == 1 | call AMTChangeSearchOldfiles() | endif

