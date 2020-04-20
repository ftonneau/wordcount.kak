# Count characters, words, lines, and paragraphs in selection.
# Author: Francois Tonneau

# VARIABLES

declare-option -hidden int wordcount_non_space_chars 0
declare-option -hidden int wordcount_all_chars       0

declare-option -hidden int wordcount_words           0

declare-option -hidden int wordcount_non_empty_lines 0
declare-option -hidden int wordcount_all_lines       0

declare-option -hidden int wordcount_paragraphs      0

# PUBLIC COMMANDS

define-command \
-docstring 'Count characters - words - lines - paragraphs' \
wordcount-count %{
    evaluate-commands %sh{
        if expr "$kak_selections_length" : '.* .*' >/dev/null; then
            printf %s\\n 'fail multiple selections not allowed'
            exit
        fi
        printf %s\\n wordcount-proceed
    }
}

alias global woc wordcount-count

# IMPLEMENTATION

define-command \
-hidden \
wordcount-proceed %{
    wordcount-grow-lines
    wordcount-count-chars
    wordcount-count-words
    wordcount-count-lines
    wordcount-count-pars
    wordcount-summarize
}

define-command \
-hidden \
wordcount-grow-lines %{
    execute-keys <a-x>
}

define-command \
-hidden \
wordcount-count-chars %{
    evaluate-commands %sh{
        bulk=$(printf %s "$kak_selection" \
            | tr -d '\n' \
            | wc -m \
        )
        nonspace=$(printf %s "$kak_selection" \
            | tr -d '\n' \
            | sed 's/[[:space:]]/ /g' \
            | tr -d ' ' \
            | wc -m \
        )
        printf %s\\n "set-option window wordcount_all_chars $bulk"
        printf %s\\n "set-option window wordcount_non_space_chars $nonspace"
    }
}

define-command \
-hidden \
wordcount-count-words %{
    evaluate-commands %sh{
        words=$( printf %s "$kak_selection" \
            | wc -w \
        )
        printf %s\\n "set-option window wordcount_words $words"
    }
}

define-command \
-hidden \
wordcount-count-lines %{
    evaluate-commands %sh{
        all=$( printf %s "$kak_selection" \
            | wc -l \
        )
        nonempty=$( printf %s "$kak_selection" \
            | sed -n /^$/!p \
            | wc -l \
        )
        printf %s\\n "set-option window wordcount_all_lines $all"
        printf %s\\n "set-option window wordcount_non_empty_lines $nonempty"
    }
}

define-command \
-hidden \
wordcount-count-pars %{
    #
    # Unless it is empty, consider the selection to be 1 paragraph by default.
    # Then count paragraph separations (\n\n [^\n]).
    try %{
        execute-keys -draft <a-k> [^\n] <ret>
        set-option window wordcount_paragraphs 1
    } \
    catch %{
        set-option window wordcount_paragraphs 0
    }
    evaluate-commands -draft %{
        try %{
            execute-keys s \n\n [^\n] <ret>
            evaluate-commands -itersel %{
                set -add window wordcount_paragraphs 1
            }
        }
    }
}

define-command \
-hidden \
wordcount-summarize %{
    info -title 'Word Count' \
"                          Words: %opt(wordcount_words)
    Characters, including space: %opt(wordcount_all_chars)
    Characters, excluding space: %opt(wordcount_non_space_chars)
                    Total lines: %opt(wordcount_all_lines)
                Non-empty lines: %opt(wordcount_non_empty_lines)
                     Paragraphs: %opt(wordcount_paragraphs)"
}

