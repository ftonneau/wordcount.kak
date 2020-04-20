# wordcount.kak

This plugin for the Kakoune editor allows you to count characters, words, lines, and paragraphs in
the current selection. Counting proceeds on whole lines and is done by calling the `woc` command (an
alias for `wordcount-count`) in Normal mode. If you want counts for the whole document, select the
buffer with `%` before calling `woc`.

## Installation

Put the `wordcount.kak` file in your autoload directory (or in one of its subdirectories).

## License

MIT

