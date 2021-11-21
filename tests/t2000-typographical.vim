" Test completion of typographically quoted strings.

scriptencoding utf-8
set encoding=utf-8

edit ++enc=utf-8 typographical.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(10)

set completefunc=QuoteComplete#Any
call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
set completefunc=QuoteComplete#Single
call IsMatchesInIsolatedLine('', ["'plain single'"], 'all single matches')
set completefunc=QuoteComplete#Double
call IsMatchesInIsolatedLine('', ['"plain double"'], 'all double matches')
set completefunc=QuoteComplete#Any

call IsMatchesInIsolatedLine('special', ['special upper ASCII', '‘special single’', '‚special single low’', '“special double”', '„special double low”'], 'starting matches for special')
call IsMatchesInIsolatedLine('quirky', [], 'no matches for quirky')
call IsMatchesInIsolatedLine('single', ["'plain single'", '‘special single’', '‚special single low’'], 'inner matches for single')

call IsMatchesInContext('My ''', '', 'single', ["plain single'", "special single'", "special single low'"], 'inner matches for ''single')
call IsMatchesInContext('My ''', '''here ', 'single', ["plain single", "special single", "special single low"], 'inner matches for ''single, followed by ''')
call IsMatchesInContext('My ', '''here ', 'single', ["'plain single'", '‘special single’', '‚special single low’'], 'inner matches for single, followed by ''')
call IsMatchesInContext('My ''', 'added'' here', 'single', ["plain single'", "special single'", "special single low'"], 'inner matches for ''single, followed by added''')

call vimtest#Quit()
