-- This is autocmd group for all of the user defined custom auto commands
vim.api.nvim_create_augroup("CustomAutoCmds", { clear = true })

-- Basic configuration
require("options")
require("keyMappings")
local keymap = map
require("autocmds")

-- Plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local vscode = vim.g.vscode
require("lazy").setup({
    ----------------------------------------
    -- UI
    ----------------------------------------
    -- Theme
    {
        "rose-pine/neovim",
        config = function()
            require("plug-config/theme")
        end,
        cond = not vscode
    },

    -- File Icons
    {
        "kyazdani42/nvim-web-devicons",
        cond = not vscode
    },

    -- File explorer
    {
        "kyazdani42/nvim-tree.lua",
        config = function()
            require("plug-config/nvimTree")
        end,
        cond = not vscode
    },

    -- Status line
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("plug-config/lualine")
        end,
        cond = not vscode
    },

    -- Indent guide
    {
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("ibl").setup {
                scope = { enabled = false },
            }
        end,
        cond = not vscode
    },

    -- Smooth scroll
    {
        "karb94/neoscroll.nvim",
        config = function()
            require("neoscroll").setup()
        end,
        cond = not vscode
    },

    -- Flashes cursor on movements (e.g jump between windows)
    {
        "danilamihailov/beacon.nvim",
        init = function()
            vim.g.beacon_ignore_filetypes = { "NvimTree", "aerial" }
            vim.g.beacon_focus_gained = 1
        end,
        cond = not vscode
    },


    ----------------------------------------
    -- Autocompletion And IDE Features
    ----------------------------------------
    -- Conquer of Completion
    {
        "neoclide/coc.nvim",
        branch = "release",
        config = function() require("plug-config/coc") end,
        cond = not vscode
    },

    -- Snippets
    {
        "honza/vim-snippets",
        cond = not vscode
    },

    -- Test plugin
    {
        "vim-test/vim-test",
        config = function()
            require("plug-config/vim-test")
        end,
    },

    -- Debugger
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require("plug-config/debugger")
        end,
        cond = not vscode
    },

    {
        "williamboman/mason.nvim",
        config = function()
            require("mason").setup()
        end,
        opts = { ensure_installed = { "debugpy" } },
        cond = not vscode
    },

    ----------------------------------------
    -- Motions | Movements
    ----------------------------------------
    -- Easy movement around buffer
    {
        "folke/flash.nvim",
        config = function()
            require("plug-config/flash")
        end,
    },

    -- Easy navigation between tmux panes and vim windows
    {
        "alexghergh/nvim-tmux-navigation",
        config = function()
            local nvim_tmux_nav = require('nvim-tmux-navigation')
            nvim_tmux_nav.setup {
                disable_when_zoomed = true
            }
            keymap({ "n", "t" }, "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft, "Tmux/Vim navigation left.")
            keymap({ "n", "t" }, "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown, "Tmux/Vim navigation down.")
            keymap({ "n", "t" }, "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp, "Tmux/Vim navigation up.")
            keymap({ "n", "t" }, "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight, "Tmux/Vim navigation right.")
        end,
        cond = not vscode
    },


    ----------------------------------------
    -- Text objects
    ----------------------------------------
    -- Easy text-object surrounding plugin
    {
        "kylechui/nvim-surround",
        config = function()
            require("plug-config/nvim-surround")
        end
    },

    -- Common plugins bundled together (only using AI module
    {
        "echasnovski/mini.nvim",
        config = function()
            require("mini.ai").setup()
        end
    },


    ----------------------------------------
    -- Git
    ----------------------------------------
    -- Git integration
    {
        "tpope/vim-fugitive",
        cond = not vscode
    },
    -- Git signs, hunk actions and text objects
    {
        "lewis6991/gitsigns.nvim",
        cond = not vscode
    },


    ----------------------------------------
    -- TreeSitter
    ----------------------------------------
    -- Syntax tree plugin
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require("plug-config/treeSitter")
        end
    },


    ----------------------------------------
    -- General
    ----------------------------------------
    -- Comment easily
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
            vim.api.nvim_create_autocmd("FileType",
                { group = "CustomAutoCmds", pattern = { "json" }, command = [[setlocal commentstring=//\ %s]] })
        end
    },

    -- Repeat macros and plug mappings with dot
    {
        "tpope/vim-repeat",
        config = function()
            vim.api.nvim_command([[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]])
        end
    },

    -- Fuzzy finder
    {
        "nvim-telescope/telescope.nvim",
        dependencies = "nvim-lua/plenary.nvim",
        config = function()
            require("plug-config/telescope")
        end,
        cond = not vscode
    },

    -- Code outline
    {
        "stevearc/aerial.nvim",
        config = function()
            require("plug-config/aerial")
        end,
        cond = not vscode
    },

    -- Auto pairs
    {
        "jiangmiao/auto-pairs",
        cond = not vscode
    },

    -- Which key
    {
        "folke/which-key.nvim",
        config = function()
            require("plug-config/whichKey")
        end,
        cond = not vscode
    },

    -- Vim to tmux panes (e.g execute current file, run tests
    {
        "preservim/vimux",
        config = function()
            require("plug-config/vimux")
        end,
        cond = not vscode
    },

    -- Sane split resize with Alt-hjkl
    {
        "mrjones2014/smart-splits.nvim",
        config = function()
            require("plug-config/smart-splits")
        end,
        cond = not vscode
    },

    -- CSV highlighted
    {
        'cameron-wags/rainbow_csv.nvim',
        config = true,
        cond = not vscode
    }
})


if not vscode then
    require("fold")
    -- ensures that all highlight groups have been set
    require("status_column")
    require("plug-config/gitConfig") -- git related plugs config
else
    require("vscode_settings")
end
