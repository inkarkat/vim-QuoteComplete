" Test completion of double-quoted strings after another quote.

set completefunc=QuoteComplete#Double
edit QuoteComplete.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(3)

call IsMatchesInContext('My "another" is "', '" here', 'fo', ['for me', 'foobar', 'fox'], 'starting matches for "fo, followed by "')
call IsMatchesInContext('My "another" is "', ' here', 'fo', ['for me"', 'foobar"', 'fox"'], 'starting matches for "fo, followed by')
call IsMatchesInContext('My "another" is ', ' here', 'fo', [], 'no starting matches for fo, followed by')

call vimtest#Quit()
