-- .config/nvim/lua/core/autocmds.lua

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace and extra newlines at EOF upon saves",
  callback = function()
    local filetype = vim.bo.filetype
    local buftype = vim.bo.buftype

    -- Skip special buffers
    if buftype ~= "" then return end

    -- Skip these filetypes
    local excluded_filetypes = {
      diff = true,
      gitcommit = true,
    }
    if excluded_filetypes[filetype] then return end

    local curpos = vim.api.nvim_win_get_cursor(0)
    pcall(function()
      vim.cmd([[keeppatterns %s/\s\+$//e]])   -- Remove trailing whitespace
      vim.cmd([[silent! %s/\%(\n\+\%$\)//e]]) -- Remove extra newlines at EOF
    end)

    -- Restore position: account for cursor being in those extra newlines
    local new_line_count = vim.api.nvim_buf_line_count(0)
    if curpos[1] > new_line_count then
      curpos[1] = math.max(1, new_line_count)
    end
    vim.api.nvim_win_set_cursor(0, curpos)
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked lines",
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 300, })
  end,
})
