require("flash").setup({
    modes = {
        char = {
            -- disable f,F,t and T
            enabled = false
        }
    }
})
local flash = require("flash")
map({"n", "x", "o"}, "s", function()
    flash.jump({
        search = {
            multi_window = false
        }
    })
end, "Flash: Jump")
map({"n", "x", "o"}, "gs", function()
    flash.treesitter_search({
        label = {
            rainbow = {
                enabled = true,
                shade = 4
            }
        },
        highlight = {
            backdrop = true,
            matches = false
        },
        search = {
            multi_window = false
        }
    })
end, "Flash Treesitter: Search")
map({"n", "x", "o"}, "gS", function()
    flash.treesitter({
        label = {
            rainbow = {
                enabled = true,
                shade = 4
            }
        },
        highlight = {
            backdrop = true,
            matches = false
        }
    })
end, "Flash Treesitter")
map({"o", "x", "n"}, "<CR>", function()
    flash.jump({
        search = {
            mode = "search",
            max_length = 0,
            multi_window = false
        },
        label = {
            after = {0, 0}
        },
        pattern = "^"
    })
end, "Line wise jump.")
