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

    -- Colorizer for Neovim (maintained fork; the original is abandoned and
    -- uses APIs deprecated in recent nvim versions)
    {
        "catgoose/nvim-colorizer.lua",
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
            -- v2 enables installed servers automatically via vim.lsp.enable(),
            -- replacing the removed setup_handlers().
            require("mason-lspconfig").setup {}
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
    -- The legacy "master" branch is archived and unsupported on nvim 0.12+,
    -- so we use the rewritten "main" branch and its new API.
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup {}
            -- Parsers must be installed explicitly on the main branch.
            require("nvim-treesitter").install {
                "bash", "c", "css", "dockerfile", "go", "html", "javascript",
                "json", "lua", "markdown", "markdown_inline", "python",
                "query", "rust", "toml", "tsx", "typescript", "vim",
                "vimdoc", "yaml",
            }
            -- Highlighting and indentation are enabled per-buffer now.
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_setup", { clear = true }),
                callback = function(ev)
                    if pcall(vim.treesitter.start, ev.buf) then
                        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end,
            })
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config = function()
            require("nvim-treesitter-textobjects").setup {
                select = {
                    lookahead = true,
                    selection_modes = {
                        ["@function.outer"] = "V",
                        ["@class.outer"] = "V",
                    },
                },
            }
            local textobject_keymaps = {
                ["aa"] = "@parameter.outer",
                ["ia"] = "@parameter.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
            }
            for lhs, capture in pairs(textobject_keymaps) do
                vim.keymap.set({ "x", "o" }, lhs, function()
                    require("nvim-treesitter-textobjects.select").select_textobject(capture, "textobjects")
                end)
            end
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
        init = function()
            -- v4 removed the `keymaps` setup option; disable the default
            -- normal-mode maps and bind our own to the <Plug> mappings.
            vim.g.nvim_surround_no_normal_mappings = true
        end,
        config = function()
            require("nvim-surround").setup({})
            vim.keymap.set("n", "sa", "<Plug>(nvim-surround-normal)", { desc = "Add surrounding pair (motion)" })
            vim.keymap.set("n", "ssa", "<Plug>(nvim-surround-normal-cur)", { desc = "Add surrounding pair (line)" })
            vim.keymap.set("n", "Sa", "<Plug>(nvim-surround-normal-line)", { desc = "Add surrounding pair (motion, new lines)" })
            vim.keymap.set("n", "SSa", "<Plug>(nvim-surround-normal-cur-line)", { desc = "Add surrounding pair (line, new lines)" })
            vim.keymap.set("n", "sd", "<Plug>(nvim-surround-delete)", { desc = "Delete surrounding pair" })
            vim.keymap.set("n", "sc", "<Plug>(nvim-surround-change)", { desc = "Change surrounding pair" })
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
        init = function()
            -- nvim-terminal.lua (used below for the ANSI header) is abandoned
            -- and calls vim.tbl_flatten, deprecated and slated for removal in
            -- nvim 0.13. Replace it with the non-deprecated equivalent so it
            -- keeps working and stops warning on startup.
            vim.tbl_flatten = function(t)
                return vim.iter(t):flatten(math.huge):totable()
            end
        end,
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
        dependencies = {'nvim-tree/nvim-web-devicons'},
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

    -- Git diff viewer
    {
        "sindrets/diffview.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        opts = {
            hooks = {
                -- Keep buffers opened while browsing diffs out of the buffer
                -- list, so they don't pile up in the tabline.
                diff_buf_read = function(bufnr)
                    vim.bo[bufnr].buflisted = false
                end,
            },
            keymaps = {
                view = {
                    { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                },
                file_panel = {
                    { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                },
                file_history_panel = {
                    { "n", "q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
                },
            },
        },
        keys = {
            {
                "<leader>gd",
                function()
                    if require("diffview.lib").get_current_view() then
                        vim.cmd("DiffviewClose")
                    else
                        vim.cmd("DiffviewOpen")
                    end
                end,
                desc = "Toggle Diffview",
            },
        },
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        branch = "0.1.x",
        dependencies = "nvim-lua/plenary.nvim",
        keys = {
            { "<leader>ft", "<Cmd>Telescope<CR>", desc = "Open Telescope" },
        },
    },
})
