-- ===================================================================
-- Filetype Specific Settings
-- ===================================================================
local ft = vim.api.nvim_create_augroup('FileTypeSettings', { clear = true })

-- C files: enable cindent
vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = "c",
  command = "setlocal cindent"
})

-- Make/Go files: use actual tabs
vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = {"make", "go"},
  command = "setlocal noexpandtab"
})

-- Markdown/TeX files: enable spellcheck and wrapping
vim.api.nvim_create_autocmd("FileType", {
  group = ft,
  pattern = {"markdown", "tex"},
  command = "setlocal spell wrap linebreak"
})
