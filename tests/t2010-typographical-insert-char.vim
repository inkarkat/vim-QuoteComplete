" Test completion with typographically quoted inserted chars.

scriptencoding utf-8

set completefunc=QuoteComplete#Any
edit ++enc=utf-8 typographical.txt

source ../helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(6)

call IsMatchesInContext('My ', '', 'plain', ["plain single", "plain double", "plain backtick"], 'starting matches for U+0091plain')
call IsMatchesInContext('My ‘', '', 'plain', ["plain single’", "plain double’", "plain backtick’"], 'starting matches for U+2018plain')
call IsMatchesInContext('My ‚', '', 'plain', ["plain single’", "plain double’", "plain backtick’"], 'starting matches for U+201Aplain')
call IsMatchesInContext('My “', '', 'plain', ["plain single”", "plain double”", "plain backtick”"], 'starting matches for U+201Cplain')
call IsMatchesInContext('My „', '', 'plain', ["plain single”", "plain double”", "plain backtick”"], 'starting matches for U+201Eplain')
call IsMatchesInContext('My ”', '', 'plain', ["'plain single'", '"plain double"', '`plain backtick`'], 'starting matches for U+201Dplain')

call vimtest#Quit()
