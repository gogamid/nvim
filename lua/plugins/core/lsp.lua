return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "mason-org/mason.nvim", opts = {} }, -- lsp/formatter/linter install manager
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      opts = {
        ensure_installed = {
          -- lua
          "stylua",
          "lua-language-server",

          -- buf
          "buf",

          -- bash
          "bash-language-server",
          "shfmt",

          -- c
          "clangd",

          -- c#
          "omnisharp",
          "omnisharp-mono",

          -- js/ts/vue
          "eslint-lsp",
          "vtsls",
          "vue-language-server",
          "prettier",

          -- go
          "gopls",
          "gofumpt",
          "goimports",
          "golangci-lint",

          -- json
          "json-lsp",

          -- yaml
          "yaml-language-server",

          -- sql
          "sql-formatter",
        },
      },
    }, --autoinstaller
    { "j-hui/fidget.nvim", opts = {} }, -- loading
    -- Allows extra capabilities provided by blink.cmp
    "saghen/blink.cmp",
  },
  config = function()
    vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        vim.lsp.inlay_hint.enable(true)

        local map = function(keys, func, desc, mode)
          mode = mode or "n"
          vim.keymap.set(mode, keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
        end

        -- Information
        map("K", vim.lsp.buf.hover, "Hover")

        -- Code actions
        map("<leader>ca", vim.lsp.buf.code_action, "Code Action", { "n", "v" })
        map("<leader>cr", vim.lsp.buf.rename, "Rename")
        map("<leader>cl", vim.lsp.codelens.run, "CodeLens")

        -- Diagnostics
        map("<leader>cD", vim.diagnostic.setloclist, "Quickfix Diagnostics")

        -- Code actions
        map("gd", Snacks.picker.lsp_definitions, "Definitions")
        map("gD", Snacks.picker.lsp_declarations, "Declarations")
        map("gr", Snacks.picker.lsp_references, "References")
        map("gi", Snacks.picker.lsp_implementations, "Implementation")
        map("gt", Snacks.picker.lsp_type_definitions, "Type Definition")
        map("gI", Snacks.picker.lsp_incoming_calls, "Incoming Calls")
        map("gO", Snacks.picker.lsp_outgoing_calls, "Outgoing Calls")
      end,
    })

    local servers = {
      "bashls",
      "buf_ls", -- for proto files
      "clangd",
      "dartls",
      "eslint",
      "gopls",
      "jsonls",
      "lua_ls",
      "omnisharp",
      "taplo", -- for toml files
      "vtsls",
      "vue_ls",
      "yamlls",
    }

    --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
    --  add capabilities and enable
    local capabilities = require("blink.cmp").get_lsp_capabilities()
    for _, name in ipairs(servers) do
      local server = {}
      server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
      vim.lsp.config(name, server)
      vim.lsp.enable(name)
    end

    vim.lsp.config("lua_ls", {
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if
            path ~= vim.fn.stdpath("config")
            and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
          then
            return
          end
        end

        client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
          runtime = {
            version = "LuaJIT",
            path = { "lua/?.lua", "lua/?/init.lua" },
          },
          workspace = {
            checkThirdParty = false,
            -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
            --  See https://github.com/neovim/nvim-lspconfig/issues/3189
            library = vim.api.nvim_get_runtime_file("", true),
          },
        })
      end,
      settings = {
        Lua = {
          hint = {
            arrayIndex = "Disable",
          },
          codeLens = { enable = false },
        },
      },
    })

    local vue_language_server_path = vim.fn.stdpath("data")
      .. "/mason/packages/vue-language-server/node_modules/@vue/language-server"
    local vue_plugin = {
      name = "@vue/typescript-plugin",
      location = vue_language_server_path,
      languages = { "vue" },
      configNamespace = "typescript",
    }
    vim.lsp.config("vtsls", {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
        "vue",
      },
      single_file_support = true,
      settings = {
        vtsls = {
          tsserver = {
            globalPlugins = {
              vue_plugin,
            },
          },
        },
      },
    })

    vim.lsp.config("gopls", {
      settings = {
        gopls = {
          gofumpt = false,
          buildFlags = { "-tags=manual_test" },
          ["local"] = os.getenv("GO_LOCAL_PKG"),
          staticcheck = true,
          analyses = {
            shadow = true,
            unusedvariable = true,
            nilness = true,
            unusedwrite = true,
            useany = true,
            ST1003 = false,
          },
          hints = {
            compositeLiteralFields = false,
            compositeLiteralTypes = false,
            functionTypeParameters = false,
            constantValues = true,
            rangeVariableTypes = false,
            ignoredError = true,
            assignVariableTypes = false,
            parameterNames = false,
          },
          usePlaceholders = true,
          completeUnimported = true,
          directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
          semanticTokens = false, -- overrides injections
          diagnosticsTrigger = "Save",
        },
      },
      on_attach = function(client, _)
        -- Set semantic tokens provider if not already set
        if not client.server_capabilities.semanticTokensProvider then
          local semantic = client.config.capabilities.textDocument.semanticTokens
          if not semantic then
            vim.notify("LSP server does not support semantic tokens")
            return
          end
          client.server_capabilities.semanticTokensProvider = {
            full = true,
            legend = { tokenModifiers = semantic.tokenModifiers, tokenTypes = semantic.tokenTypes },
            range = true,
          }
        end

        -- Hide semantic highlights so Tree-sitter injections show through
        vim.api.nvim_set_hl(0, "@lsp.type.string.go", { link = "" })

        vim.api.nvim_create_autocmd("BufWritePre", {
          desc = "Auto-organize imports for go",
          pattern = "*.go",
          callback = function()
            local params = vim.lsp.util.make_range_params(0, "utf-8")
            vim.lsp.buf_request(0, "textDocument/codeAction", params, function(err, result, _)
              if err or not result or vim.tbl_isempty(result) then
                return
              end
              for _, action in pairs(result) do
                if action.kind == "source.organizeImports" then
                  vim.notify("Organizing imports...")
                  if action.command then
                    vim.lsp.buf.code_action({
                      apply = true,
                      context = { only = { "source.organizeImports" }, diagnostics = {} },
                    })
                  elseif action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
                  end
                  return
                end
              end
            end)
          end,
        })
      end,
    })
  end,
}
