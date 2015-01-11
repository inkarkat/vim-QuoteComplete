" QuoteComplete.vim: Insert mode completion of quoted strings.
"
" DEPENDENCIES:
"   - Requires Vim 7.0 or higher.
"   - QuoteComplete.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	27-Nov-2014	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_QuoteComplete') || (v:version < 700)
    finish
endif
let g:loaded_QuoteComplete = 1

"- functions -------------------------------------------------------------------

function! s:MakeEscaped( char, ... )
    if a:0
	return {
	\   'char': a:char,
	\   'endChar': a:1,
	\   'pattern': a:char . '\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\.\|[^' . a:char . a:1 . ']\)\{-}' . a:1
	\}
    else
	return {
	\   'char': a:char,
	\   'pattern': a:char . '\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\.\|[^' . a:char . ']\)\{-}' . a:char
	\}
    endif
endfunction



"- configuration ---------------------------------------------------------------

if ! exists('g:QuoteComplete_complete')
    let g:QuoteComplete_complete = '.,w,b'
endif

if ! exists('g:QuoteComplete_Single')
    let g:QuoteComplete_Single = s:MakeEscaped("'")
endif
if ! exists('g:QuoteComplete_Double')
    let g:QuoteComplete_Double = s:MakeEscaped('"')
endif
if ! exists('g:QuoteComplete_Any')
    let g:QuoteComplete_Any = [
    \   g:QuoteComplete_Single,
    \   g:QuoteComplete_Double,
    \   s:MakeEscaped('`'),
    \   s:MakeEscaped("\u0091", "\u0092"),
    \   s:MakeEscaped("\u2018", "\u2019"),
    \   s:MakeEscaped("\u201a", "\u2019"),
    \   s:MakeEscaped("\u201c", "\u201d"),
    \   s:MakeEscaped("\u201e", "\u201d"),
    \]
endif
delfunction s:MakeEscaped


"- mappings --------------------------------------------------------------------

inoremap <silent> <expr> <Plug>(QuoteCompleteSingle) QuoteComplete#Expr('QuoteComplete#Single')
if ! hasmapto('<Plug>(QuoteCompleteSingle)', 'i')
    imap <C-x>' <Plug>(QuoteCompleteSingle)
endif
inoremap <silent> <expr> <Plug>(QuoteCompleteDouble) QuoteComplete#Expr('QuoteComplete#Double')
if ! hasmapto('<Plug>(QuoteCompleteDouble)', 'i')
    imap <C-x>" <Plug>(QuoteCompleteDouble)
endif
inoremap <silent> <expr> <Plug>(QuoteCompleteAny) QuoteComplete#Expr('QuoteComplete#Any')
if ! hasmapto('<Plug>(QuoteCompleteAny)', 'i')
    imap <C-x>` <Plug>(QuoteCompleteAny)
endif

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
