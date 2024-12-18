; extends

; neovim nightly 0.10
([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#match? @injection.content
    "(SELECT|select|INSERT|insert|UPDATE|update|DELETE|delete).+(FROM|from|INTO|into|VALUES|values|SET|set).*(WHERE|where|GROUP BY|group by)?")
  (#offset! @injection.content 0 0 0 0)
  (#set! injection.language "sql"))

; ----------------------------------------------------------------
; fallback keyword and comment based injection
; nvim 0.10
([
  (interpreted_string_literal_content)
  (raw_string_literal_content)
] @injection.content
  (#contains? @injection.content
    "-- sql" "--sql" "ADD CONSTRAINT" "ALTER TABLE" "ALTER COLUMN" "DATABASE" "FOREIGN KEY"
    "GROUP BY" "HAVING" "CREATE INDEX" "INSERT INTO" "NOT NULL" "PRIMARY KEY" "UPDATE SET"
    "TRUNCATE TABLE" "LEFT JOIN" "add constraint" "alter table" "alter column" "database"
    "foreign key" "group by" "having" "create index" "insert into" "not null" "primary key"
    "update set" "truncate table" "left join" "from" "values" "FROM" "VALUES")
  (#offset! @injection.content 0 0 0 0)
  (#set! injection.language "sql"))

; should I use a more exhaustive list of keywords?
;  "ADD" "ADD CONSTRAINT" "ALL" "ALTER" "AND" "ASC" "COLUMN" "CONSTRAINT" "CREATE" "DATABASE" "DELETE" "DESC" "DISTINCT" "DROP" "EXISTS" "FOREIGN KEY" "FROM" "JOIN" "GROUP BY" "HAVING" "IN" "INDEX" "INSERT INTO" "LIKE" "LIMIT" "NOT" "NOT NULL" "OR" "ORDER BY" "PRIMARY KEY" "SELECT" "SET" "TABLE" "TRUNCATE TABLE" "UNION" "UNIQUE" "UPDATE" "VALUES" "WHERE"
