" vim: set fdm=marker: set nospell:

if exists('g:amt_started')
  finish
endif

if has('nvim')
  finish
endif

if g:amt_core == "lua"
lua << EOF
require('starter.start').starter()
EOF
elseif g:amt_core == "python"
let g:amt_json_nerdpicker_file_root = expand("<sfile>:h:p")
python3 << EOF
# from amt import start
import amt.start
amt.start.start_amt()
EOF
else
  call vlegacy#starter#start()
endif

let g:amt_started = 1
