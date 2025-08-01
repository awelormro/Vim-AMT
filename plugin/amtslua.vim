" vim: set fdm=marker: set nospell:

if exists('g:amt_started')
  finish
endif

if has('nvim')
  finish
endif

if g:amt_core == "lua"
  lua require('starter.start').starter()
elseif g:amt_core == "python"
  py3 import starter
  py3 starter.start()
else
  call vlegacy#starter#start()
endif

let g:amt_started = 1
