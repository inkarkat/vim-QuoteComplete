" Test completion of corner case double-quoted strings.

set completefunc=QuoteComplete#Double
edit QuoteComplete.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(3)

call IsMatchesInIsolatedLine('meet', ["\"meet at\t30\\\"\t16'\""], 'match for meet')
call IsMatchesInIsolatedLine('escaped', ['"\"escaped doubled double\""'], 'match for escaped')
call vimtap#collections#DoesNotContain(GetMatchesInIsolatedLine(''''), ['"''"'], 'does not contain match for '', because it is seen as start of base')

call vimtest#Quit()
