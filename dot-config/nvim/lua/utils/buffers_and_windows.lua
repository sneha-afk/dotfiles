-- ~/.config/nvim/lua/core/utils/buffers_and_windows.lua
-- Module of utility functions and constants

local M = {}

---Calculates centered dimensions using percentages for better responsiveness
---@param width_ratio? number 0.0 to 1.0 (default 0.85)
---@param height_ratio? number 0.0 to 1.0 (default 0.75)
---@return table dims { width, height, col, row }
function M.get_centered_dims(width_ratio, height_ratio)
  local w_ratio = width_ratio or 0.85
  local h_ratio = height_ratio or 0.75

  local width = math.max(math.floor(vim.o.columns * w_ratio), 40)
  local height = math.max(math.floor(vim.o.lines * h_ratio), 10)
  return {
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
  }
end

---Creates and returns the id of a new scratch buffer
---@param content? string[] Content to place into buffer
---@param modifiable? boolean default: true
---@param ft? string Filetype to set the buffer
---@return integer ID of scratch buffer
function M.create_scratch_buf(content, ft, modifiable)
  if modifiable ~= false then modifiable = true end -- handle nil

  local buf = vim.api.nvim_create_buf(false, true)
  local options = {
    buftype = "nofile",
    bufhidden = "wipe",
    swapfile = false,
    buflisted = false,
  }
  for opt, val in pairs(options) do
    vim.api.nvim_set_option_value(opt, val, { buf = buf })
  end

  if ft then vim.api.nvim_set_option_value("filetype", ft, { buf = buf }) end
  if content then vim.api.nvim_buf_set_lines(buf, 0, -1, false, content) end
  vim.api.nvim_set_option_value("modifiable", modifiable, { buf = buf })

  local map_opts = { buffer = buf, silent = true }
  vim.keymap.set("n", "q",     "<cmd>close<cr>", map_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", map_opts)
  return buf
end

---Opens a buffer within a floating window
---@param buf integer ID of buffer
---@param title string Title of the window
---@param opts? table Options for the window
function M.open_float_win(buf, title, opts)
  local dims = M.get_centered_dims()

  local win_config = vim.tbl_extend("force", {
    relative = "editor",
    width = dims.width,
    height = dims.height,
    col = dims.col,
    row = dims.row,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  }, opts or {})

  local win = vim.api.nvim_open_win(buf, true, win_config)
  vim.api.nvim_set_option_value("number",         false, { scope = "local", win = win })
  vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = win })
  return win
end

return M
