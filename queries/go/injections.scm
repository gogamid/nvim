;; extends

; a general query injection
([
   (interpreted_string_literal_content)
   (raw_string_literal_content)
 ] @sql
 (#match? @sql "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
)

; ----------------------------------------------------------------
; fallback keyword and comment based injection

([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
 ] @sql
 (#contains? @sql "-- sql" "--sql" "ADD CONSTRAINT" "ALTER TABLE" "ALTER COLUMN"
                  "DATABASE" "FOREIGN KEY" "GROUP BY" "HAVING" "CREATE INDEX" "INSERT INTO"
                  "NOT NULL" "PRIMARY KEY" "UPDATE SET" "TRUNCATE TABLE" "LEFT JOIN" "add constraint" "alter table" "alter column" "database" "foreign key" "group by" "having" "create index" "insert into"
                  "not null" "primary key" "update set" "truncate table" "left join")
 )

; should I use a more exhaustive list of keywords?
;  "ADD" "ADD CONSTRAINT" "ALL" "ALTER" "AND" "ASC" "COLUMN" "CONSTRAINT" "CREATE" "DATABASE" "DELETE" "DESC" "DISTINCT" "DROP" "EXISTS" "FOREIGN KEY" "FROM" "JOIN" "GROUP BY" "HAVING" "IN" "INDEX" "INSERT INTO" "LIKE" "LIMIT" "NOT" "NOT NULL" "OR" "ORDER BY" "PRIMARY KEY" "SELECT" "SET" "TABLE" "TRUNCATE TABLE" "UNION" "UNIQUE" "UPDATE" "VALUES" "WHERE"

; json

((const_spec
  name: (identifier) @_const
  value: (expression_list (raw_string_literal) @json))
 (#lua-match? @_const ".*[J|j]son.*"))

; jsonStr := `{"foo": "bar"}`

((short_var_declaration
    left: (expression_list
            (identifier) @_var)
    right: (expression_list
             (raw_string_literal) @json))
  (#lua-match? @_var ".*[J|j]son.*")
  (#offset! @json 0 1 0 -1))

(short_var_declaration
    left: (expression_list (identifier))
    right: (expression_list
             (raw_string_literal
               (raw_string_literal_content) @injection.content
               (#lua-match? @injection.content "^[\n|\t| ]*\{.*\}[\n|\t| ]*$")
               (#set! injection.language "json")
             )
    )
)

(var_spec
  name: (identifier)
  value: (expression_list
           (raw_string_literal
             (raw_string_literal_content) @injection.content
             (#lua-match? @injection.content "^[\n|\t| ]*\{.*\}[\n|\t| ]*$")
             (#set! injection.language "json")
           )
  )
)

(call_expression
  (selector_expression) @_function
  (#any-of? @_function
    "regexp.Match" "regexp.MatchReader" "regexp.MatchString" "regexp.Compile" "regexp.CompilePOSIX"
    "regexp.MustCompile" "regexp.MustCompilePOSIX")
  (argument_list
    .
    [
      (raw_string_literal)
      (interpreted_string_literal)
    ] @injection.content
    (#set! injection.language "regex")
    ))

; INJECT SQL
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*sql\\s*\\*\\/") ; /* sql */ or /*sql*/
    (#set! injection.language "sql")
)

; INJECT JSON
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*json\\s*\\*\\/") ; /* json */ or /*json*/
    (#set! injection.language "json")
)

; INJECT YAML
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*yaml\\s*\\*\\/") ; /* yaml */ or /*yaml*/
    (#set! injection.language "yaml")
)

; INJECT XML
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*xml\\s*\\*\\/") ; /* xml */ or /*xml*/
    (#set! injection.language "xml")
)

; INJECT HTML
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*html\\s*\\*\\/") ; /* html */ or /*html*/
    (#set! injection.language "html")
)

; INJECT JS
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*js\\s*\\*\\/") ; /* js */ or /*js*/
    (#set! injection.language "javascript")
)

; INJECT CSS
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*css\\s*\\*\\/") ; /* css */ or /*css*/
    (#set! injection.language "css")
)

; INJECT LUA
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*lua\\s*\\*\\/") ; /* lua */ or /*lua*/
    (#set! injection.language "lua")
)

; INJECT BASH
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*bash\\s*\\*\\/") ; /* bash */ or /*bash*/
    (#set! injection.language "bash")
)

; INJECT CSV
(
	[
		; var, const or short declaration of raw or interpreted string literal
		((comment) @comment
  		.
    	(expression_list
     	[
      		(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a literal element (to struct field eg.)
		((comment) @comment
        .
        (literal_element
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content
        ))

        ; when passing as a function parameter
        ((comment) @comment
        .
        [
        	(interpreted_string_literal)
        	(raw_string_literal)
        ] @injection.content)
    ]

    (#match? @comment "^\\/\\*\\s*csv\\s*\\*\\/") ; /* csv */ or /*csv*/
    (#set! injection.language "csv")
)
