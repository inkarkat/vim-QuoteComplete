" QuoteComplete.vim: Insert mode completion of quoted strings.
"
" DEPENDENCIES:
"   - CompleteHelper.vim autoload script
"   - Complete/Repeat.vim autoload script
"   - ingo/collections.vim autoload script
"   - ingo/list QuoteComplete.vim autoload script
"   - ingo/plugin/setting.vim autoload script
"
" Copyright: (C) 2014 Ingo Karkat
"   The logic in QuoteComplete#FindQuotes() is based on <SID>FindStrings() from
"   the StringComplete.vim plugin (vimscript #2238) by Peter Hodge.
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"	002	01-Dec-2014	Change search logic in
"				QuoteComplete#FindQuotes() to restart _all_
"				quote searches after a quote was found. This
"				avoids missing quotes when there are unbalanced
"				quote chars inside another quote type.
"				Implement repeat.
"	001	27-Nov-2014	file creation
let s:save_cpo = &cpo
set cpo&vim

let s:repeatCnt = 0
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
    if s:repeatCnt
	if a:findstart
	    return col('.') - 1
	else
	    " First try to find another quote after the previous one.
	    " handle interjacent glue text like ", " or ": ".
	    let l:betweenQuotesExpr = '\S\{-}\s*'

	    " Need to translate the embedded ^@ newline into the \n atom.
	    let l:previousCompleteExpr = '\V' . substitute(escape(s:fullText, '\'), '\n', '\\n', 'g') . '\m'
	    let l:nextQuotePatterns =
	    \   join(
	    \       map(s:GetAllConfigs(), 'v:val.pattern'),
	    \       '\|'
	    \   )

	    let l:matches = []
	    call CompleteHelper#FindMatches(l:matches,
	    \   l:previousCompleteExpr . '\zs' . l:betweenQuotesExpr . '\%(' . l:nextQuotePatterns . '\)',
	    \   {'complete': s:GetCompleteOption(), 'processor': function('CompleteHelper#Repeat#Processor')}
	    \)
	    if empty(l:matches)
		" Fall back to complete keywords like the default completion.
		let l:nextKeywordPattern = CompleteHelper#Repeat#GetPattern(s:fullText, '')
		call CompleteHelper#FindMatches(l:matches,
		\   l:nextKeywordPattern,
		\   {'complete': s:GetCompleteOption(), 'processor': function('CompleteHelper#Repeat#Processor')}
		\)

		if empty(l:matches)
		    call CompleteHelper#Repeat#Clear()
		endif
	    endif

	    return l:matches
	endif
    endif

    if a:findstart
	" Locate the start of the quoted text (any possible quote) or keyword.
	let l:quotesConfig = s:GetAllConfigs()
	let l:quotesCharPatterns = map(
	\   copy(l:quotesConfig),
	\   'v:val.char'
	\)
	let l:quotesEndCharPatterns = map(
	\   copy(l:quotesConfig),
	\   's:GetEndChar(v:val)'
	\)

	let [s:isStartWithQuote, s:isEndWithQuote, s:baseQuote] = [0, 0, {}]
	let l:startCol = searchpos('\%(\V\%(' . join(l:quotesCharPatterns, '\|') . '\)\m.\{-}\|\k*\)\%#', 'bn', line('.'))[1]
	if l:startCol == 0
	    let l:startCol = col('.')
	else
	    let l:quotedBase = strpart(getline('.'), l:startCol - 1, (col('.') - l:startCol))
	    let l:textAfterCursor = strpart(getline('.'), col('.') - 1)

	    for l:idx in range(len(l:quotesCharPatterns))   " Test each pattern individually to be able to test with the same (end) char pattern at the end; with this we can support different begin- and end- characters for a quote (e.g. typographical ones).
		let [l:pattern, l:endPattern] = [l:quotesCharPatterns[l:idx], l:quotesEndCharPatterns[l:idx]]
		if l:quotedBase =~ '\V\^' . l:pattern
		    let s:isStartWithQuote = 1
		    let s:baseQuote = l:quotesConfig[l:idx]

		    " Reduce the base to exclude the quote.
		    let l:startCol += len(matchstr(l:quotedBase, l:pattern))

		    if l:textAfterCursor =~ '\V\^' . l:endPattern
			let s:isEndWithQuote = 1
		    endif
		    break
		endif
	    endfor
	endif
	return l:startCol - 1 " Return byte index, not column.
    else
	" Find matches starting with a:base.
	let l:quotes = ingo#list#Make(a:quotes)
"****D echomsg '****' string(getline('.')) string(a:base) string(a:quotes) s:isStartWithQuote s:isEndWithQuote string(s:baseQuote)
	let l:matches = []
	call CompleteHelper#Find(l:matches, function('QuoteComplete#FindQuotes'), {
	\   'complete': s:GetCompleteOption(),
	\   'base' : '\V\^\%(' . join(map(copy(l:quotes), 'v:val.char'), '\|') . '\)' . escape(a:base, '\'),
	\   'quotes': l:quotes
	\})

	if empty(l:matches) && ! empty(a:base)
	    echohl ModeMsg
	    echo '-- User defined completion (^U^N^P) -- Anywhere search...'
	    echohl None

	    call CompleteHelper#Find(l:matches, function('QuoteComplete#FindQuotes'), {
	    \   'complete': s:GetCompleteOption(),
	    \   'base' : '\V' . escape(a:base, '\'),
	    \   'quotes': l:quotes
	    \})
	endif

	return l:matches
    endif
endfunction

function! QuoteComplete#FindQuotes( lines, matches, matchTemplate, options, isInCompletionBuffer )
    for l:line in (empty(a:lines) ? s:GetCurrentLines(a:options) : a:lines)
	let l:startCols = [0]
	while ! empty(l:startCols)
	    let l:startCol = remove(l:startCols, 0)
	    for l:quote in a:options.quotes
		let l:col = l:startCol

		while 1
		    let l:quoteCol = match(l:line, '\V' . l:quote.char, l:col)
		    if l:quoteCol == -1
			break
		    endif

		    let l:quotedString = matchstr(l:line, l:quote.pattern, l:quoteCol)
		    if l:quotedString == ''
			break
		    endif

		    " Restart the search for starting quotes after the current
		    " quote match. As the iteration over the various quotes is
		    " nested _inside_ this search, this means that _any_ quotes
		    " are reconsidered. If we would just process each quote type
		    " one after the other sequentially, we would miss matches
		    " obscured by an unbalanced quote character contained in
		    " another quote, e.g. "O'Brian", 'foo'. The single-quoted
		    " search sees 'Brian", ', whereas the any-search
		    " (additionally) sees 'foo'.
		    let l:col = l:quoteCol + len(l:quotedString)
		    call add(l:startCols, l:col)

		    if l:quotedString !~# a:options.base
			break
		    endif

		    if s:isStartWithQuote
			let l:quotedString = matchstr(l:quotedString, '\V\^\%(' . l:quote.char . '\)\zs\.\*\ze\%(' . s:GetEndChar(l:quote) . '\)\$')

			if ! s:isEndWithQuote
			    " The original end quote has been removed; add the
			    " configured end char for the actual match.
			    let l:quotedString .= s:GetEndChar(s:baseQuote)
			endif
		    endif

		    let l:matchObj = copy(a:matchTemplate)
		    call CompleteHelper#AddMatch(a:matches, l:matchObj, l:quotedString, a:options)
		    break
		endwhile
	    endfor
	endwhile
    endfor
endfunction
function! s:GetAllConfigs()
    return ingo#collections#Flatten1([
    \   ingo#plugin#setting#GetBufferLocal('QuoteComplete_Single', g:QuoteComplete_Single),
    \   ingo#plugin#setting#GetBufferLocal('QuoteComplete_Double', g:QuoteComplete_Double),
    \   ingo#plugin#setting#GetBufferLocal('QuoteComplete_Any', g:QuoteComplete_Any),
    \])
endfunction
function! s:GetEndChar( quote )
    return (has_key(a:quote, 'endChar') ? a:quote.endChar : a:quote.char)
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



function! QuoteComplete#Expr( completionFunction )
    let &completefunc = a:completionFunction

    let s:repeatCnt = 0 " Important!
    let [s:repeatCnt, l:addedText, s:fullText] = CompleteHelper#Repeat#TestForRepeat()

    return "\<C-x>\<C-u>"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
