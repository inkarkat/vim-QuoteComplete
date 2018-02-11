" Test completion of double-quoted strings before another quote.

set completefunc=QuoteComplete#Double
edit QuoteComplete.txt

source ../helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(3)

call IsMatchesInContext('My "', '" here "another"', 'fo', ['for me', 'foobar', 'fox'], 'starting matches for "fo, followed by "')
call IsMatchesInContext('My "', ' here "another"', 'fo', ['for me"', 'foobar"', 'fox"'], 'starting matches for "fo, followed by')
call IsMatchesInContext('My ', ' here "another"', 'fo', ['"for me"', '"foobar"', '"fox"'], 'starting matches for fo, followed by')

call vimtest#Quit()
