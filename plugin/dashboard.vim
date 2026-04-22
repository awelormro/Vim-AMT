" echo globpath(&rtp, 'colors/*.vim')
" vim: set nospell:
"
function! StartAMTDashboard() " {{{
  " Don't run if: we have commandline arguments, we don't have an empty
  " buffer, if we've not invoked as vim or gvim, or if we'e start in insert mode
  if argc() || line2byte('$') != -1 || v:progname !~? '^[-gmnq]\=vim\=x\=\%[\.exe]$' || &insertmode
    return
  endif

  " 󰾴 Start a new buffer ... {{{
  enew

  let asciiaux = [
        \ ' $$$$$$\  $$\      $$\ $$$$$$$$\ $$\    $$\ $$$$$$\ $$\      $$\ ',
        \ '$$  __$$\ $$$\    $$$ |\__$$  __|$$ |   $$ |\_$$  _|$$$\    $$$ |',
        \ '$$ /  $$ |$$$$\  $$$$ |   $$ |   $$ |   $$ |  $$ |  $$$$\  $$$$ |',
        \ '$$$$$$$$ |$$\$$\$$ $$ |   $$ |   \$$\  $$  |  $$ |  $$\$$\$$ $$ |',
        \ '$$  __$$ |$$ \$$$  $$ |   $$ |    \$$\$$  /   $$ |  $$ \$$$  $$ |',
        \ '$$ |  $$ |$$ |\$  /$$ |   $$ |     \$$$  /    $$ |  $$ |\$  /$$ |',
        \ '$$ |  $$ |$$ | \_/ $$ |   $$ |      \$  /   $$$$$$\ $$ | \_/ $$ |',
        \ '\__|  \__|\__|     \__|   \__|       \_/    \______|\__|     \__|',
        \ ]

  " }}}
  " 󰭆 ... and set some options for it {{{
  setlocal bufhidden=wipe buftype=nofile filetype=dash nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber

  " }}}
  "  Now we can just write to the buffer, whatever you want. {{{
  call append('$', "")
  let vimsize=winwidth('%') 
  exe 'setlocal tw='.vimsize
  "for line in split(system('fortune -a'), '\n')
  "    call append('$', '        ' . l:line)
  "endfor
  if !exists('g:amt_dashboard_ascii')
    let asciiheader = asciiaux
  else
    let asciiheader = g:amt_dashboard_ascii
  endif
  call setline(1, "{{{")
  call append(1, asciiheader)
  " for lineascii in asciiheader
  "   " call append('$', '-= '.lineascii.' -=')
  "   call append('$', lineascii)
  " endfor
  call append('$', "}}}")
  " }}}
  "  Add some commands and keymaps {{{
  call append('$', '-')
  call append('$', 'commands:')
  if !exists('g:amt_dashboard_keys')
    let g:amt_dashboard_keys = [
          \ {'map':'e','command':':enew<CR>',                  'desc':'{[ 󰈔 create new file           ]}'},
          \ {'map':'i','command':':enew <bar> startinsert<CR>','desc':'{[  new file With insert mode ]}'},
          \ {'map':'bf','command':':AMToldfiles<CR>',          'desc':'{[  Explore Oldfiles          ]}'},
          \ {'map':'bs','command':':AMTStartSession<CR>',      'desc':'{[  Explore Sessions          ]}'},
          \ {'map':'fm','command':':Lexplore<CR>',             'desc':'{[  File Browser              ]}'},
          \ {'map':'q','command':':quit<CR>',                  'desc':'{[ 󰩈 Exit vim                  ]}'}
          \]
    let commandkeys = g:amt_dashboard_keys
  else
    let commandkeys = g:amt_dashboard_keys
  endif
  let i=0
  call append('$', '  ')
  let b:dash_command_start = line('$') + 1
  while i < len(commandkeys)
    exe 'nnoremap <buffer><silent> '.commandkeys[i]['map'].' '.commandkeys[i]['command']
    if len(commandkeys[i]['map']) == 1
      call append('$', "[[ ".commandkeys[i]['map'].' ]]  : '.commandkeys[i]['desc'])
    else
      call append('$', '[[ '.commandkeys[i]['map'].' ]] : '.commandkeys[i]['desc'])
    endif
    let i = i + 1
  endwhile
  " }}}
  " Center the dashboard {{{
  " exe 'normal \%center'
  %center
  " No modifications to this buffer
  setlocal nomodifiable nomodified
  call cursor(b:dash_command_start, 0)
  call search('\[\[')
  call cursor(line('.'), col('.') + 3)
  nnoremap <buffer> <Up> :call Dash_Move_cursor_up()<CR>
  nnoremap <buffer> <Down> :call Dash_Move_cursor_down()<CR>
  nnoremap <buffer> <Left> :call Dash_Move_cursor_up()<CR>
  nnoremap <buffer> <Right> :call Dash_Move_cursor_down()<CR>
  nnoremap <buffer> h :call Dash_Move_cursor_up()<CR>
  nnoremap <buffer> j :call Dash_Move_cursor_down()<CR>
  nnoremap <buffer> k :call Dash_Move_cursor_up()<CR>
  nnoremap <buffer> l :call Dash_Move_cursor_down()<CR>
  nnoremap <buffer> gh :call Dash_Move_cursor_up()<CR>
  nnoremap <buffer> gk :call Dash_Move_cursor_down()<CR>
  nnoremap <buffer> gj :call Dash_Move_cursor_up()<CR>
  nnoremap <buffer> gl :call Dash_Move_cursor_down()<CR>
  nnoremap <buffer> <CR> :call Dash_Execute_Command()<CR>
  " echo asciiaux
  " nnoremap <buffer><silent> e :enew<CR>
  "nnoremap <buffer><silent> i :enew <bar> startinsert<CR>
  "nnoremap <buffer><silent> o :enew <bar> startinsert<CR>
  "nnoremap <buffer><silent> q :quit<CR>

  " When we go to insert mode start a new buffer, and start insert
  "
  " }}}
endfunction " }}}
function! AMT_Dash_Enter()
  if argc() || line2byte('$') != -1 || v:progname !~? '^[-gmnq]\=vim\=x\=\%[\.exe]$' || &insertmode
    return
  endif
  " call append('$', "")
  enew
  let vimsize=winwidth('%') 
  exe 'setlocal tw='.vimsize
  setlocal filetype=amtdash
  call AMT_Dash_Generate_header()
  call AMT_Dash_Add_commands()
  if !exists('g:amt_dash_centering')
    let g:amt_dash_centering = 1
  endif
  if g:amt_dash_centering == 1
    %center
  endif
  setlocal nomodifiable nomodified
  call cursor(b:dash_command_start, 0)
  call search('\[\[')
  call cursor(line('.'), col('.') + 3)
endfunction
function! AMT_Dash_Generate_header()
  set filetype=amtdash
  let asciiaux =  [
        \ ' $$$$$$\  $$\      $$\ $$$$$$$$\ $$\    $$\ $$$$$$\ $$\      $$\ ',
        \ '$$  __$$\ $$$\    $$$ |\__$$  __|$$ |   $$ |\_$$  _|$$$\    $$$ |',
        \ '$$ /  $$ |$$$$\  $$$$ |   $$ |   $$ |   $$ |  $$ |  $$$$\  $$$$ |',
        \ '$$$$$$$$ |$$\$$\$$ $$ |   $$ |   \$$\  $$  |  $$ |  $$\$$\$$ $$ |',
        \ '$$  __$$ |$$ \$$$  $$ |   $$ |    \$$\$$  /   $$ |  $$ \$$$  $$ |',
        \ '$$ |  $$ |$$ |\$  /$$ |   $$ |     \$$$  /    $$ |  $$ |\$  /$$ |',
        \ '$$ |  $$ |$$ | \_/ $$ |   $$ |      \$  /   $$$$$$\ $$ | \_/ $$ |',
        \ '\__|  \__|\__|     \__|   \__|       \_/    \______|\__|     \__|',
        \ ]
  if !exists('g:amt_dashboard_ascii')
    let asciiheader = asciiaux
  else
    let asciiheader = g:amt_dashboard_ascii
  endif
  call setline(1, "{{{")
  call append(1, asciiheader)
  call append('$', "}}}")
  call append('$', ' ')
  call append('$', 'Commands:')
  let b:dash_command_start = line('$') + 1
endfunction
function! AMT_aux_generate_dash_variables()
  let i=0
  let len_dict_keys = len(b:commandkeys)
  let map_list = []
  let command_list = []
  let glyph_list = []
  let desc_list = []
  let max_len_desc_str = 0
  let max_len_command_str = 0
  let max_len_map_str = 0
  let list_properties = [ 'map', 'glyph', 'desc', 'command' ]
  " Recuerda: glyph, map, desc command, se usa add() para añadir y es con
  " cada key
  while i < len_dict_keys
    if !has_key(b:commandkeys[i], 'glyph')
      call add(glyph_list, '-1')
    else
      call add(glyph_list, b:commandkeys[i]['glyph'])
    endif
    if !has_key(b:commandkeys[i], 'desc')
      call add(desc_list, '-1')
    else
      call add(desc_list, b:commandkeys[i]['desc'])
      if len(b:commandkeys[i]['desc']) > max_len_desc_str
        let max_len_desc_str = len(b:commandkeys[i]['desc'])
      endif
    endif
    if !has_key(b:commandkeys[i], 'command')
      call add(command_list, '-')
    else
      call add(command_list, b:commandkeys[i]['command'])
      if len(b:commandkeys[i]['command']) > max_len_command_str
        let max_len_command_str = len(b:commandkeys[i]['command'])
      endif
    endif
    if !has_key(b:commandkeys[i], 'map')
      call add(map_list, '-1' )
    else
      call add(map_list, b:commandkeys[i]['map'])
      if len(b:commandkeys[i]['map']) > max_len_map_str
        let max_len_map_str = len(b:commandkeys[i]['map'])
      endif
    endif
    let i = i + 1
  endwhile
  let i = 0
  call append('$', '  ')
  let b:dash_command_start = line('$') + 1
  let map_prev = 'nnoremap <buffer><silent> '
  let len_commandkeys = len(b:commandkeys)
  let b:max_len_map_str = max_len_map_str
  let b:max_len_command_str = max_len_command_str
  let b:max_len_map_str = max_len_map_str
  while i < len_commandkeys
    if map_list[i] != '-1' && command_list[i] != '-1'
      exe map_prev.map_list[i].' :'.command_list[i].'<CR>'
    endif
    if map_list[i] != '-1' 
      let map_str = '[['.map_list[i].repeat(' ', max_len_map_str - len(map_list[i]) + 1).']]'
    else
      let map_str = '[['.repeat(' ', max_len_map_str + 1) .']]'
    endif
    if glyph_list[i] != '-1'
      let glyph_str = '(('.glyph_list[i].' ))'
    else
      let glyph_str = '((  ))'
    endif
    if desc_list[i] != '-1'
      let desc_str = '(['.desc_list[i].repeat(' ', max_len_desc_str - len(desc_list[i])).' ])'
    else
      let desc_str = '([  ])'
    endif
    let line_append = glyph_str.' '.map_str.' '.desc_str
    call append('$', line_append)
    let i = i + 1
  endwhile
endfunction
function! AMT_Dash_Add_commands()
  if !exists('g:amt_dashboard_keys')
    let b:amt_dash_keys = [
          \ {'map': 'e', 'command': 'enew', 'glyph': '󰈔', 'desc': 'New file' },
          \ {'map': 'i', 'command': 'enew <bar> startinsert', 'glyph': '', 'desc': 'New File in Insert mode' },
          \ {'map': 'rf', 'command': 'AMToldfiles', 'glyph': '', 'desc': 'Recent files' },
          \ {'map': 'sm', 'command': 'AMTStartSession', 'glyph': '', 'desc': 'Session manager' },
          \ {'map': 'fm', 'command': 'Lexplore', 'glyph': '', 'desc': 'File Explorer' },
          \ {'map': 'q', 'command': 'quit', 'glyph': '󰩈', 'desc': 'Exit vim' },
          \]
    let b:commandkeys = b:amt_dash_keys
  else
    let b:commandkeys = g:amt_dashboard_keys
  endif
  call AMT_aux_generate_dash_variables()
endfunction
function! AMT_Generate_mappings()
endfunction
"  Functions to move up and down the cursor {{{
function! Dash_Move_cursor_up() abort "{{{
  let idx_row = line('.')
  if idx_row == b:dash_command_start
    call cursor(line('$'), col('.'))
  else
    call cursor(line('.') - 1, col('.'))
  endif
endfunction " }}}
function! Dash_Move_cursor_down() abort "{{{
  let idx_row = line('.')
  if idx_row == line('$')
    call cursor(b:dash_command_start, col('.'))
  else
    call cursor(line('.') + 1, col('.'))
  endif
endfunction "}}}
function! Dash_Execute_Command() abort " {{{
  let command_line = line('.')
  let command_execute = b:commandkeys[command_line - b:dash_command_start]['command']
  call execute(command_execute)
endfunction " }}}
" }}}
" command! AMTDash call StartAMTDashboard()
if !has('nvim') || g:amt_core != 'lua'
  command! AMTDash call AMT_Dash_Enter()
  autocmd VimEnter * AMTDash
endif
function! Cosas()
  let baba = 1
endfunction
