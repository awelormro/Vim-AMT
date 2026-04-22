inoremap <buffer><expr> <Left> col(".") > 9 ? '<Left>' : ""
inoremap <buffer><expr> <bs> col(".") > 9 ? '<bs>' : ""
inoremap <buffer><expr> <del>  col(".") > 9 ? '<del>' : col('.') < col('$') ? '<del>' : ""
inoremap <buffer><silent> <Up> <C-o>:AMTCursorUp<CR>
inoremap <buffer><silent> <Down> <C-o>:AMTCursorDown<CR>
nnoremap <buffer><silent>  <Up> :AMTCursorUp<CR>
nnoremap <buffer><silent>  <Down> :AMTCursorDown<CR>
nnoremap <buffer><silent>  k :AMTCursorUp<CR>
nnoremap <buffer><silent>  j :AMTCursorDown<CR>
inoremap <buffer><silent> <CR> <C-o>:AMTConfirmSelection<CR>
nnoremap <buffer><silent> <CR> :AMTConfirmSelection<CR>
nnoremap <buffer><silent> q :q!
inoremap <buffer><silent> <C-q> <C-o>:q!
inoremap <buffer><silent> <Tab> <C-o>:AMTCursorUp<CR>
inoremap <buffer><silent> <S-Tab> <C-o>:AMTCursorDown<CR>
nnoremap <buffer><silent>  <S-Tab> :AMTCursorUp<CR>
nnoremap <buffer><silent>  <Tab> :AMTCursorDown<CR>
