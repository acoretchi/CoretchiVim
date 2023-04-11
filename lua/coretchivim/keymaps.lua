-- Shorten function name for convenience
local keymap = vim.api.nvim_set_keymap

local noremap = { noremap = true, silent = true }
local remap = { noremap = false, silent = true }
local expr = { noremap = true, silent = true, expr = true }


-- Leader Binds
vim.g.mapleader = " "
keymap("n", "<Space>", "<NOP>", noremap)         -- Unbind space in normal mode

keymap("n", "<leader>h", ":noh<CR>", noremap)                    -- Leader + h to clear highlights
keymap("n", "<leader>f", ":NvimTreeToggle<CR>", noremap)         -- Leader + f to toggle file tree



keymap("n", "<leader>.", "<Cmd>BufferNext<CR>", noremap)         -- Leader buffer movement
keymap("n", "<leader>,", "<Cmd>BufferPrevious<CR>", noremap)
keymap("n", "<leader>>", "<Cmd>BufferMoveNext<CR>", noremap)
keymap("n", "<leader><", "<Cmd>BufferMovePrevious<CR>", noremap)
keymap("n", "<leader>tt", "<Cmd>BufferPick<CR>", noremap)
keymap("n", "<leader>tq", "<Cmd>BufferClose<CR>", noremap)


-- Normal --
-- Make j and k move cursor according to displayed lines
keymap("n", "j", "gj", noremap)
keymap("n", "k", "gk", noremap)


-- Insert --
-- Use Ctrl to move around in insert mode
keymap("i", "<C-h>", "<C-o>h", noremap)
keymap("i", "<C-j>", "<C-o>j", noremap)
keymap("i", "<C-k>", "<C-o>k", noremap)
keymap("i", "<C-l>", "<C-o>l", noremap)


-- Viusal --
-- Stay in indent mode
keymap("v", "<", "<gv", noremap)
keymap("v", ">", ">gv", noremap)
