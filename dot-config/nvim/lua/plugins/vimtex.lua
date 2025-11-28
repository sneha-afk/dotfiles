-- .config/nvim/lua/plugins/vimtex.lua

---@return string|nil Returns nil if no compiler is found
local function detect_compiler()
  if vim.fn.executable("tectonic") == 1 then
    return "tectonic"
  elseif vim.fn.executable("latexmk") == 1 then
    return "latexmk"
  elseif vim.fn.executable("pdflatex") == 1 then
    return "pdflatex"
  else
    return nil
  end
end

local fts = { "tex", "latex", "bib" }

return {
  "lervag/vimtex",
  enabled = detect_compiler() ~= nil,
  cmd = { "VimtexCompile", "VimtexInverseSearch" },
  ft = fts,
  dependencies = {
    "erooke/blink-cmp-latex",
  },
  config = function()
    vim.g.tex_flavor = "latex"
    vim.g.vimtex_complete_enabled = 1

    vim.g.vimtex_quickfix_open_on_warning = 0
    vim.g.vimtex_quickfix_ignore_filters = {
      "Underfull",
      "Overfull",
    }

    if vim.g.is_windows then
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
      vim.g.vimtex_view_general_options = "-reuse-instance -forward-search @tex @line @pdf"
    elseif vim.fn.has("wsl") == 1 then
      vim.g.vimtex_view_general_viewer = os.getenv("PDF_READER_EXE") or "xdg-open"
    else
      vim.g.vimtex_view_general_viewer = "xdg-open"
      vim.g.vimtex_view_general_options = ""
    end

    local out_dir = "./build"
    vim.g.vimtex_compiler_method = detect_compiler()

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
        callback = function(args)
          local bufnr = args.buf
          local tick = vim.b[bufnr].changedtick

          -- Keep track of last compiled tick for this buffer
          if vim.b[bufnr].last_compiled_tick == nil then
            vim.b[bufnr].last_compiled_tick = -1
          end

          -- Only compile if there is a detetcted change to write
          if vim.b[bufnr].last_compiled_tick ~= tick then
            vim.b[bufnr].last_compiled_tick = tick
            vim.cmd("VimtexCompile")
          end
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
      pattern = fts,
      callback = function()
        vim.keymap.set("n", "<leader>Lc", "<cmd>VimtexCompile<cr>",   { desc = "[L]aTeX: [C]ompile" })
        vim.keymap.set("n", "<leader>Le", "<cmd>VimtexErrors<cr>",    { desc = "[L]aTeX: [E]rrors" })
        vim.keymap.set("n", "<leader>Li", "<cmd>VimtexInfo<cr>",      { desc = "[L]aTeX: [I]nfo" })
        vim.keymap.set("n", "<leader>Ll", "<cmd>VimtexLog<cr>",       { desc = "[L]aTeX: [L]og" })
        vim.keymap.set("n", "<leader>Ls", "<cmd>VimtexStatus<cr>",    { desc = "[L]aTeX: [S]tatus" })
        vim.keymap.set("n", "<leader>Lt", "<cmd>VimtexTocToggle<cr>", { desc = "[L]aTeX: Toggle [T]OC" })
        vim.keymap.set("n", "<leader>Lv", "<cmd>VimtexView<cr>",      { desc = "[L]aTeX: [V]iew" })

        -- Ensure output directory exists
        if vim.fn.isdirectory(out_dir) == 0 then
          vim.fn.mkdir(out_dir, "p")
        end
      end,
    })

    -- Compile on start: if using latexmk, this also starts continuous mode
    vim.api.nvim_create_autocmd("User", {
      pattern = "VimtexEventInitPost",
      callback = function()
        vim.cmd("VimtexCompile")
      end,
    })
  end,
}
