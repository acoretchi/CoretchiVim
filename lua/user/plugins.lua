local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = fn.system {
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    }
    print "Installing packer close and reopen Neovim..."
    vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
augroup packer_user_config
autocmd!
autocmd BufWritePost plugins.lua source <afile> | PackerSync
augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
    return
end

-- Have packer use a popup window
packer.init {
    display = {
        open_fn = function()
            return require("packer.util").float { border = "rounded" }
        end,
    },
}

-- Install plugins here
return packer.startup(function(use)
    use "wbthomason/packer.nvim"      -- Have packer manage itself
    use "nvim-lua/popup.nvim"         -- Popup API from vim in Neovim
    use "nvim-lua/plenary.nvim"       -- Lua functions used by many plugins
    use "tanvirtin/monokai.nvim"      -- Monokai Colourscheme
    use "ur4ltz/surround.nvim"        -- Edit surrounding parentheses, quotes, etc.
    use "windwp/nvim-autopairs"       -- Autopairs
    use "norcalli/nvim-colorizer.lua" -- Colours background of colour codes
    use "jghauser/mkdir.nvim"         -- Automatically mkdir on save if folder doesnt exist

    -- LSP and completion
    use {
        "ms-jpq/coq_nvim",
        branch = "coq",
        run = ":COQdeps",
        requires = {
            { "ms-jpq/coq.artifacts", branch = "artifacts" },
            { "ms-jpq/coq.thirdparty", branch = "3p", module = "coq_3p" },
        },
        disable = false,
    }
    use {
        "williamboman/nvim-lsp-installer",
        requires = {
            "neovim/nvim-lspconfig",
        },
    }

    -- Treesitter Highlighting
    use {
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- Automatically set up your configuration after cloning packer.nvim
    -- Put this at the end after all plugins
    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
