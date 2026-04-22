" 󰌾 Locks for amt {{{
if exists('g:amt_started')
  finish
endif

if !exists('g:amt_core')
  finish
endif

if g:amt_core != 'python'
  finish
endif
" }}}
" 󰀟 Global variables for AMT {{{
let g:amt_search_file_extensions = [ 
      \ 'wav', 'mp3', 'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'odt',
      \ 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'tiff', 'webp',
      \ 'mp4', 'avi', 'mkv', 'mov', 'wmv', 'flv', 'webm', 'm4v',
      \ 'ogg', 'flac', 'aac', 'm4a', 'wma',
      \ 'zip', 'tar', 'gz', 'bz2', 'xz', '7z', 'rar', 'iso',
      \ 'exe', 'msi', 'bin', 'appimage', 'deb', 'rpm', 'dmg',
      \ 'dwg', 'dxf',
      \ 'ttf', 'otf', 'woff', 'woff2',
      \ 'db', 'sqlite', 'mdb', 'accdb',
      \ 'epub', 'mobi', 'azw3'
      \ ]
let g:amt_started = 1
let g:amt_json_nerdpicker_file_root = expand("<sfile>:h:p")
"  }}}
"  Python block start {{{
python3 << EOF
# from amt import start
import amt.start
amt.start.start_amt()
EOF
"  }}}
" 󰐊 Auxiliar for nerdfonts start {{{
" 󰈮 Generate glyphs file {{{
function! ObtainNerdFile()
  let root_path = fnamemodify(g:amt_json_nerdpicker_file_root, ':h')
  let root_header = root_path . "/autoload/glifos.json"
  let simple_header = root_path . '/autoload/glifos_simples.txt'
  
  " Si no existe el archivo simple, cargar el JSON
  if findfile(simple_header) == 0
    let json_content = json_decode(join(readfile(root_header), "\n"))
    let g:json_list_total = json_content
  endif
  
  " Verificar que g:json_list_total existe
  if !exists('g:json_list_total')
    echo "Error: g:json_list_total no está definido"
    return []
  endif
  
  " Obtener las claves y construir la lista
  let contents = keys(g:json_list_total)
  let exit_list = []
  
  " CORRECCIÓN: Iterar sobre las claves, no sobre g:json_list_total directamente
  for key in contents
    " Obtener el char del valor
    let char = get(g:json_list_total[key], 'char', '')
    if !empty(char)
      let string_new = char . '-' . key
      call add(exit_list, string_new)  " Usar add() en lugar de insert()
    endif
  endfor
  
  echo exit_list
  call writefile(exit_list, simple_header)
  let g:simple_glyphs_list = exit_list
  return exit_list
endfunction
"  }}}
" Generate  write file {{{
function! Write_nerd_glyph()
  let pos = search('^->', 'n')
  let content = line(pos)
  :q!
  let current_line = getline('.')
  let line_pos = col('.')
  if line_pos == col('$')
    let new_line = current_line . content[2]
  else
    let new_line = current_line[:line_pos].content[2].current_line[line_pos:]
  endif
  call setline(current_line, new_line)
endfunction
"  }}}
"  }}}
"  󰯂 Generate fill the buffer {{{
function! AMT_Fill_buffer_data(data)
  let len_data = len(a:data)
  let b:total_data = a:data
  let b:search_data = a:data
  let b:finished_search = 0
  if len_data <= 10
    let b:buffer_data = a:data
  else
    let b:buffer_data = a:data[0:10]
  endif
  let data_fill = b:buffer_data
  call append(1, data_fill)
  let b:counter = 0
  let b:search_value = ''
  call setline(2, '->'.getline(2))
  call cursor(1, col('$'))
endfunction
"  }}}
"  Generate mappings {{{
function! AMT_aux_generate_mappings(comm_start, comm_end)
  command! -buffer AMTCursorUp call AMT_cursor_up()
  command! -buffer AMTCursorDown call AMT_cursor_down()
  command! -buffer AMTChangeSearch call AMT_reload_Search()
  command! -buffer AMTConfirmSelection call AMT_confirm_buffer(comm_start, comm_end)
  command! -buffer AMTExit :q!<CR>
  autocmd TextChangedI *.amtsearch execute 'AMTChangeSearch'
endfunction
"  }}}
"  Change ticks {{{
function! AMT_aux_change_tick(line_prev, line_new)
  call setline(a:line_prev, getline(a:line_prev)[2:])
  call setline(a:line_new, '->'.getline(a:line_new))
endfunction
"  }}}
" Generate move first row up {{{
function! AMT_aux_first_row_up()
  let len_total_data = len(b:total_data)
  if len_total_data == 1
    let b:finished_search = 1
    return
  endif
  if b:counter == 0
    if len_total_data <= 10
      call AMT_aux_change_tick(2, '$')
      let b:counter = len_total_data
      let b:finished_search = 1
      return
    endif
    call deletebufline('%', 2, '$')
    let b:counter = len_total_data - 1
    let new_pos = b:counter
    call append(1, b:total_data[new_pos])
    call setline(2, '->'.getline(2) )
    let b:finished_search = 1
    return
  endif
  let len_total_buffer = getline('$')
  if len_total_buffer > 10
    if len_total_buffer > 11
      let new_pos = b:counter - 1
      let new_line = '->'.b:total_data[new_pos]
      call append(1, new_line)
      let b:counter b:counter - 1
      let b:finished_search = 1
      return
    elseif len_total_buffer == 11
      call deletebufline('%', '$')
      let new_pos = b:counter - 1
      let new_line = b:total_data[new_pos]
      call append(1, new_line)
      let b:counter = new_pos
      let b:finished_search = 1
      return
    endif
  endif
  if len_total_buffer < 11
    let new_pos = b:counter - 1
    let new_line = '->'.b:total_data[new_pos]
    call append(1, new_line)
    let b:counter = b:counter - 1
    let b:finished_search =1
    return
  endif
  call AMT_aux_change_tick(1, line('$'))
  let b:finished_search = 1
  let b:counter b:counter - 1
endfunction
"  }}}
" Last row down {{{
function! AMT_aux_last_row_down()
  let len_total_data = len(b:total_data) - 1
  if b:counter == len_total_data
    if len_total_data >= 10
      call deletebufline('%', 2, '$')
      let insert_new_data = b:total_data[:10]
      let b:counter = 0
      call append(1, insert_new_data)
      call setline(2, '->'.getline(2))
      return
    elseif len_total_data < 10
      call setline(2, '->'.getline(2))
      call setline('$', getline('$')[2:])
      let b:counter = 0
      let b:finished_search = 1
      return
    endif
  endif
  call deletebufline('%', 2)
  call setline('$', getline('$')[2:])
  let b:counter = b:counter + 1
  let new_append = '->'.b:total_data[b:counter]
  call append('$', new_append)
  let b:finished_search = 1
  return
endfunction
"  }}}
" Generate the buffer {{{  
function! Amt_generate_buffer(data, comm_beg, comm_end)
  :belowright 11new
  :e ~/srch.amtsearch
  call deletebufline('%', 1, '$')
  setlocal bufhidden=wipe nobuflisted noautocomplete filetype=amtsearch
  call setline(1, 'Search: ')
  call AMT_Fill_buffer_data(a:data)
  let b:prev_srch = ''
  call AMT_aux_generate_mappings(a:comm_beg, a:comm_end)
endfunction
" }}}
" Confirm the selection {{{  
function! AMT_confirm_buffer(command, extras)
  let pos_search = search('^->')
  let cont_string = getline(pos_search)
  :q!
  call execute(a:command.' '.cont_string[2:].' '.a:extras)
endfunction
" }}}
" Move the cursor up {{{  
function! AMT_cursor_up()
  let search_pos = search('^->', 'n')
  if search_pos == 2
    call AMT_aux_first_row_up()
    if b:finished_search == 1
      let b:finished_search = 0
      return
    endif
  endif 
  call AMT_aux_change_tick(search_pos, search_pos - 1)
  let b:counter = b:counter - 1
endfunction
" }}}
" Move the cursor down {{{  
function! AMT_cursor_down()
  let search_pos = search('^->', 'n')
  if search_pos == line('$')
    call AMT_aux_last_row_down()
    if b:finished_search == 1
      let b:finished_search = 0
      return
    endif
  endif 
  call AMT_aux_change_tick(search_pos, search_pos + 1)
  let b:counter = b:counter + 1
endfunction
" }}}
" Function to check the autocmd {{{  
function! AMT_reload_Search()
  let word_start = 'Search: '
  let search_value = trim(getline(1)[len(word_start):])
  if search_value != b:search_value
    if search_value == ''
      let fuzzy_search = b:search_values
    else
      let fuzzy_search = matchfuzzy(b:total_data, search_value, { 'limit': 100 })
    endif
    call deletebufline('%', 2, '$')
    let b:counter = 0
    if len(fuzzy_search) == 0
      return
    endif
    if len(fuzzy_search) <= 10
      call append('$', fuzzy_search)
    else
      call append('$', fuzzy_search[:10])
    endif
    let b:search_data = fuzzy_search
    call setline(2, '->'.getline(2))
    call cursor(1, col('$'))
  endif
endfunction
" }}}
" function to delete the buffer {{{
function! AMT_delete_buffer()
endfunction
" }}}
" Function to add a nerdfonts glyph {{{ 
function! AMT_insert_nerd()
  let search_line = search('^->', 'n')
  let split_line = split(getline(search_line), '-')
  let cont_line = split_line[0][1:]
  :bw!
  let curr_line_content = getline('.')
  let curr_line_num = line('.')
  let curr_pos = col('.')
  if curr_pos == 0
    let new_line_content = cont_line.curr_line_content
  elseif curr_pos == col('$')
    let new_line_content = curr_line_content.cont_line
  else
    let new_line_content = curr_line_content[:curr_pos - 1].cont_line.curr_line_content[curr_pos:]
  endif 
  call setline(curr_line_num, new_line_content)
endfunction
" }}}
"  Function to add the nerdfont glyph
function AMT_Nerd()
  let root_path = fnamemodify(g:amt_json_nerdpicker_file_root, ':h')
  let simple_header = root_path . '/autoload/glifos_simples.txt'
  let nerd_file = readfile(simple_header)
  " echo nerd_file
  call Amt_generate_buffer(nerd_file, 'call AMT_insert_nerd()', '')
  command! -buffer AMTConfirmSelection call AMT_insert_nerd()
endfunction
"  Start for file searching {{{ 
function AMT_Searching_file(...)
  if a:0 > 0 && !empty(a:1)
    let path = expand(a:1)
    if !isdirectory(path)
      let path = fnamemodify(path, ':p:h')
    endif
    if !isdirectory(path)
      return []
    endif
  else
    let path = getcwd()
  endif
  echo path
  let path_content = readdir(path)
  echo path_content
endfunction
command! -nargs=? AMTFileExplorer call AMT_Searching_file(<q-args>)
function AMT_Launch_Edit_Enter()
endfunction
" }}}
command! AMTnerd call AMT_Nerd()
nnoremap <silent> <Leader>rf :AMToldfiles<CR>
nnoremap <silent> <Leader>bf :AMTbuffers<CR>
nnoremap <silent> <Leader>co :AMTcolors<CR>
nnoremap <silent> <Leader>nf :AMTnerd<CR>
