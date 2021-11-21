" Test completion of any-quoted strings with existing quoting.

set completefunc=QuoteComplete#Any
edit QuoteComplete.txt

runtime tests/helpers/completetest.vim
call vimtest#StartTap()
call vimtap#Plan(14)

call IsMatchesInContext('My ''', '', 'fo', ["for me'", "foobar'", "fox'", "fooxy'", "fock me'"], 'starting matches for ''fo')
call IsMatchesInContext('My ''', ''' here', 'fo', ["for me", "foobar", "fox", "fooxy", "fock me"], 'starting matches for ''fo, followed by ''')
call IsMatchesInContext('My ', ''' here', 'fo', ['"for me"', '"foobar"', '"fox"', "'fooxy'", "`fock me`"], 'starting matches for fo, followed by ''')
call IsMatchesInContext('My ''', 'added'' here', 'fo', ["for me'", "foobar'", "fox'", "fooxy'", "fock me'"], 'starting match for ''fo, followed by added''')

call IsMatchesInContext('My "', '', 'fo', ['for me"', 'foobar"', 'fox"', 'fooxy"', 'fock me"'], 'starting matches for "fo')
call IsMatchesInContext('My "', '" here', 'fo', ['for me', 'foobar', 'fox', 'fooxy', 'fock me'], 'starting matches for "fo, followed by "')
call IsMatchesInContext('My ', '" here', 'fo', ['"for me"', '"foobar"', '"fox"', "'fooxy'", '`fock me`'], 'starting matches for fo, followed by "')
call IsMatchesInContext('My "', 'added" here', 'fo', ['for me"', 'foobar"', 'fox"', 'fooxy"', 'fock me"'], 'starting matches for "fo, followed by added"')

call IsMatchesInContext('My `', '', 'fo', ['for me`', 'foobar`', 'fox`', 'fooxy`', 'fock me`'], 'starting matches for `fo')
call IsMatchesInContext('My `', '` here', 'fo', ['for me', 'foobar', 'fox', 'fooxy', 'fock me'], 'starting matches for `fo, followed by `')
call IsMatchesInContext('My ', '` here', 'fo', ['"for me"', '"foobar"', '"fox"', "'fooxy'", '`fock me`'], 'starting matches for fo, followed by `')
call IsMatchesInContext('My `', 'added` here', 'fo', ['for me`', 'foobar`', 'fox`', 'fooxy`', 'fock me`'], 'starting matches for `fo, followed by added`')

call IsMatchesInIsolatedLine('st', ['''" volutpat a, "a stoned ''', '`comment "middle ''inner'' one" nesting`', '" nesting` congue "', '"a stoned ''wreck''"', '`backticked stuff`', '"a stuffed teddy"'], 'inner matches for st')
call IsMatchesInIsolatedLine('wre', ["'wreck'"], 'starting match for wre')

call vimtest#Quit()
