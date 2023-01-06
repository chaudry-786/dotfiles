local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

local custom_actions = {}
-- if more than one items selected, secnd to qf list
function custom_actions.fzf_multi_select(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = table.getn(picker:get_multi_selection())

    if num_selections > 1 then
        local picker = action_state.get_current_picker(prompt_bufnr)

        -- this will open all the files
        -- for _, entry in ipairs(picker:get_multi_selection()) do
        --     vim.cmd(string.format("%s %s", ":e!", entry.value))
        -- end

        -- send all items to quick fix list
        actions.send_selected_to_qflist(prompt_bufnr)
        actions.open_qflist(prompt_bufnr)
    else
        actions.select_default(prompt_bufnr)
    end
end

-- when file is opened with telescope folds do not work.
-- :h zx zi
-- https://github.com/nvim-telescope/telescope.nvim/issues/559
vim.api.nvim_create_autocmd('BufRead', {
    group = "CustomAutoCmds",
    callback = function()
        vim.api.nvim_create_autocmd('BufWinEnter', {
            group = "CustomAutoCmds",
            once = true,
            command = 'normal! zxzi'
        })
    end
})

require('telescope').setup({
    defaults = {
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ['<CR>'] = custom_actions.fzf_multi_select
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
