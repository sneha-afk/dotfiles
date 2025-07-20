-- .config/nvim/lua/plugins/vimtex.lua

return {
  "lervag/vimtex",
  ft = { "tex", "latex", "bib" },
  init = function()
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
  end,
}
