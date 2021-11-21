if g:runVimTest =~# 'typographical'
    set encoding=utf-8
endif

call vimtest#AddDependency('vim-ingo-library')
call vimtest#AddDependency('vim-CompleteHelper')

runtime plugin/QuoteComplete.vim
