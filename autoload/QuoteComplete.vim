" QuoteComplete.vim: Insert mode completion of quoted strings.
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
	" Locate the start of the quoted text (any possible quote) or keyword.
	let l:quotesCharPatterns = map(
	\   ingo#collections#Flatten1([
	\       ingo#plugin#setting#GetBufferLocal('QuoteComplete_Single', g:QuoteComplete_Single),
	\       ingo#plugin#setting#GetBufferLocal('QuoteComplete_Double', g:QuoteComplete_Double),
	\       ingo#plugin#setting#GetBufferLocal('QuoteComplete_Any', g:QuoteComplete_Any),
	\   ]),
	\   'v:val.char'
	\)
	let [s:isStartWithQuote, s:isEndWithQuote] = [0, 0]
	let l:startCol = searchpos('\%(\%(' . join(l:quotesCharPatterns, '\|') . '\).\{-}\|\k*\)\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	else
	    let l:quotedBase = strpart(getline('.'), l:startCol - 1, (col('.') - l:startCol))
	    let l:textAfterCursor = strpart(getline('.'), col('.') - 1)

	    for l:pattern in l:quotesCharPatterns   " Test each pattern individually to be able to test with the same char pattern at the end; with this we can support different begin- and end- characters for a quote (e.g. typographical ones).
		if l:quotedBase =~ '^' . l:pattern
		    let s:isStartWithQuote = 1

		    " Reduce the base to exclude the quote.
		    let l:startCol += len(matchstr(l:quotedBase, l:pattern))

		    if l:textAfterCursor =~ '^' . l:pattern
			let s:isEndWithQuote = 1
		    endif
		    break
		endif
	    endfor
	endif
	return l:startCol - 1 " Return byte index, not column.
    else
	" Find matches starting with a:base.
echomsg '****' string(a:base) string(a:quotes) s:isStartWithQuote s:isEndWithQuote
	let l:quotes = ingo#list#Make(a:quotes)
	let l:base = '\V' . escape(a:base, '\')

	let l:matches = []
	call CompleteHelper#Find(l:matches, function('QuoteComplete#FindQuotes'), {
	\   'complete': s:GetCompleteOption(),
	\   'base' : '^\%(' . join(map(copy(l:quotes), 'v:val.char'), '\|') . '\)' . l:base,
	\   'quotes': l:quotes
	\})

	if empty(l:matches)
	    echohl ModeMsg
	    echo '-- User defined completion (^U^N^P) -- Anywhere search...'
	    echohl None

	    call CompleteHelper#Find(l:matches, function('QuoteComplete#FindQuotes'), {
	    \   'complete': s:GetCompleteOption(),
	    \   'base' : l:base,
	    \   'quotes': l:quotes
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

	for l:quote in a:options.quotes
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

		if s:isStartWithQuote
		    let l:quotedString = matchstr(l:quotedString, '^\%(' . l:quote.char . '\)\zs.*\ze\%(' . l:quote.char . '\)$')

		    let l:quotedString = matchstr(l:quotedString, '.*\ze\%(' . l:quote.char . '\)$')
		    if s:isEndWithQuote
		    endif
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
