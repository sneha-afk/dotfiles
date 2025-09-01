-- .config/nvim/lua/plugins/vimtex.lua

return {
  "lervag/vimtex",
  enabled = (vim.fn.executable("tectonic") == 1) or (vim.fn.executable("pdflatex") == 1),
  ft = { "tex", "latex", "bib" },
  dependencies = {
    "erooke/blink-cmp-latex",
  },
  config = function()
    vim.g.tex_flavor = "latex"

    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      "Underfull",
      "Overfull",
    }

    if vim.fn.has("wsl") == 1 then
      vim.g.vimtex_view_general_viewer = os.getenv("PDF_READER_EXE") or "xdg-open"
    else
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
    end
    vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"

    local out_dir = "./build"
    vim.g.vimtex_compiler_method = vim.g.is_windows and "tectonic" or "latexmk"

    if vim.g.vimtex_compiler_method == "tectonic" then
      vim.g.vimtex_compiler_tectonic = {
        out_dir = out_dir,
        options = {
          "--keep-logs",
          "--synctex",
          "-Z",
          "shell-escape",
        },
      }

      -- Simulate continuous mode by recompiling on save
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*.tex",
        callback = function()
          vim.cmd("VimtexCompile")
        end,
      })
    else
      vim.g.vimtex_compiler_latexmk = {
        out_dir = out_dir,
        continuous = 1,
        options = {
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
          "-shell-escape",
          "-recorder",
        },
      }
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "tex", "latex", "bib" },
      callback = function()
        vim.keymap.set("n", "<leader>Lc", "<cmd>VimtexCompile<cr>",   { desc = "[L]aTeX: [C]ompile" })
        vim.keymap.set("n", "<leader>Lv", "<cmd>VimtexTocToggle<cr>", { desc = "[L]aTeX: Toggle [T]OC" })
        vim.keymap.set("n", "<leader>Lv", "<cmd>VimtexView<cr>",      { desc = "[L]aTeX: [V]iew" })

        -- Ensure output directory exists
        if vim.fn.isdirectory(out_dir) == 0 then
          vim.fn.mkdir(out_dir, "p")
        end

        -- Compile on start: if using latexmk, this also starts continuous mode
        vim.cmd("VimtexCompile")
      end,
    })
  end,
}
