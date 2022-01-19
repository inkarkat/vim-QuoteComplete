QUOTE COMPLETE
===============================================================================
_by Ingo Karkat_

DESCRIPTION
------------------------------------------------------------------------------

This plugin ...

### SOURCE
(Original Vim tip, Stack Overflow answer, ...)

### SEE ALSO

- Check out the CompleteHelper.vim plugin page ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)) for a full
  list of insert mode completions powered by it.

### RELATED WORKS

- StringComplete.vim ([vimscript #2238](http://www.vim.org/scripts/script.php?script_id=2238)) provides basic single- and double-quote
  completion and was the inspiration for this plugin. It isn't configurable
  and doesn't benefit from the CompleteHelper.vim infrastructure, but is a
  simpler, single-script alternative.

USAGE
------------------------------------------------------------------------------

    In insert mode, invoke the completion via CTRL-X ', CTRL-X ", CTRL-X `.
    You can then search forward and backward via CTRL-N / CTRL-P, as usual.

    CTRL-X '                Find matches for single-quoted strings starting with
                            (or at least containing somewhere as a fallback) the
                            text before the cursor, either up to a previous single
                            quote, or just the keyword before the cursor. Existing
                            quotes around the cursor will be kept and preferred
                            over the ones in the matched string.
                            Further use of CTRL-X ' will copy the following quote
                            (separated by whitespace or glue characters), or the
                            next keyword.

    CTRL-X "                Same, but for double-quoted strings.

    CTRL-X `                Same, but for any kind of quoted string.

INSTALLATION
------------------------------------------------------------------------------

The code is hosted in a Git repo at
    https://github.com/inkarkat/vim-QuoteComplete
You can use your favorite plugin manager, or "git clone" into a directory used
for Vim packages. Releases are on the "stable" branch, the latest unstable
development snapshot on "master".

This script is also packaged as a vimball. If you have the "gunzip"
decompressor in your PATH, simply edit the \*.vmb.gz package in Vim; otherwise,
decompress the archive first, e.g. using WinZip. Inside Vim, install by
sourcing the vimball or via the :UseVimball command.

    vim QuoteComplete*.vmb.gz
    :so %

To uninstall, use the :RmVimball command.

### DEPENDENCIES

- Requires Vim 7.0 or higher.
- Requires the ingo-library.vim plugin ([vimscript #4433](http://www.vim.org/scripts/script.php?script_id=4433)), version 1.010 or
  higher.
- Requires the CompleteHelper.vim plugin ([vimscript #3914](http://www.vim.org/scripts/script.php?script_id=3914)), version 1.50 or
  higher.

CONFIGURATION
------------------------------------------------------------------------------

For a permanent configuration, put the following commands into your vimrc:

By default, the 'complete' option controls which buffers will be scanned for
completion candidates. You can override that either for the entire plugin, or
only for particular buffers; see CompleteHelper\_complete for supported
values.

    let g:QuoteComplete_complete = '.,w,b,u'

The default patterns for quoted strings allow escaping of quotes via a
backslash, e.g. "this is \\"one\\" quote". You can change this, also for
individual filetypes (via buffer-local variables overriding the global one),
to cater for different rules in particular languages.
Each configuration is a single Object or List of Objects with the following
attributes:
    - char:     the quote character
    - pattern:  regular expression matching the entire quoted string
                (including the quotes)
    - endChar:  optional, for when the ending quote is different from the
                starting one
For example, to configure simple double quotes without escaping:

    let g:QuoteComplete_Double = {
    \   'char': '"',
    \   'pattern': '"[^"]\+"'
    \}

If you want to use different mappings, map your keys to the
&lt;Plug&gt;(QuoteComplete...) mapping targets _before_ sourcing the script
(e.g. in your vimrc):

    imap <C-x>' <Plug>(QuoteCompleteSingle)
    imap <C-x>" <Plug>(QuoteCompleteDouble)
    imap <C-x>` <Plug>(QuoteCompleteAny)

CONTRIBUTING
------------------------------------------------------------------------------

Report any bugs, send patches, or suggest features via the issue tracker at
https://github.com/inkarkat/vim-QuoteComplete/issues or email (address below).

HISTORY
------------------------------------------------------------------------------

##### GOAL
First published version.

##### 0.01    27-Nov-2014
- Started development.

------------------------------------------------------------------------------
Copyright: (C) 2014-2022 Ingo Karkat -
The logic in QuoteComplete#FindQuotes() is based on &lt;SID&gt;FindStrings() from -
the StringComplete.vim plugin ([vimscript #2238](http://www.vim.org/scripts/script.php?script_id=2238)) by Peter Hodge. -
The [VIM LICENSE](http://vimdoc.sourceforge.net/htmldoc/uganda.html#license) applies to this plugin.

Maintainer:     Ingo Karkat &lt;ingo@karkat.de&gt;
