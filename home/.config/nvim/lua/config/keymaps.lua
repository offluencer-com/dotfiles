local map = vim.keymap.set

-- File tree
map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Grep in project" })
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find buffer" })
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Help tags" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>", { desc = "Recent files" })

-- Window movement
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Basics
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Move selected lines up/down
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Writing mode toggle (defined properly once zen-mode plugin loads)
map("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Toggle zen/writing mode" })

map("n", "<C-t>", "<cmd>enew<CR>", { desc = "New buffer tab" })
map("n", "<C-x>", "<cmd>bdelete<CR>", { desc = "Close buffer tab" })

for i = 1, 9 do
  map("n", "<A-" .. i .. ">", "<cmd>BufferLineGoToBuffer " .. i .. "<CR>", { desc = "Go to buffer tab " .. i })
end

local wb = require("config.worldbuilding")
map("n", "<leader>nc", wb.new_character, { desc = "New character" })
map("n", "<leader>nh", wb.new_house, { desc = "New house" })
map("n", "<leader>nl", wb.new_location, { desc = "New location" })
map("n", "<leader>np", wb.new_plot, { desc = "New plot entry" })
map("n", "<leader>ny", wb.new_history, { desc = "New history entry" })
map("n", "<leader>nb", wb.new_brainstorm, { desc = "New brainstorm entry" })
map("n", "<leader>ni", wb.build_index, { desc = "Rebuild wiki index" })
