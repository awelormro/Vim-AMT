if !has('vim9script')
  finish
endif
vim9script

#   command creations {{{ 
command! AMTSmartSquote             Smart_quotes("'")
command! AMTSmartDquote             Smart_quotes("\"")
command! AMTStartSmart1             Smart_pairing('(')
command! AMTStartSmart2             Smart_pairing('[')
command! AMTStartSmart3             Smart_pairing('{')

# }}}
# 󰌌 Mapping creation {{{
# inoremap <silent> ( <C-o>:AMTStartSmart1<CR>
# inoremap <silent> [ <C-o>:AMTStartSmart2<CR>
# inoremap <silent> { <C-o>:AMTStartSmart3<CR>
# inoremap <silent> ' <C-o>:AMTSmartSquote<CR>
# inoremap <silent> " <C-o>:AMTSmartDquote<CR>
# }}}
# 󰊕 Functions {{{ 
def Smart_pairing(start: string) # {{{
  var close = start == '[' ? ']' : start == '(' ? ')' : start == '{' ? '}' : ''
  var curr_pos = col('.') 
  var prev_indent = indent('.')
  b:pairing = 1
  execute "normal! a" .. start .. close
  execute "normal! =="
  var dif_indent = indent('.')
  if prev_indent != dif_indent
    cursor(line('.'), curr_pos + dif_indent + 1)
  else
    cursor(line('.'), curr_pos + 2) 
  endif
  var char = getcharstr()
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
    return
  endif
  if char ==  ' '
    feedkeys("\<Left>  \<Left>", 'n')
  elseif char == "\<CR>"
    execute "normal i\<CR>\<Up>\<C-o>$\<CR>"
  elseif char == '"'
    execute "normal \<Left>a\""
  elseif char == "'"
    execute "normal \<Left>a'"
  elseif char == ";"
    execute "normal i\<CR>\<Right>;\<Left>\<Up>\<C-o>$\<CR>"
  elseif char == close
    execute "normal \<Right>"
  elseif char == '('
    execute "normal \<Left>i()\<Left>"
  elseif char == '['
    execute "normal \<Left>i[]\<Left>"
  elseif char == '{'
    execute "normal \<Left>i{}\<Left>"
  else
    feedkeys("\<Left>" .. char, "n")
  endif
  b:pairing = 0
enddef # }}}
def Smart_quotes(start: string) # {{{
  if !exists("b:pairing")
    b:pairing = 0
  endif
  if b:pairing == 1
    execute "normal! a" .. start
    return
  endif
  var curr_pos = col('.') 
  var prev_indent = indent('.')
  execute "normal! a" start .. start
  execute "normal! =="
  var dif_indent = indent('.')
  if prev_indent != dif_indent
    cursor(line('.'), curr_pos + dif_indent + 1)
  else
    cursor(line('.'), curr_pos + 2) 
  endif
  var char = getcharstr()
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
    return
  endif
  if char ==  ' '
    feedkeys("\<Left>  \<Left>", 'n')
  else
    feedkeys("\<Left>" .. char, "n")
  endif
enddef # }}}
export def Smart_squote() # {{{
  execute "normal! a'"
  var char = getcharstr()
  feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
  return
  if strlen(char) > 1
    execute "normal! a'\<Esc>i"
    feedkeys("\<Right>")
    feedkeys(char, 'n')
    return
  endif
  if char == ' '
    execute "normal! a  '\<Left>" 
  elseif char == "\<CR>"
    execute "normal! a\n'\<Up>\<C-o>$\<C-o>"
  elseif char == "'"
    execute "normal! a'\<Esc>i"
    feedkeys("\<Right>")
  elseif char == '"'
    execute "normal! a\"\"'\<Left>"
  else
    execute "normal! a" .. char .. "'"
    feedkeys("\<Left>")
  endif
enddef # }}}
export def Smart_dquote() # {{{
  execute "normal! a\""
  var char = getcharstr()
  # Si es Backspace (^?) o Delete (^[[3~), salimos sin hacer más
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
    return
  endif
  if strlen(char) > 1
    execute "normal! a\"\<Esc>i"
    feedkeys("\<Right>")
    feedkeys(char, 'b')
    return
  endif
  if char == ' '
    execute "normal! a  \"\<Left>" 
  elseif char == "\<CR>"
    execute "normal! a\n\"\<Up>\<C-o>$\<C-o>"
  elseif char == "\""
    execute "normal! a\"\"\"\"\"\<Esc>3h"
    feedkeys("\<Right>")
  elseif char == "'"
    execute "normal! a''\"\<Left>"
  else
    execute "normal! a" .. char .. "\""
    feedkeys("\<Left>")
  endif
enddef # }}}
# # }}}
