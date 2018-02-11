" Test completion of base within double-quoted strings.

set completefunc=QuoteComplete#Double
edit QuoteComplete.txt

source ../helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(5)

call IsMatchesInIsolatedLine('stuff', ['"a stuffed teddy"'], 'inner match for stuff')
call IsMatchesInIsolatedLine('y', ['"a stuffed teddy"'], 'inner match for y')
call IsMatchesInIsolatedLine('st', ['"a stoned ''wreck''"', '"a stuffed teddy"'], 'inner matches for st')

call IsMatchesInContext('My "', '" here', "\t", ["meet at\t30\\\"\t16'"], 'inner matches for "\t"')
call IsMatchesInContext('My "', '" here', ' ''w', ['a stoned ''wreck'''''], 'inner matches for " ''w"')

call vimtest#Quit()
