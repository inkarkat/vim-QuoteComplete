" Test repeat of any-quote completion with keywords in between.

source ../helpers/insert.vim
view QuoteComplete.txt
new

call SetCompletion("\<C-x>`")

call InsertRepeat('my escaped', 1, 0, 0, 0, 0, 0)
call InsertRepeat('my escaped', 1, 0, 0, 0, 0)
call InsertRepeat('my escaped', 1, 0, 0, 0)
call InsertRepeat('my escaped', 1, 0, 0)
call InsertRepeat('my escaped', 1, 0)
call InsertRepeat('my escaped', 1)

call vimtest#SaveOut()
call vimtest#Quit()
