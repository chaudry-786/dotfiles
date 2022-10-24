local Plug = vim.fn["plug#"]

vim.call("plug#begin", "~/.vim/plugged")
-- UI
Plug("luisiacc/gruvbox-baby")                                   -- Theme
Plug("kyazdani42/nvim-web-devicons")                            -- File Icons
Plug("kyazdani42/nvim-tree.lua")                                -- File explorer
Plug("nvim-lualine/lualine.nvim")                               -- Status line
Plug("akinsho/bufferline.nvim", { tag = 'v2.*' })               -- Bufferline
Plug("PeterRincker/vim-searchlight")                            -- Under cursor highlighted text in different colour
Plug("lukas-reineke/indent-blankline.nvim")                     -- Indent guide
Plug("karb94/neoscroll.nvim")                                   -- Smooth scroll
Plug("mhinz/vim-startify")                                      -- Startup screen
Plug("folke/noice.nvim")                                        -- UI for commandline, messages and popupmenu
Plug("MunifTanjim/nui.nvim")                                    -- required for noice.nvim
Plug("rcarriga/nvim-notify")                                    -- required for noice.nvim

-- Autocompletion And IDE Features
Plug("neoclide/coc.nvim", { branch = 'release' })               -- Conquer of Completion
Plug("honza/vim-snippets")                                      -- Snippets

-- Motions | Movements
Plug("phaazon/hop.nvim")                                        -- Easy hop around
Plug("unblevable/quick-scope")                                  -- Highlights chars in current line to move easily
Plug("christoomey/vim-tmux-navigator")                          -- Easy navigation between tmux panes and vim windows

-- Text objects
Plug("kylechui/nvim-surround")                                  -- Easy text-object surrounding plugin

-- Git
Plug("tpope/vim-fugitive")                                      -- Git integration
Plug("airblade/vim-gitgutter")                                  -- Show git changes on left

-- TreeSitter
Plug("nvim-treesitter/nvim-treesitter", { ['do'] = ':TSUpdate' }) -- Syntax tree plugin
Plug("nvim-treesitter/nvim-treesitter-textobjects")             -- Text objects based on treesitter

-- General
Plug("tpope/vim-commentary")                                    -- Comment easily
Plug("tpope/vim-repeat")                                        -- Repeat macros and plug mappings with dot
Plug("puremourning/vimspector")                                 -- Debugger
Plug("junegunn/fzf", { ['do'] = vim.fn['fzf#install'] })        -- Installs FZF
Plug("junegunn/fzf.vim")                                        -- Fuzzy finder
Plug("stevearc/aerial.nvim")                                    -- Code outline
Plug("jiangmiao/auto-pairs")                                    -- Auto pairs
Plug("folke/which-key.nvim")                                    -- Which key
vim.call("plug#end")


-- Basic configuration
require("options")
require("keyMappings")
require("autocmds")
require("textObjects")


-- PLUGINS configuration
require("plug-config/gruvbox-baby")                             -- gruvbox | theme
require("plug-config/nvimTree")                                 -- nvim-tree | file explorer
require("plug-config/lualine")                                  -- lualine.nvim | statusline
require("plug-config/bufferline")                               -- bufferline.nvim
require("plug-config/treeSitter")                               -- tree-sitter
require("plug-config/gitFugitive")                              -- vim-fugitive
require("plug-config/gitGutter")                                -- vim-gitgutter
require("plug-config/aerial")                                   -- aerial | code outline
require("plug-config/hop")                                      -- hop.vim
require("plug-config/fzf")                                      -- fzf | fuzzy search finder
require("plug-config/vimspector")                               -- vimspector | debuggging
require('plug-config/quickScope')                               -- quick-scope
require("plug-config/nvim-surround")                            -- nvim-surround
require("plug-config/noice")                                    -- noice
require('plug-config/whichKey')                                 -- which-key
require("plug-config/coc")                                      -- coc.vim

-- vim-commentary
vim.api.nvim_create_autocmd("FileType", { pattern = { "json" }, command = [[setlocal commentstring=//\ %s]] })

-- vim-repeat
vim.api.nvim_command([[silent! call repeat#set("\<Plug>MyWonderfulMap", v:count)]])

-- neoscroll
require('neoscroll').setup()

-- highlights
require("highlights")
