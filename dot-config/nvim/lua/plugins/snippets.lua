-- .config/nvim/lua/plugins/lsp/snippets.lua
-- Configures snippet engine, lazy-loaded by completions.lua

return {
  "L3MON4D3/LuaSnip",
  lazy = true,
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  opts = {
    history = true,
    region_check_events = "InsertEnter",
    update_events = "TextChanged,TextChangedI",
    delete_check_events = "TextChanged",
  },
  config = function(_, opts)
    require("luasnip").config.setup(opts)

    require("luasnip.loaders.from_vscode").lazy_load({
      paths = {
        vim.fn.stdpath("data") .. "/lazy/friendly-snippets", -- Built-in vscode-style snippets
        vim.fn.stdpath("config") .. "/snippets",             -- Personal snippets in .config/nvim/snippets
        vim.uv.cwd() .. "/.nvim/snippets"                    -- Project-specific snippets
      }
    })

    vim.api.nvim_create_user_command("EditSnippets", function()
      require("luasnip.loaders").edit_snippet_files({
        format = function(file, source_name)
          local path_replacements = {
            ["/.local/share/nvim/lazy/friendly%-snippets"] = "FriendlySnippets",
            ["/.config/nvim/snippets"] = "Personal",
            ["/dotfiles/dot%-config/nvim/snippets"] = "Personal",
            [vim.uv.cwd() .. "/.nvim/snippets"] = "Project",
            ["/.local/share/nvim/lazy/LuaSnip"] = "LuaSnip",
          }

          for pattern, label in pairs(path_replacements) do
            if file:find(pattern) then
              local filename = file:match(".*/(.*)$") or file
              return string.format("%s : %s", label, filename)
            end
          end
          return file
        end
      })
    end, { desc = "Open snippet files for editing" })
  end
}
