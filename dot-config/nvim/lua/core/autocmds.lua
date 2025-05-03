-- .config/nvim/lua/core/autocmds.lua

local function augroup(name)
  return vim.api.nvim_create_augroup("Autocmds_" .. name, { clear = true })
end

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("remove_whitespace"),
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
  group = augroup("hl_yank"),
  desc = "Highlight yanked lines",
  callback = function()
    vim.hl.on_yank({ higroup = "Visual", timeout = 300, })
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("clear_lsp_logs"),
  desc = "Auto-clear LSP logs past 10 MB",
  callback = function()
    local log_path = vim.lsp.log.get_filename()
    local max_size = 10 * 1024 * 1024

    local ok, stats = pcall(vim.uv.fs_stat, log_path)
    if ok and stats and stats.size > max_size then
      local file = io.open(log_path, "w")
      if file then
        file:close()
        vim.notify("Cleared LSP log (>10MB)", vim.log.levels.INFO)
      end
    end
  end,
})

-- From LazyVim
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  desc = "Automatically create directories for a new file",
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})
