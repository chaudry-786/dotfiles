require "nvim-treesitter.configs".setup {
    -- TS parsers
    ensure_installed = { "c",
        "python",
        "java",
        "bash",
        "vim",
        "comment",
        "json",
        "jsonc",
        "javascript",
        "typescript",
        "html",
        "htmldjango",
        "css",
        "lua",
        "regex",
        "sql",
        "rust",
        "yaml"
    },

    -- TS modules
    highlight = {
        enable = true,
        disable = function()
            return vim.g.vscode or false
        end,
    },
    -- nvim-treesitter/nvim-treesitter-textobjects
    textobjects = {
        select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["ai"] = "@conditional.outer",
                ["ii"] = "@conditional.inner",
            },
        },

        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]f"] = "@function.outer",
                ["]l"] = "@loop.outer",
                ["]i"] = "@conditional.outer",
            },
            goto_previous_start = {
                ["[f"] = "@function.outer",
                ["[l"] = "@loop.outer",
                ["[i"] = "@conditional.outer",
            },
        },
    },

    -- Auto tag for typescript, javascript
    autotag = { enable = true }
}
