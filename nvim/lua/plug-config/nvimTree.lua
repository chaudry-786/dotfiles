local function on_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
        return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))
    vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts('CD'))
end
require("nvim-tree").setup({
    on_attach = on_attach,
    sort_by = "case_sensitive",
    hijack_cursor = true,
    sync_root_with_cwd = true,
    update_focused_file = { enable = true },
    git = {
        show_on_dirs = false,
        ignore = true
    },
    view = {
        adaptive_size = true,
    },
    renderer = {
        indent_markers = {
            enable = true,
        },
        group_empty = true, -- empty folders on the same line
        icons = {
            git_placement = "signcolumn",
            glyphs = {
                git = {
                    unstaged = "",
                    staged = "",
                    untracked = "",
                }
            }
        }
    },
    diagnostics = {
        enable = false,
        show_on_dirs = false,
        icons = {
            error = "",
        },
    },
    filters = {
        -- dotfiles = true, --don't show hidden files
        custom = { "venv", "__pycache__", ".git", "Session.vim" } -- ignore folders
    },
    actions = {
        open_file = {
            quit_on_open = true,
        }
    },
})
map("n", "<C-n>", ":NvimTreeToggle<CR>", "Toggle file explorer.")

-- cursorline
vim.api.nvim_create_autocmd("BufEnter", {
    group = "CustomAutoCmds",
    callback = function()
        if vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
            vim.cmd "setlocal cursorline"
        end
    end
})

-- automatically open newly created file
local api = require("nvim-tree.api")
api.events.subscribe(api.events.Event.FileCreated, function(file)
    vim.cmd("edit " .. file.fname)
end)
