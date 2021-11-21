" Test completion of any-quoted strings.

set completefunc=QuoteComplete#Any
edit QuoteComplete.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(6)

call IsMatchesInIsolatedLine('doesnotexist', [], 'no matches for doesnotexist')
call IsMatchesInIsolatedLine('foo', ['"foobar"', "'fooxy'"], 'starting matches for foo')
call IsMatchesInIsolatedLine('co', ['"complete"', '`comment "middle ''inner'' one" nesting`'], 'starting matches for co')
call IsMatchesInIsolatedLine('stuff', ['`backticked stuff`', '"a stuffed teddy"'], 'inner matches for stuff')
call vimtap#collections#DoesNotContain(GetMatchesInIsolatedLine('"'), ['''"''', '"''"', '`''''`'], 'does not contain match for ", because it is seen as start of base')
call vimtap#collections#DoesNotContain(GetMatchesInIsolatedLine("'"), ['''"''', '"''"', '`''''`'], 'does not contain match for '', because it is seen as start of base')

call vimtest#Quit()
