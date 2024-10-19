-- <<-------------------------Git signs -------------------------------------->>
require("gitsigns").setup {
    attach_to_untracked = false,
    on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.silent = true
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
            if vim.wo.diff then return "]h" end
            vim.schedule(function() gs.next_hunk() end)
            return "<Ignore>"
        end, { expr = true })

        map("n", "[h", function()
            if vim.wo.diff then return "[h" end
            vim.schedule(function() gs.prev_hunk() end)
            return "<Ignore>"
        end, { expr = true })

        -- Actions
        map({ "n", "v" }, "<leader>gha", ":Gitsigns stage_hunk<CR>")
        map({ "n", "v" }, "<leader>ghu", ":Gitsigns reset_hunk<CR>")
        map("n", "<leader>ghp", gs.preview_hunk)

        --toggle_signs
        map("n", "<leader>tg", gs.toggle_signs)

        -- Text object
        map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>")
    end

}
-- Useful toggle
-- Gitsigns toggle_linehl               > highlights changed lines
-- Gitsigns toggle_word_diff            > highlight changed word
-- Gitsigns toggle_deleted              > display deleted text
-- Gitsigns toggle_current_line_blame   > show current line blame info
-- <<------------------------------------------------------------------------->>


-- <<-------------------------Git Fugitive ----------------------------------->>
local keymap = map
keymap("n", "<leader>gd", ":Gvdiffsplit<CR>", "Git diff")
keymap("n", "<leader>gD", ":Gvdiffsplit!<CR>", "Git diff split for resolving conflicts")
keymap("n", "<leader>gc", ":Gread<CR>", "Git checkout file (revert buffer to last commit)")
keymap("n", "<leader>ga", ":Gwrite<CR>", "Git add current file")
keymap("n", "<leader>gb", ":G blame<CR>", "Git blame")
keymap("n", "<leader>gr", ":G reset<CR>", "Git reset current file")
-- " Notes: useful commands
-- " Git difftool    - Open diff for current buffer in quickfix list
-- " Git difftool -y - Open all git modified files in a new tab
-- " Gclog           - Open commit history in quick fix list (use cn and cp to
-- " jump between quickfix items)
-- <<------------------------------------------------------------------------->>
