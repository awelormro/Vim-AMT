if !has('vim9script') || has('nvim')
  finish
endif

vim9script

export def AMT_sneak_search(forward: bool, advance: number)
  var ch1 = getcharstr()
  if advance == 2
    var ch2 = getcharstr()
    ch1 = ch1 .. ch2
  endif
  b:last_chars = ch1
  AMT_sneak_repeat(true)
enddef

export def AMT_sneak_repeat(forward: bool)
  if !exists('b:last_chars') || b:last_chars == ''
    return
  endif
  var count = v:count1
  var i = 0
  if forward == true
    while i < count
      search(b:last_chars, 'W')
    endwhile
  else
    while i < count
      search(b:last_chars, 'bW')
    endwhile
  endif
  i += 1
enddef
