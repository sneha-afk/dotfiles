-- .config/nvim/lua/plugins/oil.lua

local function ignore_files(name)
  local ignores = {
    static = {
      [".git"] = true,
      ["node_modules"] = true,
      ["__pycache__"] = true,
      [".DS_Store"] = true,
      ["package-lock.json"] = true,
      ["yarn.lock"] = true,
      ["Cargo.lock"] = true,
      ["pnpm-lock.yaml"] = true,
    },
    patterns = {
      "%.lock$", "%.tmp$", "%.bak$", "%.sw[po]$", "%.py[co]$",
      "^%..*%.swp$", "^[dD]ebug$", "^[rR]elease$", "^target$",
      "^dist$", "^build$", "^venv$", "^%.venv$", "^%.cache$",
      "^%.idea$", "^%.vscode$", "^%.history$",
    },
  }

  -- O(1) lookup -> fast path
  if ignores.static[name] then
    return true
  end

  -- Compile + cache regexes upon first call
  if not ignores.compiled then
    local compiled = {}
    for _, pattern in ipairs(ignores.patterns) do
      table.insert(compiled, { pattern = pattern, re = vim.regex(pattern) })
    end
    ignores.compiled = compiled
  end

  for _, item in ipairs(ignores.compiled) do
    if item.re:match_str(name) then
      return true
    end
  end

  return false
end

return {
  "stevearc/oil.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>e", "<cmd>Oil --float<cr>", desc = "Open files" },
    { "-",         "<cmd>Oil<cr>",         desc = "Open file tree" },
  },
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
    default_file_explorer = true,

    -- System trash instead of permanently deleting
    delete_to_trash = true,

    -- File operations filtering
    skip_confirm_for_simple_edits = true,
    prompt_save_on_select_new_entry = false,
    cleanup_delay_ms = 2000,
    constrain_cursor = "name",


    -- Unified filtering across all features
    view_options = {
      show_hidden = true,
      is_always_hidden = ignore_files,
    },
    -- Column display
    columns = {
      -- "icon",
      -- "permissions",
      {
        "size",
        highlight = "Number",
        format = function(size)
          if size < 1024 then
            return tostring(size) .. "B"
          elseif size < 1024 * 1024 then
            return string.format("%.1fK", size / 1024)
          else
            return string.format("%.1fM", size / (1024 * 1024))
          end
        end,
      },
      {
        "mtime",
        format = "%Y-%m-%d %H:%M",
        highlight = "Define",
      },
    },


    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    win_options = {
      cursorline = true,
      winblend = 5,
    },
    float = {
      max_width = 0.95,
      max_height = 0.70,
      border = "rounded",
    },

    keymaps = {
      ["<localleader>p"] = "actions.preview",
    },
  },
}
