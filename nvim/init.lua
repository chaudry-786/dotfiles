-- This is autocmd group for all of the user defined custom auto commands
vim.api.nvim_create_augroup("CustomAutoCmds", { clear = true })

-- Basic configuration
require("options")
require("keyMappings")
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

require("lazy").setup({
    ----------------------------------------
    -- UI
    ----------------------------------------
    { "rose-pine/neovim", config = function()
        require("plug-config/theme")
    end },                                                  -- Theme
    "kyazdani42/nvim-web-devicons",                         -- File Icons
    { "kyazdani42/nvim-tree.lua", config = function()
        require("plug-config/nvimTree")
    end },                                                  -- File explorer
    { "nvim-lualine/lualine.nvim", config = function()
        require("plug-config/lualine")
    end },                                                  -- Status line
    { "lukas-reineke/indent-blankline.nvim", config = function()
        require("ibl").setup {
            scope = { enabled = false },
        }
    end },                                                  -- Indent guide
    { "karb94/neoscroll.nvim", config = function()
        require("neoscroll").setup()
    end },                                                  -- Smooth scroll
    { "goolord/alpha-nvim", config = function()
        require("plug-config/alpha")
    end },                                                  -- Startup screen
    { "danilamihailov/beacon.nvim", init = function()
        vim.g.beacon_ignore_filetypes = { "NvimTree", "aerial" }
        vim.g.beacon_focus_gained = 1
    end },                                                  -- Flashes cursor on movements (e.g jump between windows)

    ----------------------------------------
    -- Autocompletion And IDE Features
    ----------------------------------------
    { "neoclide/coc.nvim", branch = "release",
        config = function() require("plug-config/coc") end }, -- Conquer of Completion
    "honza/vim-snippets",                                   -- Snippets
    { "vim-test/vim-test", config = function()
        require("plug-config/vim-test")
    end },                                                  -- Test plugin
    { "Vigemus/iron.nvim", config = function()
        require("plug-config/iron")
    end },                                                  -- REPL
    { "puremourning/vimspector", config = function()
        require("plug-config/vimspector")
    end },                                                  -- Debugger

    ----------------------------------------
    -- Motions | Movements
    ----------------------------------------
    { "ggandor/leap.nvim", config = function()
        local keymap = vim.api.nvim_set_keymap
        require("leap").opts.safe_labels = {}
        keymap("", "<leader>j", "<Plug>(leap-forward-to)", { silent = true })
        keymap("", "<leader>k", "<Plug>(leap-backward-to)", { silent = true })
    end },                                                  -- Easy movement around buffer
    "christoomey/vim-tmux-navigator",                       -- Easy navigation between tmux panes and vim windows

    ----------------------------------------
    -- Text objects
    ----------------------------------------
    { "kylechui/nvim-surround", config = function()
        require("plug-config/nvim-surround")
    end },                                                  -- Easy text-object surrounding plugin
    { "echasnovski/mini.nvim", config = function()
        require("mini.ai").setup()
    end },                                                  -- Common plugins bundled together (only using AI module

    ----------------------------------------
    -- Git
    ----------------------------------------
    "tpope/vim-fugitive",                                   -- Git integration
    "lewis6991/gitsigns.nvim",                              -- Git signs, hunk actions and text objects

    ----------------------------------------
    -- TreeSitter
    ----------------------------------------
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
        dependencies = "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require("plug-config/treeSitter")
        end },                                              -- Syntax tree plugin

    ----------------------------------------
    -- General
    ----------------------------------------
    { "numToStr/Comment.nvim", config = function()
        require("Comment").setup()
        vim.api.nvim_create_autocmd("FileType",
            { group = "CustomAutoCmds", pattern = { "json" }, command = [[setlocal commentstring=//\ %s]] })
    end },                                                  -- Comment easily
    { "tpope/vim-repeat", config = function()
        vim.api.nvim_command([[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]])
    end },                                                  -- Repeat macros and plug mappings with dot
    { "nvim-telescope/telescope.nvim",                      -- Fuzzy finder
        dependencies = "nvim-lua/plenary.nvim", config = function()
        require("plug-config/telescope")
    end },
    { "stevearc/aerial.nvim", config = function()
        require("plug-config/aerial")
    end },                                                  -- Code outline
    "jiangmiao/auto-pairs",                                 -- Auto pairs
    "windwp/nvim-ts-autotag",                               -- Auto tag for typescript, javascript
    { "folke/which-key.nvim", config = function()
        require("plug-config/whichKey")
    end },                                                  -- Which key
    "tpope/vim-obsession",                                  -- Session management plugin
    { "preservim/vimux", config = function()
        require("plug-config/vimux")
    end },                                                  -- Vim to tmux panes (e.g execute current file, run tests
    { "mrjones2014/smart-splits.nvim", config = function()
        require("plug-config/smart-splits")
    end },                                                  -- Sane split resize with Alt-hjkl
    { "vimwiki/vimwiki", init = function()
        vim.g.vimwiki_list = { { path = "$HOME/Dropbox/wiki" } }
        vim.g.vimwiki_ext = ".md"
        vim.g.vimwiki_global_ext = 0
    end },                                                  -- personal wiki
    {
        "nvim-neorg/neorg",
        build = ":Neorg sync-parsers",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("plug-config/neorg")
        end,
    },                                                      -- Better notes
    {
        'cameron-wags/rainbow_csv.nvim',
        config = true,
    }                                                       -- CSV highlighted
})


-- PLUGINS configuration
require("plug-config/gitConfig") -- git related plugs config


-- highlights
require("highlights")

-- ensures that all highlight groups have been set
require("status_column")
