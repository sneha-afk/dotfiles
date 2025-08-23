-- .config/nvim/lua/plugins/vimtex.lua

return {
  "lervag/vimtex",
  enabled = vim.fn.has("unix") == 1,
  ft = { "tex", "latex", "bib" },
  config = function()
    vim.g.tex_flavor = "latex"

    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_compiler_latexmk = {
      out_dir = "./build",
      continuous = 1,
      options = {
        "-verbose",
        "-file-line-error",
        "-synctex=1",
        "-interaction=nonstopmode",
        "-shell-escape",
      },
    }

    if vim.fn.has("wsl") == 1 then
      vim.g.vimtex_view_general_viewer = os.getenv("PDF_READER_EXE")
    else
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
    end
    vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"

    -- Start continuous mode by compiling on start
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        vim.cmd("VimtexCompile")
      end,
    })
  end,
}
