" Test completion of double-quoted strings.

set completefunc=QuoteComplete#Double
edit QuoteComplete.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(9)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('not enough', [], 'no matches for incomplete not enough')
call IsMatchesInIsolatedLine('foo', ['"foobar"'], 'starting match for foo')
call IsMatchesInIsolatedLine('fo', ['"foobar"', '"for me"', '"fox"'], 'starting matches for fo')

call IsMatchesInContext('My "', '', 'fo', ['for me"', 'foobar"', 'fox"'], 'starting matches for "fo')
call IsMatchesInContext('My "', '" here', 'fo', ['for me', 'foobar', 'fox'], 'starting matches for "fo, followed by "')
call IsMatchesInContext('My ', '" here', 'fo', ['"for me"', '"foobar"', '"fox"'], 'starting matches for fo, followed by "')
call IsMatchesInContext('My "', 'added" here', 'fo', ['for me"', 'foobar"', 'fox"'], 'starting matches for "fo, followed by added"')

call IsMatchesInContext('My "', '', 'a st', ['a stoned ''wreck''"', 'a stuffed teddy"'], 'starting matches for "a st')

call vimtest#Quit()
