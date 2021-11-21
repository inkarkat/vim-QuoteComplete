" Test completion of single-quoted strings.

set completefunc=QuoteComplete#Single
edit QuoteComplete.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(14)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('goes over', [], 'no matches for multi-line goes over')
call IsMatchesInIsolatedLine('foo', ["'fooxy'"], 'starting match for foo')
call IsMatchesInIsolatedLine('inn', ["'inner'"], 'starting match for inn')
call IsMatchesInIsolatedLine('wre', [], 'no starting match for wre; it is obscured by the unclosed 16''')
call IsMatchesInIsolatedLine('Brian', ["'single O\\'Brian'"], 'inner match for Brian')
call IsMatchesInIsolatedLine('Mega', ["'s Mr Mega'"], 'inner match for Mega')
call IsMatchesInIsolatedLine('escaped', ["'\\'escaped doubled single\\''"], 'match for escaped')
call vimtap#collections#DoesNotContain(GetMatchesInIsolatedLine('"'), ['''"'''], 'does not contain match for ", because it is seen as start of base')

call IsMatchesInContext('My ''', '', 'fo', ["fooxy'"], 'starting match for ''fo')
call IsMatchesInContext('My ''', ''' here', 'fo', ["fooxy"], 'starting match for ''fo, followed by ''')
call IsMatchesInContext('My ', ''' here', 'fo', ["'fooxy'"], 'starting match for fo, followed by ''')
call IsMatchesInContext('My ''', 'added'' here', 'fo', ["fooxy'"], 'starting match for ''fo, followed by added''')

call IsMatchesInContext('My ''', '', 'in here', ["in here \"multiple\" \"ones\"'"], 'starting matches for ''in here')

call vimtest#Quit()
