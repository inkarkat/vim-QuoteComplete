" vim_QuoteComplete.vim: Quoting customization for Vimscript.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.00.001	04-Dec-2014	file creation

let b:QuoteComplete_Single = {'pattern': '''\%([^'']\|''''\)\+''', 'char': "'"}

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
