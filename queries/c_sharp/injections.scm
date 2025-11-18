;; extends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;SQL;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

([
  (raw_string_content)
  (string_literal_content)

  (character_literal)
  (interpolated_string_expression)
  (interpolation_start)
  (interpolation_quote)
  ] @injection.content
 (#match? @injection.content "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
 (#set! injection.language "sql"))



; sql = @"select * from users";
(
(verbatim_string_literal) @injection.content
(#match? @injection.content "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete|UPSERT|upsert|DECLARE|declare).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
(#offset! @injection.content 0 2 0 -1)
(#set! injection.language "sql")
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;XML;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; //language=xml
; var xml = "<book><title>The Great Gatsby</title><author>F. Scott Fitzgerald</author><year>1925</year></book>";
(
(comment) @comment
.
(local_declaration_statement
  (variable_declaration
    (variable_declarator
      (string_literal
        (string_literal_content) @injection.content))))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
(#set! injection.combined)
)

; var xml = "";
; //language=xml
; xml = "<authors><author>John Doe</author></authors>";
(
(comment) @comment
.
(expression_statement
  (assignment_expression
    (string_literal
      (string_literal_content) @injection.content)))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
(#set! injection.combined)
)

; //language=xml
; var xml = @"<books><book id=""1""><title>The Great Gatsby</title><author>F. Scott Fitzgerald</author><year>1925</year></book></books>";
(
(comment) @comment
.
(local_declaration_statement
  (variable_declaration
    (variable_declarator
      (verbatim_string_literal) @injection.content)))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
(#offset! @injection.content 0 2 0 -1)
)

; var xml = string.Empty;
; //language=xml
; xml = @"<autos><auto id=""1""><make>Ford</make><model>Focus</model><year>2010</year></auto></autos>";
(
(comment) @comment
.
(expression_statement
  (assignment_expression
    (verbatim_string_literal) @injection.content))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
(#offset! @injection.content 0 2 0 -1)
)

; //language=xml
; var xml = """
;     <person>
;       <name>John Doe</name>
;       <age>30</age>
;     </person>
;     """;
(
(comment) @comment
.
(local_declaration_statement
  (variable_declaration
    (variable_declarator
      (raw_string_literal
        (raw_string_content) @injection.content))))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
)

; var xml = string.Empty;
; //language=xml
; xml = """
;     <?xml version="1.0" encoding="UTF-8"?>
;     <book>
;       <title>The Great Gatsby</title>
;       <author>F. Scott Fitzgerald</author>
;       <year>1925</year>
;     </book>
;     """;
(
(comment) @comment
.
(expression_statement
  (assignment_expression
    (raw_string_literal
      (raw_string_content) @injection.content)))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
)

; var title = "The Great Gatsby";
; var author = "F. Scott Fitzgerald";
; //language=xml
; var xml2 = $"""
;     <?xml version="1.0" encoding="UTF-8"?>
;     <book>
;       <title>{title}</title>
;       <author>{author}</author>
;       <year>1925</year>
;     </book>
;     """;
(
(comment) @comment
.
(local_declaration_statement
  (variable_declaration
    (variable_declarator
      (interpolated_string_expression
        (string_content) @injection.content))))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
(#set! injection.combined)
)

; var userId = 1;
; var email = "alice@example.com";
; var xml3 = string.Empty;
; //language=xml
; xml3 = $$"""
;     <users>
;       <user id="{userId}">
;         <name>Alice</name>
;         <email>{email}</email>
;       </user>
;     </users>
;     """;
(
(comment) @comment
.
(expression_statement
  (assignment_expression
    (interpolated_string_expression
      (string_content) @injection.content)))

(#eq? @comment "//language=xml")
(#set! injection.language "xml")
(#set! injection.combined)
)
