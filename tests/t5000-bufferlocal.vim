" Test completion of single-quoted strings with simpler buffer-local config.

set completefunc=QuoteComplete#Single
edit vimscript.txt

let b:QuoteComplete_Single = {'pattern': "'[^']\\+'", 'char': "'"}

source ../helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(2)

call IsMatchesInIsolatedLine('escap', ["'escaping in '", "'escape'"], 'starting matches for escap')
call IsMatchesInIsolatedLine('mislead', ["'misleading \\'"], 'starting match for mislead')

call vimtest#Quit()
