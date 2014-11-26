" QuoteComplete.vim: Insert mode completion of puoted strings.
"
" DEPENDENCIES:
"
" Copyright: (C) 2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	001	27-Nov-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

function! s:GetCompleteOption()
    return (exists('b:QuoteComplete_complete') ? b:QuoteComplete_complete : g:QuoteComplete_complete)
endfunction

function! QuoteComplete#Single( findstart, base )
    return s:Complete(ingo#plugin#setting#GetBufferLocal('QuoteComplete_Single', g:QuoteComplete_Single), a:findstart, a:base)
endfunction
function! QuoteComplete#Double( findstart, base )
    return s:Complete(ingo#plugin#setting#GetBufferLocal('QuoteComplete_Double', g:QuoteComplete_Double), a:findstart, a:base)
endfunction
function! QuoteComplete#Any( findstart, base )
    let l:anyFallback = g:QuoteComplete_Any
    if exists('b:QuoteComplete_Single') || exists('b:QuoteComplete_Double')
	let l:anyFallback = [
	\   ingo#plugin#setting#GetBufferLocal('QuoteComplete_Single', g:QuoteComplete_Single),
	\   ingo#plugin#setting#GetBufferLocal('QuoteComplete_Double', g:QuoteComplete_Double)
	\] + g:QuoteComplete_Any[2:]
    endif

    return s:Complete(ingo#plugin#setting#GetBufferLocal('QuoteComplete_Any', l:anyFallback), a:findstart, a:base)
endfunction

function! s:Complete( quotes, findstart, base )
    if a:findstart
	" Locate the start of the keyword.
	let l:startCol = searchpos('\k*\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	endif
	return l:startCol - 1 " Return byte index, not column.
    else
	" Find matches starting with a:base.
	let l:matches = []
	call CompleteHelper#Find(l:matches, function('QuoteComplete#FindQuotes'), {
	\   'complete': s:GetCompleteOption(),
	\   'base' : '\V\^' . escape(a:quotes.char . a:base, '\'),
	\   'quotes': a:quotes
	\})

	if empty(l:matches)
	    echohl ModeMsg
	    echo '-- User defined completion (^U^N^P) -- Anywhere search...'
	    echohl None

	    call CompleteHelper#Find(l:matches, function('QuoteComplete#FindQuotes'), {
	    \   'complete': s:GetCompleteOption(),
	    \   'base' : '\V' . escape(a:base, '\'),
	    \   'quotes': a:quotes
	    \})
	endif

	return l:matches
    endif
endfunction

function! s:GetCurrentLines( options )
    let l:isBackward = (has_key(a:options, 'backward_search') ?
	\  a:options.backward_search :
	\  g:CompleteHelper_IsDefaultToBackwardSearch
    \)
    let l:lnums = (l:isBackward ?
	\  range(line('.') - 1, 1, -1) + range(line('$'), line('.'), -1) :
	\  range(line('.'), line('$')) + range(1, line('.') - 1)
    \)
    return map(l:lnums, 'getline(v:val)')
endfunction
function! QuoteComplete#FindQuotes( lines, matches, matchTemplate, options, isInCompletionBuffer )
    for l:line in (empty(a:lines) ? s:GetCurrentLines(a:options) : a:lines)
	let l:lineLen = len(l:line)

	for l:quote in ingo#list#Make(a:options.quotes)
	    let l:col = 0

	    while l:col < l:lineLen
		let l:quoteCol = match(l:line, l:quote.char, l:col)
		if l:quoteCol == -1
		    break
		endif

		let l:quotedString = matchstr(l:line, l:quote.pattern, l:quoteCol)
		if l:quotedString == ''
		    break
		endif

		let l:col = l:quoteCol + len(l:quotedString)

		if l:quotedString !~# a:options.base
		    continue
		endif

		let l:matchObj = copy(a:matchTemplate)
		call CompleteHelper#AddMatch(a:matches, l:matchObj, l:quotedString, a:options)
	    endwhile
	endfor
    endfor
endfunction



function! QuoteComplete#Expr( completionFunction )
    let &completefunc = a:completionFunction
    return "\<C-x>\<C-u>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
