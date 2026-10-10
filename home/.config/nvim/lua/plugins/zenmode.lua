return {
  "folke/zen-mode.nvim",
  opts = {
    on_open = function()
      -- Save current statusline state
      vim.g.zen_laststatus = vim.o.laststatus
      vim.o.laststatus = 0

      -- Hide LSP diagnostics
      vim.diagnostic.enable(false)

      -- Disable completion popup
      vim.g.zen_completion_disabled = true

      require("cmp").setup.buffer({
        enabled = false,
      })
    end,

    on_close = function()
      -- Restore statusline
      vim.o.laststatus = vim.g.zen_laststatus or 3

      -- Restore LSP diagnostics
      vim.diagnostic.enable(true)

      -- Restore completion
      vim.g.zen_completion_disabled = false

      require("cmp").setup.buffer({
        enabled = true,
      })
    end,
  },
}
