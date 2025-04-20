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

vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Auto-clear LSP logs past 10 MB",
  callback = function()
    local log_path = ""
    if vim.fn.has("nvim-0.11") == 1 then
      log_path = vim.lsp.log.get_filename()
    else
      log_path = vim.fn.stdpath("log") .. "/lsp.log"
    end
    local max_size = 10 * 1024 * 1024

    local ok, stats = pcall((vim.uv or vim.loop).fs_stat, log_path)
    if ok and stats and stats.size > max_size then
      local file = io.open(log_path, "w")
      if file then
        file:close()
        vim.notify("Cleared LSP log (>10MB)", vim.log.levels.INFO)
      end
    end
  end,
})
