return {
    cmd = { "lua-language-server" },
    filetypes = { "lua" },
    root_markers = {
        ".luarc.json",
        ".luarc.jsonc",
        ".luacheckrc",
        ".stylua.toml",
        "stylua.toml",
        "selene.toml",
        "selene.yml",
        ".git",
    },
    settings = {
        Lua = {
            format = {
                -- enable = true,
                defaultConfig = {
                    indent_style = "Space",
                    indent_size = "2",
                    column_width = "100",
                },
            },
            workspace = {
                checkThirdParty = false,
                library = { vim.env.VIMRUNTIME },
            },
        },
    },
}
