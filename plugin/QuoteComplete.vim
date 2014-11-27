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
"	001	27-Nov-2014	file creation

" Avoid installing twice or when in unsupported Vim version.
if exists('g:loaded_QuoteComplete') || (v:version < 700)
    finish
endif
let g:loaded_QuoteComplete = 1

"- configuration ---------------------------------------------------------------

if ! exists('g:QuoteComplete_complete')
    let g:QuoteComplete_complete = '.,w,b'
    let g:QuoteComplete_complete = '.' "TODO
endif

if ! exists('g:QuoteComplete_Single')
    let g:QuoteComplete_Single = {'char': "'", 'pattern': '''\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\.\|[^'']\)\{-}'''}
endif
if ! exists('g:QuoteComplete_Double')
    let g:QuoteComplete_Double = {'char': '"', 'pattern': '"\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\.\|[^"]\)\{-}"'}
endif
if ! exists('g:QuoteComplete_Any')
    let g:QuoteComplete_Any = [g:QuoteComplete_Single, g:QuoteComplete_Double, {'char': '`', 'pattern': '`\%(\%(\%(^\|[^\\]\)\%(\\\\\)*\\\)\@<!\\.\|[^`]\)\{-}`'}]
endif



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
