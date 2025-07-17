if !has('vim9script')
  finish
endif
vim9script

if exists('g:amt_started')
  finish
endif

if !exists('g:amt_core')
  g:amt_core = 'vim9script'
endif

if g:amt_core != 'vim9script'
  finish
endif

g:amt_started = 1

import autoload "v9sc/start.vim" as starter

starter.StartFun()
