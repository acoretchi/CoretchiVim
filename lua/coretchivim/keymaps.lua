-- Shorten function name for convenience
local keymap = vim.api.nvim_set_keymap

local opts = { noremap = true, silent = true }
local expr = { noremap = true, silent = true, expr = true }


-- Leader Binds
vim.g.mapleader = " "
keymap("n", "<leader>f", ":NvimTreeToggle<CR>", opts) -- Leader + f to toggle file tree
keymap("n", "<leader>h", ":noh<CR>", opts) -- Leader + h to clear highlights
keymap("n", "<leader>.", "<Cmd>BufferNext<CR>", opts)
keymap("n", "<leader>,", "<Cmd>BufferPrevious<CR>", opts)
keymap("n", "<leader>>", "<Cmd>BufferMoveNext<CR>", opts)
keymap("n", "<leader><", "<Cmd>BufferMovePrevious<CR>", opts)
keymap("n", "<leader>tt", "<Cmd>BufferPick<CR>", opts)
keymap("n", "<leader>tq", "<Cmd>BufferClose<CR>", opts)

-- Normal --
-- Make j and k move cursor according to displayed lines
keymap("n", "j", "gj", opts)
keymap("n", "k", "gk", opts)

-- Insert --
-- Use Ctrl to move around in insert mode
keymap("i", "<C-h>", "<C-o>h", opts)
keymap("i", "<C-j>", "<C-o>j", opts)
keymap("i", "<C-k>", "<C-o>k", opts)
keymap("i", "<C-l>", "<C-o>l", opts)

-- Viusal --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
