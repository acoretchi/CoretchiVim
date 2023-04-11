local options = {
    -- Dont make swapfiles or backups
    swapfile = false,
    backup = false,
    writebackup = false,

    -- Indentation/Tab Behavior
    autoindent = true,
    expandtab = true,                            -- Spaces not tabs
    shiftround = true,
    tabstop = 4,
    shiftwidth = 4,

    -- Line Numbering
    number = true,
    relativenumber = false,

    -- Movement/Editing
    backspace = {"indent", "eol", "start"},      -- Make backspace work as you'd expect
    virtualedit = "onemore",                     -- Allow cursor to move past end of line

    -- Search
    hlsearch = true,                             -- Search highlighting
    incsearch = true,                            -- Incremental searching

    -- Rendering
    encoding = "utf-8",
    scrolloff = 10,
    wrap = true,

    -- Folding
    foldmethod = "indent",
    foldlevel = 99,

    -- Colouring
    termguicolors = true,

    -- Use system clipboard
    clipboard = "unnamedplus",
}

-- Iterate over options defined above and set them accordingly
for k, v in pairs(options) do
    vim.opt[k] = v
end
