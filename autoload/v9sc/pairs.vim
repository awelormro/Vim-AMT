if !has('vim9script')
  finish
endif

vim9script
export def AMT_Match_pairs(pair: string, end: string)
  auxchar = getchar()
  if pair == '('
    # TODO: Generate function
  elseif pair == '['
    # TODO: Generate function
  elseif pair == '{'
    # TODO: Generate function
  endif
enddef

export def AMT_Match_quote(pair: string)
  if pair == '"'
    # TODO: Generate function
  elseif pair == "'"
    # TODO: Generate function
  endif
endif
