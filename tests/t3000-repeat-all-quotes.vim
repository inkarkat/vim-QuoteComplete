" Test repeat of quote completion.

runtime tests/helpers/insert.vim
view QuoteComplete.txt
new

call SetCompletion("\<C-x>\"")
call SetCompleteExpr('QuoteComplete#Expr("QuoteComplete#Double")')

call InsertRepeat('my "foo', 0, 0, 0, 0, 0, 0)
call InsertRepeat('my "foo', 0, 0, 0, 0, 0)
call InsertRepeat('my "foo', 0, 0, 0, 0)
call InsertRepeat('my "foo', 0, 0, 0)
call InsertRepeat('my "foo', 0, 0)
call InsertRepeat('my "foo', 0)

call vimtest#SaveOut()
call vimtest#Quit()
