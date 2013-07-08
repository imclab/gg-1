Some notes if you want to hack on this and submit pull requests:
---------------------------------

If you use Emacs, please set indent-tab-modes to nil and run M-x
whitespace-cleanup on files before submitting pull requests. (If you
want to be hardcore, add whitespace-cleanup to before-save-hook to do
it all the time.) If you don't use Emacs, please do your best to
remove trailing spaces from lines. This reduces the number of lines of
diff output we need to look at be removing all changes due to
unimportant (and invisible) changes in spacing.

## If you use VIM:

Add the following to your ~/.vimrc file, as you like, removing the
lines that start with the `-` character.

2 space tabs

    set tabstop=2
    set shiftwidth=2
    set softtabstop=2
    set expandtab

Remove trailing whitespaces on save (:w)

    autocmd BufWritePre * :%s/\s\+$//e


Highlight trailing whitespace

    highlight ExtraWhitespace ctermbg=red guibg=red
    au ColorScheme * highlight ExtraWhitespace guibg=red
    au BufEnter * match ExtraWhitespace /\s\+$/
    au InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
    au InsertLeave * match ExtraWhiteSpace /\s\+$/


## Setting up gh-pages as subfolder of gg/

    mkdir public/
    cd public
    git clone git@github.com:sirrice/gg.git .
    git checkout origin/gh-pages -b gh-pages
    git branch -d master



