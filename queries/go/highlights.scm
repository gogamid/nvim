;; extends

((comment) @comment.documentation
  (#match? @comment.documentation "^// "))

((comment) @comment.error
  (#match? @comment.error "\\c(error|fixme|deprecated)"))

((comment) @comment.warning
  (#match? @comment.warning "\\c(warning|fix|hack)"))

((comment) @comment.todo
  (#match? @comment.todo "\\c(todo|wip)"))

((comment) @comment.note
  (#match? @comment.note "\\c(note|info)"))

