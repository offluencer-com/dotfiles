return {
  "nvim-tree/nvim-tree.lua",
  cmd = "NvimTreeToggle",
  -- the actual <leader>e mapping lives in lua/config/keymaps.lua only;
  -- it calls :NvimTreeToggle, which lazy.nvim intercepts to load this
  -- plugin on first use. Defining keys here too caused a double-binding.
  opts = {
    view = { width = 30, side = "left" },
    renderer = { group_empty = true, icons = { show = { git = true, folder = true, file = true, folder_arrow = true } } },
    filters = { dotfiles = false },
    git = { enable = true },
  },
}
