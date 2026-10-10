return {
  "akinsho/bufferline.nvim",
  event = "VeryLazy",
  dependencies = { "echasnovski/mini.nvim" },
  opts = {
    options = {
      mode = "buffers",
      diagnostics = "nvim_lsp",
      separator_style = "thin",
      show_buffer_close_icons = false,
      show_close_icon = false,
      always_show_bufferline = false,
    },
  },
  config = function(_, opts)
    require("bufferline").setup(opts)
  end,
}
