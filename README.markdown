CSS Prepare
===========

A minifier/preprocessor for CSS:

*   parses CSS from multiple files, including a limited form of inheritence
    to enable base stylesheets to be used intelligently

*   can emit warnings when encountering invalid CSS

*   accepts "colour" and "background-colour" properties for people that
    habitually spell correctly

*   optimises output CSS files by omitting unnecessary source elements such
    as comments, non-significant whitespace and redundant rules

*   useful preprocessing features, such as
    
    *   different block-level and line-level comment styles
    *   reusable definitions
    *   automatic expansion of commonly replicated CSS rules
        (eg. border-radius, -moz-border-radius, -webkit-border-radius)
