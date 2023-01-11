local Plug = vim.fn["plug#"]

vim.call("plug#begin", "~/.vim/plugged")
-- UI
Plug("rose-pine/neovim")                                        -- Theme
Plug("kyazdani42/nvim-web-devicons")                            -- File Icons
Plug("kyazdani42/nvim-tree.lua")                                -- File explorer
Plug("nvim-lualine/lualine.nvim")                               -- Status line
Plug("PeterRincker/vim-searchlight")                            -- Under cursor highlighted text in different colour
Plug("lukas-reineke/indent-blankline.nvim")                     -- Indent guide
Plug("karb94/neoscroll.nvim")                                   -- Smooth scroll
Plug("goolord/alpha-nvim")                                      -- Startup screen
Plug("folke/noice.nvim")                                        -- UI for commandline, messages and popupmenu
Plug("MunifTanjim/nui.nvim")                                    -- required for noice.nvim
Plug("rcarriga/nvim-notify")                                    -- required for noice.nvim

-- Autocompletion And IDE Features
Plug("neoclide/coc.nvim", { branch = "release" })               -- Conquer of Completion
Plug("honza/vim-snippets")                                      -- Snippets

-- Motions | Movements
Plug("phaazon/hop.nvim")                                        -- Easy hop around
Plug("ggandor/leap.nvim")                                       -- Easy movement around buffer
Plug("christoomey/vim-tmux-navigator")                          -- Easy navigation between tmux panes and vim windows

-- Text objects
Plug("kylechui/nvim-surround")                                  -- Easy text-object surrounding plugin
Plug("echasnovski/mini.nvim")                                   -- Common plugins bundeled together (only using AI module)

-- Git
Plug("tpope/vim-fugitive")                                      -- Git integration
Plug("lewis6991/gitsigns.nvim")                                 -- Git signs, hunk actions and text objects

-- TreeSitter
Plug("nvim-treesitter/nvim-treesitter", { ["do"] = ":TSUpdate" }) -- Syntax tree plugin
Plug("nvim-treesitter/nvim-treesitter-textobjects")             -- Text objects based on treesitter
Plug("nvim-treesitter/nvim-treesitter-context")                 -- Context pinned on top

-- SQL client | database
Plug("tpope/vim-dadbod")                                        -- Core plugin for sql
Plug("kristijanhusak/vim-dadbod-ui")                            -- UI for vim-dadbod

-- General
Plug("numToStr/Comment.nvim")                                   -- Comment easily
Plug("tpope/vim-repeat")                                        -- Repeat macros and plug mappings with dot
Plug("puremourning/vimspector")                                 -- Debugger
-- Plug("junegunn/fzf", { ["do"] = vim.fn["fzf#install"] })        -- Installs FZF
-- Plug("junegunn/fzf.vim")                                        -- Fuzzy finder
Plug("nvim-lua/plenary.nvim")                                   -- required by telescope
Plug("nvim-telescope/telescope.nvim")                           -- Fuzzy finder
Plug("stevearc/aerial.nvim")                                    -- Code outline
Plug("jiangmiao/auto-pairs")                                    -- Auto pairs
Plug("windwp/nvim-ts-autotag")                                  -- Auto tag for typescript, javascript
Plug("folke/which-key.nvim")                                    -- Which key
Plug("tpope/vim-obsession")                                     -- Session management plugin
Plug("preservim/vimux")                                         -- Vim to tmux panes (e.g execute current file, run tests)
Plug("mrjones2014/smart-splits.nvim")                           -- Sane split resize with Alt-hjkl
Plug("vimwiki/vimwiki")                                         -- personal wiki
vim.call("plug#end")

-- This is autocmd group for all the autocmds
vim.api.nvim_create_augroup("CustomAutoCmds", { clear = true })

-- Basic configuration
require("options")
require("keyMappings")
require("autocmds")


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
