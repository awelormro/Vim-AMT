" echo globpath(&rtp, 'colors/*.vim')
" vim: set nospell:
" vim: set foldmethod=marker:
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
  for lineascii in asciiheader
    " call append('$', '-= '.lineascii.' -=')
    call append('$', lineascii)
  endfor
  call append('$', "}}}")
  " }}}
  "  Add some commands and keymaps {{{
  call append('$', '-')
  call append('$', 'commands:')
  if !exists('g:amt_dashboard_keys')
    let g:amt_dashboard_keys = [
          \ {'map':'e','command':':enew<CR>',                  'desc':'{[ 󰈔 create new file           ]}'},
          \ {'map':'i','command':':enew <bar> startinsert<CR>','desc':'{[  new file With insert mode ]}'},
          \ {'map':'o','command':':enew <bar> startinsert<CR>','desc':'{[  new file With insert mode ]}'},
          \ {'map':'bf','command':':AMTOldfiles<CR>',          'desc':'{[  Explore Oldfiles          ]}'},
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
  exe 'normal \%center'
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
endfunction


" }}}
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
  let command_execute = g:amt_dashboard_keys[command_line - b:dash_command_start]['command']
  let command_execute = substitute(command_execute, '<', '\\<', 'g')
  execute 'call feedkeys('.'"'.command_execute.'", "n")'
  echo command_execute
endfunction " }}}
" }}}
command! AMTDash call StartAMTDashboard()
autocmd VimEnter * AMTDash
" Run after doing all the startup stuff

