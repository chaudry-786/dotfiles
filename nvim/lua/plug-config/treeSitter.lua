require "nvim-treesitter.configs".setup {
    -- TS parsers
    ensure_installed = { "c",
        "python",
        "java",
        "bash",
        "vim",
        "comment",
        "json",
        "javascript",
        "typescript",
        "html",
        "css",
        "lua",
        "regex",
        "sql"
    },

    -- TS modules
    highlight = {
        enable = true,
        disable = { "rust" },
    },
    -- nvim-treesitter/nvim-treesitter-textobjects
    textobjects = {
        select = {
            enable = true,
            -- Automatically jump forward to textobj, similar to targets.vim
            lookahead = true,
            keymaps = {
                ["ac"] = "@class.outer",
                ["ic"] = "@class.inner",
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["al"] = "@loop.outer",
                ["il"] = "@loop.inner",
                ["ai"] = "@conditional.outer",
                ["ii"] = "@conditional.inner",
                ["aC"] = "@comment.outer",
            },
        },

        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                ["]c"] = "@class.outer",
                ["]f"] = "@function.outer",
                ["]l"] = "@loop.outer",
                ["]i"] = "@conditional.outer",
                ["]C"] = "@comment.outer",
            },
            goto_next_end = {
                ["]]c"] = "@class.outer",
                ["]]f"] = "@function.outer",
                ["]]l"] = "@loop.outer",
                ["]]i"] = "@conditional.outer",
                ["]]C"] = "@comment.outer",
            },
            goto_previous_start = {
                ["[c"] = "@class.outer",
                ["[f"] = "@function.outer",
                ["[l"] = "@loop.outer",
                ["[i"] = "@conditional.outer",
                ["[C"] = "@comment.outer",
            },
            goto_previous_end = {
                ["[]c"] = "@class.outer",
                ["[]f"] = "@function.outer",
                ["[]l"] = "@loop.outer",
                ["[]i"] = "@conditional.outer",
                ["[]C"] = "@comment.outer",
            },
        },
    },

    -- Auto tag for typescript, javascript
    autotag = { enable = true }
}

-- reminder on how to correctly navigate
vim.keymap.set("", "[[", function() vim.notify("START = [f END = []f ") end, { noremap = true, silent = true })
vim.keymap.set("", "][", function() vim.notify("START = [f END = []f ") end, { noremap = true, silent = true })
