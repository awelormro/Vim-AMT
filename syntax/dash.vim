setlocal concealcursor=nvic
syn match AMTHeadContent ".*" contained
syn match AMTDelStart  /^\s*{{{/ contained conceal
syn match AMTDelEnd /^\s*}}}/ contained conceal
syn region AMTHeadEntity start=/^\s*{{{/ end=/^\s*}}}/ contains=AMTHeadContent,AMTDelStart,AMTDelEnd keepend
syn match AMTMapping "\a*" contained
syn match AMTMappingStart "\V[[" contained conceal
syn match AMTMappingEnd "\V]]" contained conceal
syn region AMTMappingState start=/\s\[\[/ end="\]\]\s" contains=AMTMappingStart,AMTMappingEnd,AMTMapping keepend
syn match AMTGlyphStart /{\[/ contained conceal cchar= 
syn match AMTGlyphEnd /\]}/ contained conceal cchar= 
" syn match AMTGlyph ".*" contained
syn match AMTGlyph /[^{}\[\]]\+/ contained
syn region AMTGlyphState start=/{\[/ end=/\]}/ contains=AMTGlyphStart,AMTGlyph,AMTGlyphEnd concealends keepend transparent
hi link AMTHeadContent Type
hi link AMTGlyph Float
hi link AMTGlyphEnd Type
hi link AMTMapping Constant
