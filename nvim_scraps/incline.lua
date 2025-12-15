-- .config/nvim/lua/plugins/incline.lua

return {
  "b0o/incline.nvim",
  enabled = false,
  event = "VeryLazy",
  config = function()
    local helpers = require("incline.helpers")
    local icons = vim.g.use_icons and require("mini.icons") or nil

    local function render_file_icon(filename)
      if not vim.g.use_icons or not icons then return {} end

      local ft_icon, ft_hl = icons.get("file", filename)
      if ft_icon and ft_hl then
        local hl_id = vim.fn.hlID(ft_hl)

        local fg_color = vim.fn.synIDattr(hl_id, "fg#")
        local bg_color = vim.fn.synIDattr(hl_id, "bg#")

        if fg_color and bg_color then
          return {
            " ",
            ft_icon,
            " ",
            guibg = bg_color,
            guifg = fg_color,
          }
        end
      end
      return ""
    end

    require("incline").setup({
      window = {
        padding = 0,
        margin = { horizontal = 0 },
      },
      render = function(props)
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
        if filename == "" then
          filename = "[No Name]"
        end

        local modified = vim.bo[props.buf].modified
        return {
          render_file_icon(filename),
          " ",
          { filename, gui = modified and "bold,italic" or "bold" },
          " ",
          -- guibg = "#44406e",
        }
      end,
    })
  end,
}
