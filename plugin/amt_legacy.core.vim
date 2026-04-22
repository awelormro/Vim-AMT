if !exists('g:amt_core')
  finish
endif

if g:amt_core != 'legacy'
finish
endif

if exists('g:amt_started')
  finish
endif

let g:amt_started = 1

" command!
