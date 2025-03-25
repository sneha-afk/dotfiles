-- ===================================================================
-- Terminal Settings
-- ===================================================================
-- On opening terminal, disable line numbers and clean gutter space
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "setlocal nonumber norelativenumber signcolumn=no"
})

-- Windows Terminal Cursor Shaping
if vim.env.WT_SESSION then
  vim.opt.guicursor = {
    "n-v-c:block",    -- Normal/visual/command mode: block cursor
    "i-ci-ve:ver25",  -- Insert mode: vertical bar
    "r-cr:hor20",     -- Replace mode: horizontal bar
    "o:hor50"         -- Operator-pending mode: wider horizontal bar
  }
end
