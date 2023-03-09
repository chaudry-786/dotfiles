-- if vim.g.started_by_firenvim then
-- do something if neovim launched by firenvim
-- end

-- Install extension on chrome
-- https://chrome.google.com/webstore/detail/firenvim/egpjdkipkomnmjhjmdamaniclmdlobbo
-- set shortcut to launch nvim in browser
-- chrome://extensions/shortcuts

vim.g.firenvim_config = {
    globalSettings = {
        alt = "all",
    },
    localSettings = {
        [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never",
        },
    }
}
