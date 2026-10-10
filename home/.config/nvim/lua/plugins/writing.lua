return {
  {
    "lervag/vimtex",
    ft = { "tex", "latex", "plaintex" },
    init = function()
      vim.g.vimtex_view_method = "zathura" -- change to your PDF viewer if different
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0 -- don't yank focus on minor warnings
    end,
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    dependencies = { "folke/twilight.nvim" },
    opts = {
      window = {
        width = 90,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
        },
      },
      plugins = {
        twilight = { enabled = true }, -- dims everything outside the focused paragraph
      },
    },
  },
  {
    -- renders markdown headers/emphasis/lists inline as you write, no preview window needed
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "echasnovski/mini.nvim" },
    opts = {
      heading = { sign = false, position = "inline" },
    },
  },
  {
    "dhruvasagar/vim-table-mode",
    ft = "markdown",
    init = function()
      vim.g.table_mode_silent_mode = 1
    end,
  },
}
