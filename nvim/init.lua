-- This is autocmd group for all the autocmds
vim.api.nvim_create_augroup("CustomAutoCmds", { clear = true })

-- Basic configuration
require("options")
require("keyMappings")
require("autocmds")

require('packer').startup(function(use)
    use "wbthomason/packer.nvim"                                -- Plugin manager

    -- UI
    use "rose-pine/neovim"                                      -- Theme
    use "kyazdani42/nvim-web-devicons"                          -- File Icons
    use "kyazdani42/nvim-tree.lua"                              -- File explorer
    use "nvim-lualine/lualine.nvim"                             -- Status line
    use "PeterRincker/vim-searchlight"                          -- Under cursor highlighted text in different colour
    use "lukas-reineke/indent-blankline.nvim"                   -- Indent guide
    use "karb94/neoscroll.nvim"                                 -- Smooth scroll
    use "goolord/alpha-nvim"                                    -- Startup screen
    use "folke/noice.nvim"                                      -- UI for commandline, messages and popupmenu
    use "MunifTanjim/nui.nvim"                                  -- required for noice.nvim
    use "rcarriga/nvim-notify"                                  -- required for noice.nvim

    -- Autocompletion And IDE Features
    use {"neoclide/coc.nvim", branch = "release"  }             -- Conquer of Completion
    use "honza/vim-snippets"                                    -- Snippets

    -- Motions | Movements
    use "phaazon/hop.nvim"                                      -- Easy hop around
    use "ggandor/leap.nvim"                                     -- Easy movement around buffer
    use "christoomey/vim-tmux-navigator"                        -- Easy navigation between tmux panes and vim windows

    -- Text objects
    use "kylechui/nvim-surround"                                -- Easy text-object surrounding plugin
    use "echasnovski/mini.nvim"                                 -- Common plugins bundeled together (only using AI module

    -- Git
    use "tpope/vim-fugitive"                                    -- Git integration
    use "lewis6991/gitsigns.nvim"                               -- Git signs, hunk actions and text objects

    -- TreeSitter
    use {"nvim-treesitter/nvim-treesitter", run = ":TSUpdate" } -- Syntax tree plugin
    use "nvim-treesitter/nvim-treesitter-textobjects"           -- Text objects based on treesitter
    use "nvim-treesitter/nvim-treesitter-context"               -- Context pinned on top

    -- SQL client | database
    use "tpope/vim-dadbod"                                      -- Core plugin for sql
    use "kristijanhusak/vim-dadbod-ui"                          -- UI for vim-dadbod

    -- General
    use "numToStr/Comment.nvim"                                 -- Comment easily
    use "tpope/vim-repeat"                                      -- Repeat macros and plug mappings with dot
    use "puremourning/vimspector"                               -- Debugger
    -- Plug("junegunn/fzf", { ["do"] = vim.fn["fzf#install"] })        -- Installs FZF
    -- Plug("junegunn/fzf.vim")                                        -- Fuzzy finder
    use { "nvim-telescope/telescope.nvim",                      -- Fuzzy finder
        requires = "nvim-lua/plenary.nvim" }
    use "stevearc/aerial.nvim"                                  -- Code outline
    use "jiangmiao/auto-pairs"                                  -- Auto pairs
    use "windwp/nvim-ts-autotag"                                -- Auto tag for typescript, javascript
    use "folke/which-key.nvim"                                  -- Which key
    use "tpope/vim-obsession"                                   -- Session management plugin
    use "preservim/vimux"                                       -- Vim to tmux panes (e.g execute current file, run tests
    use "mrjones2014/smart-splits.nvim"                         -- Sane split resize with Alt-hjkl
    use "vimwiki/vimwiki"                                       -- personal wiki
end)


-- PLUGINS configuration
require('mini.ai').setup()                                      -- better text objects including quote and brackets
require('Comment').setup()                                      -- Comment easily
require("plug-config/theme")                                    -- theme
require("plug-config/nvimTree")                                 -- nvim-tree | file explorer
require("plug-config/lualine")                                  -- lualine.nvim | statusline
require("plug-config/treeSitter")                               -- tree-sitter
require("plug-config/gitConfig")                                -- git realted plugs config
require("plug-config/aerial")                                   -- aerial | code outline
require("plug-config/movements")                                -- movements config
-- require("plug-config/fzf")                                      -- fzf | fuzzy search finder
require("plug-config/telescope")                                -- telescope | fuzzy search finder
require("plug-config/vimspector")                               -- vimspector | debuggging
require("plug-config/nvim-surround")                            -- nvim-surround
require("plug-config/noice")                                    -- noice
require("plug-config/whichKey")                                 -- which-key
require("plug-config/sql-dadbod")                               -- sql-vim-dadbod
require("plug-config/alpha")                                    -- startup screen
require("plug-config/vimux")                                    -- vim to tmux panes
require("plug-config/smart-splits")                             -- smart split resize with Alt-hjkl
require("plug-config/coc")                                      -- coc.vim

-- vim-commentary
vim.api.nvim_create_autocmd("FileType", { group = "CustomAutoCmds", pattern = { "json" }, command = [[setlocal commentstring=//\ %s]] })

-- vim-repeat
vim.api.nvim_command([[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]])

-- neoscroll
require("neoscroll").setup()

-- vimwiki
vim.g.vimwiki_list = {{path = '$HOME/Dropbox/wiki'}}
vim.g.vimwiki_ext = '.md'
vim.g.vimwiki_global_ext = 0

--indent line sane setting
vim.g.indent_blankline_show_trailing_blankline_indent = false

-- highlights
require("highlights")
