" echo globpath(&rtp, 'colors/*.vim')
" vim: set nospell:
" vim: set foldmethod=marker:
function! StartAMTDashboard() " {{{
  " Don't run if: we have commandline arguments, we don't have an empty
  " buffer, if we've not invoked as vim or gvim, or if we'e start in insert mode
  if argc() || line2byte('$') != -1 || v:progname !~? '^[-gmnq]\=vim\=x\=\%[\.exe]$' || &insertmode
    return
  endif

  " Start a new buffer ...
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

  " ... and set some options for it
  setlocal bufhidden=wipe buftype=nofile filetype=dash nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber

  " Now we can just write to the buffer, whatever you want.
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
  for lineascii in asciiheader
    call append('$', '-='.lineascii.'-=')
  endfor
  call append('$', '-')
  call append('$', 'commands:')
  if !exists('g:amt_dashboard_keys')
    let commandkeys = [
          \ {'map':'e','command':':enew<CR>',                  'desc':'- create new file           -'},
          \ {'map':'i','command':':enew <bar> startinsert<CR>','desc':'- new file With insert mode -'},
          \ {'map':'o','command':':enew <bar> startinsert<CR>','desc':'- new file With insert mode -'},
          \ {'map':'bf','command':':BrowseOldFi<CR>',          'desc':'-Explore Oldfiles          -'},
          \ {'map':'fm','command':':Lexplore<CR>',             'desc':'-File Browser-             -'},
          \ {'map':'q','command':':quit<CR>',                  'desc':'- Exit vim                  -'}
          \]
  else
    let commandkeys = g:amt_dashboard_keys
  endif
  let i=0
  call append('$', '  ')
  while i<len(commandkeys)
    exe 'nnoremap <buffer><silent> '.commandkeys[i]['map'].' '.commandkeys[i]['command']
    " call append('$', '  ')
    call append('$', commandkeys[i]['map'].': '.commandkeys[i]['desc'])
    let i=i+1
  endwhile
  exe 'normal \%center'
  %center
  " No modifications to this buffer
  setlocal nomodifiable nomodified
  " echo asciiaux
  " nnoremap <buffer><silent> e :enew<CR>
  "nnoremap <buffer><silent> i :enew <bar> startinsert<CR>
  "nnoremap <buffer><silent> o :enew <bar> startinsert<CR>
  "nnoremap <buffer><silent> q :quit<CR>

  " When we go to insert mode start a new buffer, and start insert
endfunction

command! AMTDash call StartAMTDashboard()
autocmd VimEnter * AMTDash
" }}}
" Run after doing all the startup stuff
