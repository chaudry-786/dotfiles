-- This is autocmd group for all the autocmds
vim.api.nvim_create_augroup("CustomAutoCmds", { clear = true })

-- Basic configuration
require("options")
require("keyMappings")
require("autocmds")

require("packer").startup(function(use)
    use "wbthomason/packer.nvim"                                -- Plugin manager

	----------------------------------------
    -- UI
	----------------------------------------
    use { "rose-pine/neovim", config = function()
        require("plug-config/theme")
    end }                                                       -- Theme
    use "kyazdani42/nvim-web-devicons"                          -- File Icons
    use { "kyazdani42/nvim-tree.lua", config = function()
        require("plug-config/nvimTree")
    end }                                                       -- File explorer
    use { "nvim-lualine/lualine.nvim", config = function()
        require("plug-config/lualine")
    end }                                                       -- Status line
    use { "lukas-reineke/indent-blankline.nvim", config = function()
        vim.g.indent_blankline_show_trailing_blankline_indent = false
    end }                                                       -- Indent guide
    use { "karb94/neoscroll.nvim", config = function()
        require("neoscroll").setup()
    end }                                                       -- Smooth scroll
    use { "goolord/alpha-nvim", config = function()
        require("plug-config/alpha")
    end }                                                       -- Startup screen
    use { "folke/noice.nvim", config = function()
        require("plug-config/noice")
    end, requires = { "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify" } }                              -- UI for commandline, messages and popupmenu
    use { "danilamihailov/beacon.nvim", config = function()
        vim.g.beacon_ignore_filetypes = { "NvimTree", "aerial" }
    end }                                                       -- Flashes cursor on movements (e.g jump between windows)

	----------------------------------------
    -- Autocompletion And IDE Features
	----------------------------------------
    use { "neoclide/coc.nvim", branch = "release",
        config = function() require("plug-config/coc") end }    -- Conquer of Completion
    use "honza/vim-snippets"                                    -- Snippets
    use { "vim-test/vim-test", config = function()
        require("plug-config/vim-test")
    end }                                                       -- Test plugin
    use { "Vigemus/iron.nvim", config = function()
        require("plug-config/iron")
    end }                                                       -- REPL

	----------------------------------------
    -- Motions | Movements
	----------------------------------------
    use { "ggandor/leap.nvim", config = function()
        local keymap = vim.api.nvim_set_keymap
        require("leap").opts.safe_labels = {}
        keymap("", "<leader>j", "<Plug>(leap-forward-to)", { silent = true })
        keymap("", "<leader>k", "<Plug>(leap-backward-to)", { silent = true })
    end }                                                       -- Easy movement around buffer
    use "christoomey/vim-tmux-navigator"                        -- Easy navigation between tmux panes and vim windows

	----------------------------------------
    -- Text objects
	----------------------------------------
    use { "kylechui/nvim-surround", config = function()
        require("plug-config/nvim-surround")
    end }                                                       -- Easy text-object surrounding plugin
    use { "echasnovski/mini.nvim", config = function()
        require("mini.ai").setup()
    end }                                                       -- Common plugins bundeled together (only using AI module

	----------------------------------------
    -- Git
	----------------------------------------
    use "tpope/vim-fugitive"                                    -- Git integration
    use "lewis6991/gitsigns.nvim"                               -- Git signs, hunk actions and text objects

	----------------------------------------
    -- TreeSitter
	----------------------------------------
    use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate",
        requires = "nvim-treesitter/nvim-treesitter-textobjects",
        config = function()
            require("plug-config/treeSitter")
        end }                                                   -- Syntax tree plugin

	----------------------------------------
    -- SQL client | database
	----------------------------------------
    use { "tpope/vim-dadbod", config = function()
        require("plug-config/sql-dadbod")
    end, requires = "kristijanhusak/vim-dadbod-ui" }            -- Core plugin for sql

	----------------------------------------
    -- General
	----------------------------------------
    use { "numToStr/Comment.nvim", config = function()
        require("Comment").setup()
        vim.api.nvim_create_autocmd("FileType", { group = "CustomAutoCmds", pattern = { "json" }, command = [[setlocal commentstring=//\ %s]] })
    end }                                                       -- Comment easily
    use { "tpope/vim-repeat", config = function()
        vim.api.nvim_command([[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]])
    end }                                                       -- Repeat macros and plug mappings with dot
    use { "puremourning/vimspector", config = function()
        require("plug-config/vimspector")
    end }                                                       -- Debugger
    use { "nvim-telescope/telescope.nvim",                      -- Fuzzy finder
        requires = "nvim-lua/plenary.nvim", config = function()
            require("plug-config/telescope")
        end }
    use { "stevearc/aerial.nvim", config = function()
        require("plug-config/aerial")
    end }                                                       -- Code outline
    use "jiangmiao/auto-pairs"                                  -- Auto pairs
    use "windwp/nvim-ts-autotag"                                -- Auto tag for typescript, javascript
    use { "folke/which-key.nvim", config = function()
        require("plug-config/whichKey")
    end }                                                       -- Which key
    use "tpope/vim-obsession"                                   -- Session management plugin
    use { "preservim/vimux", config = function()
        require("plug-config/vimux")
    end }                                                       -- Vim to tmux panes (e.g execute current file, run tests
    use { "mrjones2014/smart-splits.nvim", config = function()
        require("plug-config/smart-splits")
    end }                                                       -- Sane split resize with Alt-hjkl
    use { "vimwiki/vimwiki", config = function()
        vim.g.vimwiki_list = { { path = "$HOME/Dropbox/wiki" } }
        vim.g.vimwiki_ext = ".md"
        vim.g.vimwiki_global_ext = 0
    end }                                                       -- personal wiki
end)


-- PLUGINS configuration
require("plug-config/gitConfig")                                -- git related plugs config


-- highlights
require("highlights")
