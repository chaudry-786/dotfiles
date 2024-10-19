local keymap = map

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local custom_actions = {}
-- if more than one items selected, send to qf list
function custom_actions.fzf_multi_select(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)
    local num_selections = table.getn(picker:get_multi_selection())

    if num_selections > 1 then
        actions.send_selected_to_qflist(prompt_bufnr)
        actions.open_qflist(prompt_bufnr)
    else
        actions.select_default(prompt_bufnr)
    end
end

-- do not preview large files
local previewers = require("telescope.previewers")
local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}

    filepath = vim.fn.expand(filepath)
    vim.loop.fs_stat(filepath, function(_, stat)
        if not stat then return end
        if stat.size > 100000 then
            return
        else
            previewers.buffer_previewer_maker(filepath, bufnr, opts)
        end
    end)
end

require("telescope").setup({
    defaults = {
        buffer_previewer_maker = new_maker,
        mappings = {
            i = {
                ["<esc>"] = actions.close,
                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,
                ["<CR>"] = custom_actions.fzf_multi_select
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
    extensions = {
        aerial = {
            format_symbol = function(symbol_path, filetype)
                if filetype == "json" or filetype == "yaml" then
                    return table.concat(symbol_path, ".")
                else
                    return symbol_path[#symbol_path]
                end
            end,
            show_columns = "symbols",
        },
    },
})

keymap("n", "<leader>/", ":Telescope current_buffer_fuzzy_find<CR>", "Telescope search within the current buffer")
keymap("n", "<leader>fb", ":Telescope buffers<CR>", "Telescope find buffers")
keymap("n", "<leader>fc", ":Telescope commands<CR>", "Telescope find commands")
keymap("n", "<leader>ff", ":Telescope find_files<CR>", "Telescope find files")
keymap("n", "<leader>fg", ":Telescope live_grep<CR>", "Telescope live grep")
keymap("n", "<leader>fh", ":Telescope help_tags<CR>", "Telescope find help tags")
keymap("n", "<leader>fo", ":Telescope aerial<CR>", "Telescope find outline")
keymap("n", "<leader>fq", ":Telescope quickfix<CR>", "Telescope find quickfix entries")
keymap("n", "<leader>fs", ":Telescope spell_suggest<CR>", "Telescope find spell suggestions")
