-- This is autocmd group for all of the user defined custom auto commands
vim.api.nvim_create_augroup("CustomAutoCmds", { clear = true })

-- Basic configuration
require("options")
require("keyMappings")
require("autocmds")
require("fold")

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
    { "kyazdani42/nvim-web-devicons",
        cond = not vim.g.vscode },                          -- File Icons
    { "kyazdani42/nvim-tree.lua", config = function()
        require("plug-config/nvimTree")
    end, cond = not vim.g.vscode },                         -- File explorer
    { "nvim-lualine/lualine.nvim", config = function()
        require("plug-config/lualine")
    end, cond = not vim.g.vscode },                         -- Status line
    { "lukas-reineke/indent-blankline.nvim", config = function()
        require("ibl").setup {
            scope = { enabled = false },
        }
    end, cond = not vim.g.vscode },                         -- Indent guide
    { "karb94/neoscroll.nvim", config = function()
        require("neoscroll").setup()
    end, cond = not vim.g.vscode},                          -- Smooth scroll
    { "goolord/alpha-nvim", config = function()
        require("plug-config/alpha")
    end, cond = not vim.g.vscode },                         -- Startup screen
    { "danilamihailov/beacon.nvim", init = function()
        vim.g.beacon_ignore_filetypes = { "NvimTree", "aerial" }
        vim.g.beacon_focus_gained = 1
    end, cond = not vim.g.vscode },                          -- Flashes cursor on movements (e.g jump between windows)

    ----------------------------------------
    -- Autocompletion And IDE Features
    ----------------------------------------
    { "neoclide/coc.nvim", branch = "release",
        config = function() require("plug-config/coc") end,
        cond = not vim.g.vscode },                          -- Conquer of Completion
    "honza/vim-snippets",                                   -- Snippets
    { "vim-test/vim-test", config = function()
        require("plug-config/vim-test")
    end },                                                  -- Test plugin
    { "luk400/vim-jukit", init = function()
        vim.g.jukit_terminal = "nvimterm"
        vim.g.jukit_in_style = 4
        vim.g.jukit_mappings_ext_enabled = { "py", "ipynb" }
        vim.g.jukit_mappings = 0
    end, config = function()
        require("plug-config/jukit")
    end },                                                  -- notebook REPL
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap",
        -- neotest
        "nvim-neotest/neotest",
        "nvim-lua/plenary.nvim",
        "antoinemadec/FixCursorHold.nvim",
        "nvim-neotest/neotest-python"
    },
        config = function()
            require("plug-config/debugger")
        end
    },                                                      -- Debugger
    { "williamboman/mason.nvim", config = function()
        require("mason").setup()
    end,
        opts = { ensure_installed = { "debugpy"} }
    },

    ----------------------------------------
    -- Motions | Movements
    ----------------------------------------
    { "ggandor/leap.nvim", config = function()
        local keymap = vim.keymap.set
        require("leap").opts.safe_labels = {}
        keymap("", "<leader>j", "<Plug>(leap-forward-to)", { silent = true })
        keymap("", "<leader>k", "<Plug>(leap-backward-to)", { silent = true })
    end },                                                  -- Easy movement around buffer
    { "alexghergh/nvim-tmux-navigation", config = function()
        local nvim_tmux_nav = require('nvim-tmux-navigation')
        local keymap = vim.keymap.set
        nvim_tmux_nav.setup {
            disable_when_zoomed = true
        }
        keymap({ "n", "t" }, "<C-h>", nvim_tmux_nav.NvimTmuxNavigateLeft)
        keymap({ "n", "t" }, "<C-j>", nvim_tmux_nav.NvimTmuxNavigateDown)
        keymap({ "n", "t" }, "<C-k>", nvim_tmux_nav.NvimTmuxNavigateUp)
        keymap({ "n", "t" }, "<C-l>", nvim_tmux_nav.NvimTmuxNavigateRight)
    end },                                                  -- Easy navigation between tmux panes and vim windows

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

if not vim.g.vscode then
    -- ensures that all highlight groups have been set
    require("status_column")
else
    require("vscode_settings")
end

