return {
  "akinsho/toggleterm.nvim",
  version = "*",
  keys = { [[<C-`>]], { "<leader>t", desc = "Toggle terminal" } },
  opts = {
    open_mapping = [[<C-`>]],
    direction = "horizontal",
    size = 15,
    persist_mode = true,
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { desc = "Toggle terminal" })
  end,
}
