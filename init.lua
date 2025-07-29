local o = vim.o
local g = vim.g

--------------------------------- options --------------------------------------

vim.g.mapleader = " "

-- Indenting
o.expandtab = true
o.shiftwidth = 2
o.smartindent = true
o.tabstop = 2
o.softtabstop = 2

o.number = true;
o.relativenumber = true;
o.wrap = false;

o.colorcolumn = "80"
o.relativenumber = true
o.termguicolors = true

--------------------------------- plugins --------------------------------------

vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/sharkdp/fd" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = 'main' },
  { src = "https://github.com/nvim-telescope/telescope.nvim", tag = "0.1.8" },


  { src =     "https://github.com/stevearc/conform.nvim" },

})

vim.lsp.enable({"lua_ls", "clangd"})

--------------------------------- mappings -------------------------------------

local builtin = require "telescope.builtin"
local map = vim.keymap.set

map("n", "<leader>e", "<cmd>Ex<CR>", { desc = "See currect directory" })

map("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
map("n", "<leader>fw", builtin.live_grep, { desc = "Telescope live grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
map("n", "<leader>fg", builtin.git_files, { desc = "Telescope git grep" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>") --- ?

map(
  "n",
  "<leader>s",
  ":%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>",
  { desc = "Select and replace all words" }
)

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlighted lines one down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlighted lines one up" })

map(
  { "v", "n", "i" },
  "<C-c>",
  "<Esc>",
  { noremap = true, silent = true, desc = "Cancel - does the same as Esc" }
)
map("n", "<C-a>", "ggVG", { desc = "Select all" })

map("n", "<leader>gl", function()
  vim.diagnostic.open_float { border = "rounded" }
end, { desc = "Line Diagnostics" })

map("n", "<C-h>", "<cmd>TmuxNavigateLeft<CR>", { silent = true })
map("n", "<C-j>", "<cmd>TmuxNavigateDown<CR>", { silent = true })
map("n", "<C-k>", "<cmd>TmuxNavigateUp<CR>", { silent = true })
map("n", "<C-l>", "<cmd>TmuxNavigateRight<CR>", { silent = true })
map("n", "<C-\\>", "<cmd>TmuxNavigatePrevious<CR>", { silent = true })
