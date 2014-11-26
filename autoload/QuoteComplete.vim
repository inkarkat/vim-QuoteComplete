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
	let l:single = ('QuoteComplete_Single', g:QuoteComplete_Single)
	let l:double = ingo#plugin#setting#GetBufferLocal('QuoteComplete_Double', g:QuoteComplete_Double)
	let l:anyFallback = [l:single[0] . '\|' . l:double[0], l:single[1] . '\|' . l:double[1]]
    endif

    return s:Complete(ingo#plugin#setting#GetBufferLocal('QuoteComplete_Any', l:anyFallback), a:findstart, a:base)
endfunction

function! s:Complete( quoteConfig, findstart, base )
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
	\   'base' : a:base,
	\   'quoteExpr': a:quoteConfig[0],
	\   'quotedStringExpr': a:quoteConfig[1]
	\})
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
    let l:lead = ''
    let l:leadLen = strlen(l:lead)

    " now we need to search the buffer for strings!!!
    for l:lineData in (empty(a:lines) ? s:GetCurrentLines(a:options) : a:lines)
	let l:lineLen = strlen(l:lineData)

	let l:start = 0

	while l:start < l:lineLen
	    " find the first quote in the string
	    let l:qPos = match(l:lineData, a:options.quoteExpr, l:start)

	    " if nothing was found, nothing to do
	    if l:qPos == -1
		break
	    endif

	    let l:str = matchstr(l:lineData, a:options.quotedStringExpr, l:qPos)

	    " if there was no string match (the string wasn't complete), then we
	    " can't do anything more with this line
	    if l:str == ''
		break
	    endif

	    " look for the next string further on
	    let l:start = l:qPos + strlen(l:str)

	    " if we have a leadstring, then we need to make sure the lead matches too
	    if l:leadLen && (strpart(l:str, 1, l:leadLen) != l:lead)
		" if the string doesn't begin with 'lead' already in place, then it
		" can't be used
		continue
	    endif

	    " Don't allow strings of less than 1 contained character
	    if strlen(l:str) > 3
		if ! count(a:matches, l:str)
		    let l:add = { 'word': l:str, 'icase': 0 }

		    call add(a:matches, l:add)
		    unlet l:add
		endif
	    endif
	endwhile
    endfor
endfunction


function! QuoteComplete#Expr( completionFunction )
    let &completefunc = a:completionFunction
    return "\<C-x>\<C-u>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
