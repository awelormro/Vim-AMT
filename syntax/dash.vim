syn match AMTHeadContent ".*" contained
syn match AMTDelStart  /^\s*{{{/ contained conceal
syn match AMTDelEnd /^\s*}}}/ contained conceal
syn region AMTHeadEntity start=/^\s*{{{/ end=/^\s*}}}/ contains=AMTHeadContent,AMTDelStart,AMTDelEnd keepend
syn match AMTMapping ".*" contained
syn match AMTMappingStart /\[\[/ contained conceal
syn match AMTMappingEnd /\]\]/ contained conceal
syn region AMTMappingState start=/\[\[/ end=/\]\]/ contains=AMTMappingStart,AMTMappingEnd,AMTMapping keepend
hi link AMTHeadContent Type

