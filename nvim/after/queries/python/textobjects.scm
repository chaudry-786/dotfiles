; extends
; https://tree-sitter.github.io/tree-sitter/playground
; Module docstring
(module . (expression_statement (string) @comment.outer))

; Class docstring
(class_definition
  body: (block . (expression_statement (string) @comment.outer)))

; Function/method docstring
(function_definition body: (block . (expression_statement (string) @comment.outer)))

; Attribute docstring
((expression_statement (assignment)) . (expression_statement (string) @comment.outer))

