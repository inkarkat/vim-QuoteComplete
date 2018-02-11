" Test completion of single-quoted strings with Vimscript-specific config.

set completefunc=QuoteComplete#Single
filetype plugin on
edit +setf\ vim vimscript.txt

source ../helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(2)

call IsMatchesInIsolatedLine('escap', ["'escaping in ''single'' quote'", "'escape'"], 'starting matches for escap')
call IsMatchesInIsolatedLine('mislead', ["'misleading \\'"], 'starting match for mislead')

call vimtest#Quit()
