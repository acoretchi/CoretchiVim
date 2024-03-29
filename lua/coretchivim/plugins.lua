--------------------------------------------------------------------------------
-- Bootstrap our package manager.
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)


--------------------------------------------------------------------------------
-- Define our plugins.
--------------------------------------------------------------------------------

require("lazy").setup({

    "nvim-lua/popup.nvim",         -- Popup API from vim in Neovim
    "nvim-lua/plenary.nvim",       -- Lua functions used by many plugins
    "jghauser/mkdir.nvim",          -- Create directories on save

    -- Colorizer for Neovim
    {
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    },


    -- Monokai
    {
        "tanvirtin/monokai.nvim",
        priority=1000, -- Ensure our colours are loaded first.
        lazy = false,
        config = function()
            local monokai = require('monokai')
            local palette = monokai.soda
            palette.base2 = "#121212"
            monokai.setup {
                palette = palette,
            }
        end,
    },


    -- Status Bar
    {
        "hoob3rt/lualine.nvim",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            require("lualine").setup {
                options = {
                    section_separators = "",
                    component_separators = "",
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { "filename" },
                    lualine_x = { "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
                inactive_sections = {
                    lualine_a = {  },
                    lualine_b = {  },
                    lualine_c = { "filename" },
                    lualine_x = { "location" },
                    lualine_y = {  },
                    lualine_z = {  },
                },
            }
        end,
    },


    -- Tab Line
    {
        'romgrk/barbar.nvim',
        lazy = false,
        dependencies = 'nvim-tree/nvim-web-devicons',
        init = function() vim.g.barbar_auto_setup = false end,
        opts = {
            auto_hide = true,
        },
        version = '^1.0.0', -- optional: only update when a new 1.x version is released
    },


    -- LSP, DAP, Linter, Formatter Manager.
    {
        "williamboman/mason.nvim",
        lazy = false,
        priority = 500,
        build = ":MasonUpdate",
        config = function()
            require("mason").setup {}
        end,
    },


    -- LSP
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
        },
        config = function()
            require("mason-lspconfig").setup {}
            require("mason-lspconfig").setup_handlers {
                -- The first entry (without a key) will be the default handler
                -- and will be called for each installed server that doesn't have
                -- a dedicated handler.
                function (server_name) -- default handler (optional)
                    require("lspconfig")[server_name].setup {}
                end,
            }
            local lspconfig = require("lspconfig")
            vim.o.updatetime = 250
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = vim.api.nvim_create_augroup("float_diagnostic", { clear = true }),
                callback = function ()
                    vim.diagnostic.open_float(nil, {focus=false})
                end
            })
        end,
    },


    -- Treesitter
    {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup {
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["aa"] = "@parameter.outer",
                            ["ia"] = "@parameter.inner",
                            ["af"] = "@function.outer",
                            ["if"] = "@function.inner",
                            ["ac"] = "@class.outer",
                            ["ic"] = "@class.inner",
                        },
                        selection_modes = {
                            ["@function.outer"] = "V",
                            ["@class.outer"] = "V",
                        },
                    },
                },
            }
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
    },

    {
        "nvim-treesitter/nvim-treesitter-refactor",
        after = "nvim-treesitter",
        requires = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter.configs").setup {
                refactor = {
                    highlight_definitions = { enable = true },
                    highlight_current_scope = { enable = false },
                    smart_rename = {
                        enable = true,
                        keymaps = {
                            smart_rename = "grr",
                        },
                    },
                    navigation = {
                        enable = true,
                        keymaps = {
                            goto_definition = "gd",
                            goto_next_usage = "gu",
                            goto_previous_usage = "gU",
                        },
                    },
                },
            }
        end,
    },


    -- Copilot.
    {
        "github/copilot.vim",
        config = function()
            local options = { noremap = true, silent = true, expr = true, replace_keycodes=false }
            vim.keymap.set("i", "<C-c>", "copilot#Accept('<CR>')", options)
            vim.g.copilot_no_tab_map = true
        end,
    },


    -- Completions (call after Copilot to override Tab behavior).
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-calc",
            "hrsh7th/cmp-emoji",
            "hrsh7th/cmp-vsnip",
            "hrsh7th/vim-vsnip",
        },
        config = function()
            local cmp = require("cmp")
            cmp.setup {
                snippet = {
                    expand = function(args)
                        vim.fn["vsnip#anonymous"](args.body)
                    end,
                },
                window = {
                    completion = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },
                mapping = {
                    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<C-e>"] = cmp.mapping.close(),
                    ["<CR>"] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ["<Tab>"] = cmp.mapping.select_next_item(),
                    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
                },
                sources = {
                    { name = "nvim_lsp" },
                    { name = "buffer" },
                    { name = "path" },
                    { name = "nvim_lua" },
                    { name = "calc" },
                    { name = "emoji" },
                    { name = "vsnip" },
                },
            }
        end,
    },


    -- Auto pairs.
    {
        "windwp/nvim-autopairs",
        config = function()
            require("nvim-autopairs").setup {}
        end,
    },


    -- Surround actions
    {
        "kylechui/nvim-surround",
        version = "*", -- Use for stability; omit to use `main` branch for the latest features
        event = "VeryLazy",
        config = function()
            require("nvim-surround").setup({
                keymaps = {
                    normal = "sa",
                    normal_cur = "ssa",
                    normal_line = "Sa",
                    normal_cur_line = "SSa",
                    delete = "sd",
                    change = "sc",
                }
            })
        end
    },

    -- File Tree
    {
        "kyazdani42/nvim-tree.lua",
        dependencies = 'nvim-tree/nvim-web-devicons',
        config = function()
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1
            require("nvim-tree").setup {
                hijack_cursor = true,
                hijack_unnamed_buffer_when_opening = true,
                view = {
                    width = 40,
                },
                renderer = {
                    group_empty = true,
                },
                update_focused_file = {
                    enable = true,
                    update_root = true,
                    update_cwd = true,
                },
            }
        end,
    },

    -- Start Screen
    {
        "glepnir/dashboard-nvim",
        event = "VimEnter",
        config = function()
            -- TODO: Auto center the header.
            -- local col_str = vim.cmd("set co")
            local header = require("coretchivim.hal")
            require("dashboard").setup {
                theme = "doom",
                config = {
                    header = header,
                    center = {
                        {
                            desc=""
                        }
                    },
                    disable_move = true,
                }
            }
            vim.api.nvim_create_autocmd("UIEnter", {
                command="lua vim.cmd('AnsiEsc') require('terminal').attach_to_buffer(0) "
            })
        end,
        dependencies = {
            {"nvim-tree/nvim-web-devicons"},
            {"norcalli/nvim-terminal.lua"},  -- Colour ANSI Escape codes
            {"powerman/vim-plugin-AnsiEsc"}, -- Remove the ANSI Escape codes from the screen.
        }
    },

    -- More icons
    {
        'yamatsum/nvim-nonicons',
        requires = {'kyazdani42/nvim-web-devicons'},
        priority = 500,
    },

    -- Scrollbar
    {
        "dstein64/nvim-scrollview",
        config = function()
            vim.g.scrollview_excluded_filetypes = { "dashboard", "NvimTree", "terminal" }
        end,
    },


    -- Auto tags
    {
        "windwp/nvim-ts-autotag",
        config = function()
            require("nvim-ts-autotag").setup()
        end,
    },

    -- Git Signs
    {
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup {}
        end,
    },
})
