; extends

( 
  (comment) @trigger
  .
  (variable_declaration 
  (assignment_statement ((expression_list (string (string_content) @injection.content ))))
    )
  (#match? @trigger "language: scheme")
  (#set! injection.language "scheme")
)


