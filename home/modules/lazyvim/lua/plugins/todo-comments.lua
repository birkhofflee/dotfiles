-- Highlight TODO/FIXME/etc. even without a trailing colon ("// TODO fix" as well as "// TODO: fix")
return {
  {
    "folke/todo-comments.nvim",
    opts = {
      highlight = { pattern = [[.*<(KEYWORDS)\s*:?]] },
      search = { pattern = [[\b(KEYWORDS)\b]] },
    },
  },
}
