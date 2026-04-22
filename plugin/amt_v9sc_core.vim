if has('nvim') || !has('vim9script')
  finish
endif

vim9script

if exists('g:amt_core') && g:amt_core != 'vim9'
  finish
endif

if exists('g:amt_started') 
  finish
endif

g:amt_started = 1

echo 'vim9script core started'
