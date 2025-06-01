if !has('vim9script')
  finish
endif
vim9script


command! AMTSmartPar             Smart_parentheses()
command! AMTSmartBracket         Smart_brackets()
command! AMTSartCur              Smart_Curly()
command! AMTSmartSquote          Smart_squote()
command! AMTSmartDquote          Smart_dquote()

inoremap <silent> ( <C-o>:AMTSmartPar<CR>
inoremap <silent> [ <C-o>:AMTSmartBracket<CR>
inoremap <silent> { <C-o>:AMTSartCur<CR>
inoremap <silent> ' <C-o>:AMTSmartSquote<CR>
inoremap <silent> " <C-o>:AMTSmartDquote<CR>

export def Smart_parentheses()
  execute "normal! a("
  var char = getcharstr()
  # Si es Backspace (^?) o Delete (^[[3~), salimos sin hacer más
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
    return
  endif
  if char == ' '
    execute "normal! a  )\<Left>" 
  elseif char == "\<CR>"
    execute "normal! a\n)\<Up>\<C-o>$\<C-o>"
  elseif char == ")"
    execute "normal! a)\<Esc>i"
    feedkeys("\<Right>")
  elseif char == '"'
    execute "normal! a\"\")\<Left>"
  elseif char == "'"
    execute "normal! a'')\<Left>"
  else
    execute "normal! a" .. char .. ")"
    feedkeys("\<Left>")
  endif
enddef

export def Smart_brackets()
  execute "normal! a["
  var char = getcharstr()
  # Si es Backspace (^?) o Delete (^[[3~), salimos sin hacer más
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
    return
  endif
  if char == ' '
    execute "normal! a  ]\<Left>" 
  elseif char == "\<CR>"
    execute "normal! a\n]\<Up>\<C-o>$\<C-o>"
  elseif char == "]"
    execute "normal! a]\<Esc>i"
    feedkeys("\<Right>")
  elseif char == '"'
    execute "normal! a\"\"]\<Left>"
  elseif char == "'"
    execute "normal! a'']\<Left>"
  else
    execute "normal! a" .. char .. "]"
    feedkeys("\<Left>")
  endif
enddef

export def Smart_Curly()
  execute "normal! a{"
  var char = getcharstr()
  # Si es Backspace (^?) o Delete (^[[3~), salimos sin hacer más
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
    return
  endif
  if char == ' '
    execute "normal! a  }\<Left>" 
  elseif char == "\<CR>"
    execute "normal! a\n}\<Up>\<C-o>$\<C-o>"
  elseif char == "}"
    execute "normal! a}\<Esc>i"
    feedkeys("\<Right>")
  elseif char == '"'
    execute "normal! a\"\"}\<Left>"
  elseif char == "'"
    execute "normal! a''}\<Left>"
  else
    execute "normal! a" .. char .. "}"
    feedkeys("\<Left>")
  endif
enddef


export def Smart_squote()
  execute "normal! a'"
  var char = getcharstr()
  # Si es Backspace (^?) o Delete (^[[3~), salimos sin hacer más
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
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
enddef



export def Smart_dquote()
  execute "normal! a\""
  var char = getcharstr()
  # Si es Backspace (^?) o Delete (^[[3~), salimos sin hacer más
  if char == "\<BS>" || char == "\<Del>"
    feedkeys(char, 'n')  # Insertamos el Backspace/Delete normalmente
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
enddef
