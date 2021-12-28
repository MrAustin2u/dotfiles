require("Comment").setup({
  ignore = "^$",
  pre_hook = function(ctx)
    local U = require("Comment.utils")
    local type = ctx.ctype == U.ctype.line and "__default" or "__multiline"
    return require("ts_context_commentstring.internal").calculate_commentstring({
      key = type,
    })
  end,
  })
