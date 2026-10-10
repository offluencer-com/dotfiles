-- nvim-treesitter's "master" branch (the old .configs API) is effectively
-- legacy and stops tracking Neovim's own treesitter internals as core
-- evolves. On very new Neovim (0.12+) that mismatch crashes highlighting.
-- "main" is the actively maintained rewrite built to track core changes,
-- so that's what we use here - the API is just different (no .configs
-- module, no highlight.enable option; you install parsers and then start
-- highlighting yourself via an autocmd, which nvim-treesitter's own docs
-- recommend doing for every filetype with a pcall guard).

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  lazy = false,
  config = function()
    require("nvim-treesitter").install({
      "lua", "vim", "vimdoc", "query",
      "python", "javascript", "typescript", "tsx", "html", "css",
      "c", "cpp", "rust", "go",
      "bash", "json", "yaml", "toml",
      "markdown", "markdown_inline",
    })

    -- Auto-start highlighting for any filetype that has an installed
    -- parser; pcall so filetypes without one don't error.
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- Treesitter-based indentation (optional but nice - remove this
    -- block if it ever misbehaves, plain smartindent still applies)
    vim.api.nvim_create_autocmd("FileType", {
      callback = function()
        pcall(function()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end)
      end,
    })
  end,
}
