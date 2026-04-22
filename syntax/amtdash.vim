setlocal conceallevel=2
setlocal concealcursor=nvic
"  Header info {{{
syn match AMTHeadContent ".*" contained
syn match AMTDelStart  /^\s*{{{/ contained conceal
syn match AMTDelEnd /^\s*}}}/ contained conceal
syn region AMTHeadEntity start=/^\s*{{{/ end=/^\s*}}}/ contains=AMTHeadContent,AMTDelStart,AMTDelEnd keepend
" }}}
"  Mapping info {{{
syn match AMTMapping "\a*" contained
syn match AMTMappingStart "\[\[" contained conceal
syn match AMTMappingEnd "\]\]" contained conceal
syn region AMTMappingState start=/\s\[\[/ end="\]\]\s" contains=AMTMappingStart,AMTMappingEnd,AMTMapping keepend
" }}}
"  Glyph info {{{
syn match AMTGlyphStart "((" contained conceal
syn match AMTGlyphEnd "))" contained conceal
syn region AMTGlyphState start=/((/ end=/))/ keepend contains=AMTGlyphContent,AMTGlyphStart,AMTGlyphEnd
" }}}
" 󰈔 Description Info {{{  
syn match AMTDescStart "(\[" contained conceal
syn match AMTDescEnd "\])" contained conceal
syn region AMDescState start=/(\[/ end=/\])/ keepend contains=AMTDescStart,AMTDescEnd,AMTEnd
" }}}
"   Highlight definitions {{{
hi link AMTHeadContent Type
hi link AMTMapping Constant
hi link AMTGlyphState Label
hi link AMDescState Define
" }}}
