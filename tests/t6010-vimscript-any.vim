" Test completion of quoted strings with Vimscript-specific config.

set completefunc=QuoteComplete#Any
filetype plugin on
edit +setf\ vim vimscript.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(6)

" Tests that the buffer-local Single config is used for Any completion.
call IsMatchesInIsolatedLine('escap', ["'escaping in ''single'' quote'", "'escape'"], 'starting matches for escap')
call IsMatchesInIsolatedLine('mislead', ["'misleading \\'"], 'starting match for mislead')
call IsMatchesInIsolatedLine('single', ["'simple single quote'", "'escaping in ''single'' quote'"], 'inner matches for single')
call IsMatchesInIsolatedLine('local', ['`=string(localtime())`'], 'inner match for local')

" Tests that a buffer-local override of the Any config has precedence.
let b:QuoteComplete_Any = [{'pattern': "'[^']\\+'", 'char': "'"}, {'pattern': '"[^"]\+"', 'char': '"'}]
call IsMatchesInIsolatedLine('escap', ["'escaping in '", "'escape'"], 'starting matches for escap')
call IsMatchesInIsolatedLine('local', [], 'no match for local')

call vimtest#Quit()
