local o = vim.o
local g = vim.g

--------------------------------- options --------------------------------------

o.clipboard = "unnamedplus"
g.mapleader = " "
g.maplocalleader = " "

-- Indenting
o.expandtab = true
o.smartindent = true
o.tabstop = 2
o.shiftwidth = 2
o.softtabstop = 2

o.swapfile = false
o.list = true -- show trailing characters
o.signcolumn = "yes"

o.number = true
o.relativenumber = true
o.wrap = false

o.colorcolumn = "80"
o.relativenumber = true
o.termguicolors = true

o.winborder = "rounded"
o.undofile = true
o.ignorecase = true
o.smartcase = true

o.scrolloff = 8

--------------------------------- plugins --------------------------------------

local ls = {
  "lua_ls",
  "clangd",
}

vim.pack.add {
  { src = "https://github.com/christoomey/vim-tmux-navigator" },
  { src = "https://github.com/numToStr/Comment.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/sharkdp/fd" },
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
  },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/nvim-telescope/telescope.nvim", tag = "0.1.8" },
  {
    src = "https://github.com/catppuccin/nvim",
    priority = 1000,
  },
  {
    src = "https://github.com/ThePrimeagen/harpoon",
    version = "harpoon2",
  },
  { src = "https://github.com/hrsh7th/nvim-cmp" },
  { src = "https://github.com/hrsh7th/cmp-nvim-lsp" },
  { src = "https://github.com/stevearc/conform.nvim" },
}

vim.cmd.colorscheme "catppuccin"
vim.lsp.enable(ls)

require("nvim-treesitter.config").setup {
  ensure_installed = {
    "c",
    "lua",
    "vim",
    "vimdoc",
    "query",
    "markdown",
    "markdown_inline",
  },
  auto_install = true,
  highlight = {
    enable = true,
    use_languagetree = true,
    additional_vim_regex_highlighting = false,
  },
  indent = {
    enable = true,
  },
}

require("telescope").setup {
  defaults = {
    prompt_prefix = "   ",
    selection_caret = " ",
    entry_prefix = " ",
    sorting_strategy = "ascending",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
      },
      width = 0.87,
      height = 0.80,
    },
    mappings = {
      n = { ["q"] = require("telescope.actions").close },
    },
  },

  extensions_list = { "themes", "terms" },
  extensions = {},
}

--------------------------------- Conform -------------------------------------

require("conform").setup {
  formatters_by_ft = {
    lua = { "stylua" },
    nix = { "nixfmt" },

    -- Low-Level
    cpp = { "clang_format" },
    c = { "clang_format" },
    asm = { "asmfmt" },
    rust = { "rustfmt" },

    -- Front - End
    javascript = { "biome", "rustywind" },
    typescript = { "biome", "rustywind" },
    typescriptreact = { "biome", "rustywind" },
    javascriptreact = { "biome", "rustywind" },
    html = { "rustywind" },
    css = { "rustywind" },

    python = { "black" },
    markdown = { "markdownlint" },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  format = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
}

--------------------------------- Nvim CMP -------------------------------------

local cmp = require "cmp"
cmp.setup {
  completion = {
    completeopt = "menu,menuone,noselect", -- Added noselect for better control
  },
  snippet = {
    expand = function(args)
      vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },
  },
  sources = {
    { name = "nvim_lsp", priority = 1000 },
    { name = "buffer", priority = 500 },
    { name = "path", priority = 250 },
    { name = "nvim_lua", priority = 750 },
  },
  formatting = {
    format = function(entry, vim_item)
      -- Kind icons could be added here if desired
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        buffer = "[Buffer]",
        path = "[Path]",
        nvim_lua = "[Lua]",
      })[entry.source.name]
      return vim_item
    end,
  },
}

local lspconfig_defaults = require("lspconfig").util.default_config
lspconfig_defaults.capabilities = vim.tbl_deep_extend(
  "force",
  lspconfig_defaults.capabilities,
  require("cmp_nvim_lsp").default_capabilities()
)

-- for name, opts in pairs(ls) do
--   require("lspconfig")[name].setup(opts)
-- end

--------------------------------- Autocmd -------------------------------------

local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", { -- enable treesitter highlighting and indents
  callback = function(args)
    local filetype = args.match
    local lang = vim.treesitter.language.get_lang(filetype)
    if vim.treesitter.language.add(lang) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      vim.treesitter.start()
    end
  end,
})

local set = vim.keymap.set

autocmd("LspAttach", {
  desc = "LSP actions",
  callback = function(event)
    local opts = { buffer = event.buf }

    set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>", opts)
    set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>", opts)
    set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>", opts)
    set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<cr>", opts)
    set("n", "go", "<cmd>lua vim.lsp.buf.type_definition()<cr>", opts)
    set("n", "gr", "<cmd>lua vim.lsp.buf.references()<cr>", opts)
    set("n", "gs", "<cmd>lua vim.lsp.buf.signature_help()<cr>", opts)
    set("n", "ge", "<cmd>lua vim.lsp.buf.rename()<cr>", opts)
    set("n", "ga", "<cmd>lua vim.lsp.buf.code_action()<cr>", opts)
  end,
})

--------------------------------- Harpoon --------------------------------------

local harpoon = require "harpoon"
harpoon:setup()

set("n", "<leader>a", function()
  harpoon:list():add()
end)
set("n", "<A-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

set("n", "<A-h>", function()
  harpoon:list():select(1)
end)
set("n", "<A-j>", function()
  harpoon:list():select(2)
end)
set("n", "<A-k>", function()
  harpoon:list():select(3)
end)
set("n", "<A-l>", function()
  harpoon:list():select(4)
end)

-- Toggle previous & next buffers stored within Harpoon list
set("n", "<A-p>", function()
  harpoon:list():prev()
end, { desc = "Harpoon: Previous file" })
set("n", "<A-n>", function()
  harpoon:list():next()
end, { desc = "Harpoon: Next file" })

--------------------------------- Custom Cmds ----------------------------------

local usrcmd = vim.api.nvim_create_user_command

usrcmd("PackUpdate", function()
  vim.pack.update()
end, {
  desc = "Update all Neovim packages (vim.pack)",
})

--------------------------------- mappings -------------------------------------

local builtin = require "telescope.builtin"
local map = vim.keymap.set

map("n", "<leader>fm", vim.lsp.buf.format)

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

map("n", "<C-x>", ":noh<CR>", { desc = "Clear search highlight" })
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
