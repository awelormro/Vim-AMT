if !has('vim9script')
  finish
endif

vim9script

export def StartFun()
  echo 'generate start from vim9script'
  g:amt_core_v9sc = 1
enddef
