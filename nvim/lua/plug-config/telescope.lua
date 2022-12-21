local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

local actions = require("telescope.actions")
require('telescope').setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
            },
        },
        prompt_prefix = "   ",
        selection_caret = " ",
        sorting_strategy = "ascending",
        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                prompt_position = "top",
                preview_width = 0.55,
                result_width = 0.8
            },
            vertical = { mirror = false },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120
        }
    },
    pickers = {
        find_files = {
            find_command = { "rg", "--files", "--hidden" },
        },
        live_grep = {
            additional_args = function()
                return { "--hidden" }
            end
        },
    },
})

keymap("n", "<leader>/", ":Telescope current_buffer_fuzzy_find<CR>", opts)
keymap("n", "<leader>fb", ":Telescope buffers<CR>", opts)
keymap("n", "<leader>fc", ":Telescope commands<CR>", opts)
keymap("n", "<leader>ff", ":Telescope find_files<CR>", opts)
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", opts)
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", opts)
keymap("n", "<leader>fo", ":Telescope vim_options<CR>", opts)
keymap("n", "<leader>fs", ":Telescope spell_suggest<CR>", opts)
