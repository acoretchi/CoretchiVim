-- Shorten function name for convenience
local keymap = vim.api.nvim_set_keymap

-- Stop recursive expanding of remaps and silence functions
local opts = {
    noremap = true,
    silent = true,
}

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
