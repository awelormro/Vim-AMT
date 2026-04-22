" echo 1
setlocal bufhidden=wipe buftype=nofile nobuflisted nocursorcolumn nocursorline nolist nospell nonumber noswapfile norelativenumber

nnoremap <buffer><silent> <Up> :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> <Down> :call Dash_Move_cursor_down()<CR>
nnoremap <buffer><silent> <Left> :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> <Right> :call Dash_Move_cursor_down()<CR>
nnoremap <buffer><silent> h :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> j :call Dash_Move_cursor_down()<CR>
nnoremap <buffer><silent> k :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> l :call Dash_Move_cursor_down()<CR>
nnoremap <buffer><silent> gh :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> gk :call Dash_Move_cursor_down()<CR>
nnoremap <buffer><silent> gj :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> gl :call Dash_Move_cursor_down()<CR>
nnoremap <buffer><silent> <CR> :call Dash_Execute_Command()<CR>
nnoremap <buffer><silent> <BS> :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> <Del> :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> <S-Tab> :call Dash_Move_cursor_up()<CR>
nnoremap <buffer><silent> <Tab> :call Dash_Move_cursor_down()<CR>
