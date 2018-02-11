" Test repeat of quote completion with keywords in between.

source ../helpers/insert.vim
view QuoteComplete.txt
new

call SetCompletion("\<C-x>\"")
call SetCompleteExpr('QuoteComplete#Expr("QuoteComplete#Double")')

call InsertRepeat('my "meet', 0, 0, 0, 0, 0, 0)
call InsertRepeat('my "meet', 0, 0, 0, 0, 0)
call InsertRepeat('my "meet', 0, 0, 0, 0)
call InsertRepeat('my "meet', 0, 0, 0)
call InsertRepeat('my "meet', 0, 0)
call InsertRepeat('my "meet', 0)

call vimtest#SaveOut()
call vimtest#Quit()
