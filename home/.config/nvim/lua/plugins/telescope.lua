return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
keys = { "<leader>ff", "<leader>fg", "<leader>fb", "<leader>fh", "<leader>fr" },
    "nvim-lua/plenary.nvim",
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  opts = {
    defaults = {
      layout_strategy = "horizontal",
      sorting_strategy = "ascending",
      file_ignore_patterns = { "%.git/", "node_modules" },
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    telescope.setup(opts)
    pcall(telescope.load_extension, "fzf")
  end,
}
