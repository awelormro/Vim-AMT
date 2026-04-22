" File: plugin-generator.vim
" Descripción: Generador de plantillas para plugins Vim en diferentes lenguajes


" Boilers section {{{
if exists('g:loaded_plugin_generator') || &cp
  finish
endif
let g:loaded_plugin_generator = 1

if !exists('g:plugins_path_save')
  let g:plugins_path_save = "~/"
endif
command! -nargs=1 -complete=customlist,s:PluginTypes NewPlugin call s:GeneratePlugin(<f-args>)

function! s:PluginTypes(ArgLead, CmdLine, CursorPos)
  return ['vim9', 'lua', 'vim-legacy', 'python', 'vim9lua', 'vim9py']
endfunction

function! s:CheckLastPartPath(pth) abort
  let last_part_buf = a:pth[::-2]
endfunction

function! s:GeneratePlugin(type) abort
  let plugin_name = input('Nombre del plugin (sin espacios): ')
  if empty(plugin_name)
    echo "Operación cancelada"
    return
  endif

  let template = s:GetTemplate(a:type, plugin_name)
  if empty(template)
    echoerr "Tipo de plugin no válido: " . a:type
    return
  endif

  " Crear directorio del plugin
  let dirname = plugin_name
  if !isdirectory(dirname)
    call mkdir(dirname, 'p')
  endif

  " Crear archivos según el tipo
  if a:type ==# 'vim9'
    call mkdir(dirname."/plugin/", 'p')
    call mkdir(dirname."/autoload/", 'p')
    let dir_save = expand(g:plugins_path_save . dirname . '/plugin/' )
    call writefile(split(template, "\n"), dir_save . plugin_name . '.vim')
  elseif a:type ==# 'lua'
    call writefile(split(template, "\n"), dirname . '/lua/' . plugin_name . '.lua')
  elseif a:type ==# 'vim-legacy'
    call writefile(split(template, "\n"), dirname . '/plugin/' . plugin_name . '.vim')
  elseif a:type ==# 'python'
    call writefile(split(template, "\n"), dirname . '/python/' . plugin_name . '.py')
    " Crear también el loader Vim
    let vim_loader = [
          \ "if !has('python3')",
          \ "  echo 'Error: Se requiere Python3'",
          \ "  finish",
          \ "endif",
          \ "",
          \ "python3 << EOF",
          \ "import sys, vim",
          \ "sys.path.append(vim.eval('expand(\"<sfile>:p:h\")') + '/python')",
          \ "import " . plugin_name,
          \ "EOF",
          \ "",
          \ "command! " . plugin_name . "Test call " . plugin_name . "#Test()"
          \ ]
    call writefile(vim_loader, dirname . '/plugin/' . plugin_name . '.vim')
  endif

  echo "Plugin " . plugin_name . " creado como tipo " . a:type
endfunction

function! s:GetTemplate(type, name) abort
  if a:type ==# 'vim9'
    return printf(
\ "vim9script\n".
\ "# %s - Descripción breve del plugin\n".
\ "\n".
\ "if exists('g:loaded_%s') || &cp\n".
\ "  finish\n".
\ "endif\n".
\ "const g:loaded_%s = 1\n".
\ "\n".
\ "# Configuración\n".
\ "def! %s#Setup()\n".
\ "  # Configuración del plugin\n".
\ "enddef\n".
\ "\n".
\ "# Comandos\n".
\ "command! -nargs=0 %sTest echo 'Test ejecutado'", a:name, a:name, a:name, a:name, a:name)

  elseif a:type ==# 'lua'
    return printf(
\ "-- %s - Descripción breve del plugin\n"
\ "\n"
\ "local M = {}\n"
\ "\n"
\ "function M.setup()\n"
\ "  -- Configuración del plugin\n"
\ "end\n"
\ "\n"
\ "function M.test()\n"
\ "  print('Test ejecutado')\n"
\ "end\n"
\ "\n"
\ "vim.cmd([[command! -nargs=0 %sTest lua require('%s').test()]])\n"
\ "\n"
\ "return M", a.name, a.name, a.name)

  elseif a:type ==# 'vim-legacy'
    return printf(
\ "\" %s - Descripción breve del plugin\n"
\ "\n"
\ "if exists('g:loaded_%s') || &cp\n"
\ "  finish\n"
\ "endif\n"
\ "let g:loaded_%s = 1\n"
\ "\n"
\ "\" Configuración\n"
\ "function! %s#Setup()\n"
\ "  \" Configuración del plugin\n"
\ "endfunction\n"
\ "\n"
\ "\" Comandos\n"
\ "command! -nargs=0 %sTest echo 'Test ejecutado'", a.name, a.name, a.name, a.name, a.name)

  elseif a:type ==# 'python'
    return printf(
\ "# %s - Descripción breve del plugin\n"
\ "\n"
\ "import vim\n"
\ "\n"
\ "def test():\n"
\ "    \"\"\"Función de prueba\"\"\"\n"
\ "    vim.command(\"echo 'Test desde Python ejecutado'\")\n"
\ "\n"
\ "# Para exponer funciones a Vim\n"
\ "class VimInterface:\n"
\ "    @staticmethod\n"
\ "    def Test():\n"
\ "        test()", a.name)

  else
    return ''
  endif
endfunction


" }}}
" Mini sneak {{{
let g:last_chars = ''

function! MiniSneakjump() abort
  let g:last_chars = nr2char(getchar()) . nr2char(getchar())
  call search(g:last_chars, 'W')
endfunction

function! MiniSneakrepeat(forward) abort
  if empty(g:last_chars)
    echo "No previous sneak"
    return
  endif
  if a:forward
    call search(g:last_chars, 'W')
  else
    call search(g:last_chars, 'bW')
  endif
endfunction



" nnoremap <silent> s :call MiniSneakjump()<CR>
" nnoremap <expr> ; g:last_chars == '' ? ':' : ':call MiniSneakrepeat(1)<CR>'
" nnoremap <silent> , :call MiniSneakrepeat(0)<CR>
" nnoremap <silent> <Esc><Esc> :let g:last_chars = ''<CR>
" }}}
" File: mini-easymotion.vim {{{
" Descripción: Implementación minimalista de movimiento estilo EasyMotion

if exists('g:loaded_mini_easymotion') || &cp
  finish
endif
let g:loaded_mini_easymotion = 1

" Configuración
let g:mini_easymotion_keys = get(g:, 'mini_easymotion_keys', 
      \ 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ')
let g:mini_easymotion_highlight = get(g:, 'mini_easymotion_highlight', 'IncSearch')

" Variables internas
let s:targets = []
let s:marks = {}

" Función principal
function! s:EasyMotion() range
  " Limpiar cualquier marcador previo
  call s:ClearHighlights()

  " Obtener posición inicial (línea actual, columna 1)
  let start_line = line('.')
  let start_col = 1

  " Obtener posición final (línea actual, fin de línea)
  let end_line = line('.')
  let end_col = col('$')

  " Buscar todos los caracteres objetivo en la línea actual
  let s:targets = []
  let keys_used = ''

  for lnum in range(start_line, end_line)
    let line = getline(lnum)
    for cnum in range(0, strlen(line)-1)
      let char = tolower(line[cnum])
      if stridx(g:mini_easymotion_keys, char) != -1 && 
           \ stridx(keys_used, char) == -1
        call add(s:targets, {'lnum': lnum, 'cnum': cnum+1, 'char': char})
        let keys_used .= char
      endif
    endfor
  endfor

  " Mostrar marcadores
  call s:ShowMarkers()

  " Esperar entrada del usuario
  let input = nr2char(getchar())

  " Saltar a la posición seleccionada
  call s:JumpToMarker(input)

  " Limpiar marcadores
  call s:ClearHighlights()
endfunction

" Mostrar marcadores
function! s:ShowMarkers()
  let s:marks = {}
  let key_index = 0

  " Limitar el número de objetivos si hay más que teclas disponibles
  let max_targets = len(g:mini_easymotion_keys)
  if len(s:targets) > max_targets
    let s:targets = s:targets[:max_targets-1]
  endif

  for target in s:targets
    let key = g:mini_easymotion_keys[key_index]
    let s:marks[key] = target
    call matchaddpos(g:mini_easymotion_highlight, 
          \ [[target.lnum, target.cnum]], 10)
    call setpos('.', [0, target.lnum, target.cnum, 0])
    execute 'normal! i' . key . "\<Esc>"
    let key_index += 1
  endfor
endfunction

" Saltar a marcador
function! s:JumpToMarker(key)
  if has_key(s:marks, a:key)
    let target = s:marks[a:key]
    call setpos('.', [0, target.lnum, target.cnum, 0])
  endif
endfunction

" Limpiar marcadores
function! s:ClearHighlights()
  for match in getmatches()
    if match['group'] == g:mini_easymotion_highlight
      call matchdelete(match['id'])
    endif
  endfor

  " Restaurar texto original (eliminar letras marcadoras)
  for target in s:targets
    call setpos('.', [0, target.lnum, target.cnum, 0])
    normal! x
  endfor
endfunction

" Mapeos
nnoremap <silent> <Plug>(MiniEasyMotion) :<C-U>call <SID>EasyMotion()<CR>

" Mapeo por defecto (puede ser sobreescrito en el vimrc)
if !hasmapto('<Plug>(MiniEasyMotion)', 'n')
  nmap <Leader><Leader> <Plug>(MiniEasyMotion)
endif



" }}}
" Term manager {{{
" ==============================
" TermManager.vim
" Plugin simple para gestionar terminales
" ==============================

if exists("g:loaded_termmanager")
  finish
endif
let g:loaded_termmanager = 1

let s:term_buffers = {}
let s:current_term = 1
let s:term_count = 0

" ---- Abrir nueva terminal ----
function! TermManagernew() abort
  let s:term_count += 1
  let l:bufname = "term://" . s:term_count
  " split para abrir abajo, puedes cambiar a vsplit
  split
  execute "terminal"
  let s:term_buffers[s:term_count] = bufnr("%")
  let s:current_term = s:term_count
endfunction

" ---- Toggle terminal actual ----
function! TermManagertoggle() abort
  if bufexists(s:term_buffers[s:current_term])
    if bufwinnr(s:term_buffers[s:current_term]) != -1
      " Si está visible → ciérralo
      execute bufwinnr(s:term_buffers[s:current_term]) . "wincmd c"
    else
      " Si no está visible → ábrelo
      split
      execute "buffer " . s:term_buffers[s:current_term]
    endif
  else
    call TermManager#new()
  endif
endfunction

" ---- Cambiar terminal actual ----
function! TermManagerswitch(id) abort
  if has_key(s:term_buffers, a:id)
    let s:current_term = a:id
    call TermManager#toggle()
  else
    echo "Terminal " . a:id . " no existe."
  endif
endfunction

" ---- Cerrar terminal actual ----
function! TermManagerclose() abort
  if bufexists(s:term_buffers[s:current_term])
    execute "bd! " . s:term_buffers[s:current_term]
    call remove(s:term_buffers, s:current_term)
  endif
endfunction

" ---- Enviar comando a terminal ----
function! TermManagersend(cmd) abort
  if bufexists(s:term_buffers[s:current_term])
    call chansend(bufwinid(s:term_buffers[s:current_term]), a:cmd . "\n")
  else
    echo "No hay terminal activa"
  endif
endfunction

" ---- Mapas de ejemplo ----
nnoremap <leader>tt :call TermManagertoggle()<CR>
nnoremap <leader>tn :call TermManagernew()<CR>
nnoremap <leader>tc :call TermManagerclose()<CR>
nnoremap <leader>ts :call input("Switch to terminal #: ") \| call TermManagerswitch(str2nr(input))<CR>
nnoremap <leader>tr :call input("Command: ") \| call TermManagersend(input)<CR>
" }}}
