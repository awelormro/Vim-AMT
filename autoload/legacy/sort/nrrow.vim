if !has('vim9script')
  finish
endif
vim9script

command -range AMTSelection Nrrow_content(<line1>, <line2>)
vnoremap <silent> <leader>a<leader>n :AMTSelection<CR>
command AMTVisible Nrrow_content(line('w0'), line('w$'))
command AMTParagraph Nrrow_para()

def Nrrow_para()
  var search_blank_prev = search('^\s*$', 'nbW')
  var search_blank_next = search('^\s*$', 'nW')
  if search_blank_prev == 0
    search_blank_prev = 1
  endif

  if search_blank_next == 0
    search_blank_next = line('$')
  endif
  Nrrow_content(search_blank_prev, search_blank_next)
enddef

def Nrrow_content(start: number, end: number)
  if exists('g:nrrow_start')
    if g:nrrow_start == true
      echoerr 'Currently a narrowed buffer is started, finish'
      finish
    else
      g:nrrow_start = true
    endif
  else
    g:nrrow_start = true
  endif
  var content_file = getline(start, end)
  var buffer_add = expand('%')
  var content_narrow = content_file
  var curr_filetype = &filetype
  :enew
  execute 'setlocal filetype=' .. curr_filetype .. '.nrrow'
  b:start = start
  b:end = end
  b:buffer_replace_name = buffer_add
  append(1, content_narrow)
  :1delete
  cursor(1, 1)
  command -buffer AMTNrrowQuit Nrrow_close()
enddef

def Nrrow_close()
  var content_file = getline(1, line('$'))
  if line('$') == 1 && getline(1) =~ '^\s*$'
    return
  endif
  var start_replace = b:start
  var end_replace = b:end
  var replace_buffer = b:buffer_replace_name
  :bw!
  execute 'b ' .. replace_buffer
  execute ':' .. start_replace .. ',' .. end_replace .. 'delete'
  append(start_replace - 1, content_file)
  g:nrrow_start = false
enddef
