-- .config/nvim/lsp/lua_ls.lua

return {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
      hint = {
        enable = true,
      },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
        },
      },
      runtime = {
        version = "LuaJIT",
      },
      format = {
        enable = true,
        defaultConfig = {
          indent_style = "space",
          indent_size = "2",
          continuation_indent_size = "2",
          quote_style = "double",
          align_call_args = true,
          space_around_assign = true,
          trailing_table_separator = "smart",
          insert_final_newline = false,
        },
      },
    },
  },
}
