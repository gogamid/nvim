vim.lsp.config("lua_ls", {
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
      semanticTokens = true, -- overrides injections for 20s
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

-- used when buf lsp is buggy
vim.lsp.config("protobuf_language_server", {
  cmd = { "/Users/gamidli/go/bin/protobuf-language-server" },
  filetypes = { "proto" },
  root_markers = { ".git" },
  single_file_support = true,
  settings = {
    -- ["additional-proto-dirs"] = [
    -- path to additional protobuf directories
    -- "vendor",
    -- "third_party",
    -- ]
  },
})

vim.lsp.enable({
  -- "ada_ls",
  -- "agda_ls",
  -- "aiken",
  -- "air",
  -- "alloy_ls",
  -- "anakin_language_server",
  -- "angularls",
  -- "ansiblels",
  -- "antlersls",
  -- "arduino_language_server",
  -- "asm_lsp",
  -- "ast_grep",
  -- "astro",
  -- "atlas",
  -- "autohotkey_lsp",
  -- "autotools_ls",
  -- "awk_ls",
  -- "azure_pipelines_ls",
  -- "bacon_ls",
  -- "ballerina",
  -- "basedpyright",
  "bashls",
  -- "basics_ls",
  -- "bazelrc_lsp",
  -- "beancount",
  -- "bicep",
  -- "biome",
  -- "bitbake_language_server",
  -- "blueprint_ls",
  -- "bqls",
  -- "bright_script",
  -- "bsl_ls",
  -- "buck2",
  -- "buddy_ls",
  "buf_ls", -- for proto files
  -- "bufls",
  -- "bzl",
  -- "c3_lsp",
  -- "cairo_ls",
  -- "ccls",
  -- "cds_lsp",
  -- "circom-lsp",
  -- "clangd",
  -- "clarinet",
  -- "clojure_lsp",
  -- "cmake",
  -- "cobol_ls",
  -- "codebook",
  -- "coffeesense",
  -- "contextive",
  -- "coq_lsp",
  -- "crystalline",
  -- "csharp_ls",
  -- "cspell_ls",
  -- "css_variables",
  -- "cssls",
  -- "cssmodules_ls",
  -- "cucumber_language_server",
  -- "cue",
  -- "custom_elements_ls",
  -- "cypher_ls",
  -- "daedalus_ls",
  -- "dafny",
  -- "dagger",
  -- "dartls",
  -- "dcmls",
  -- "debputy",
  -- "denols",
  -- "dhall_lsp_server",
  -- "diagnosticls",
  -- "digestif",
  -- "djlsp",
  -- "docker_compose_language_service",
  -- "docker_language_server",
  -- "dockerls",
  -- "dolmenls",
  -- "dotls",
  -- "dprint",
  -- "ds_pinyin_lsp",
  -- "dts_lsp",
  -- "earthlyls",
  -- "ecsact",
  -- "efm",
  -- "elixirls",
  -- "elmls",
  -- "elp",
  -- "ember",
  -- "emmet_language_server",
  -- "emmet_ls",
  -- "emm_ls",
  -- "erg_language_server",
  -- "erlangls",
  -- "esbonio",
  "eslint",
  -- "facility_language_server",
  -- "fennel_language_server",
  -- "fennel_ls",
  -- "fish_lsp",
  -- "flow",
  -- "flux_lsp",
  -- "foam_ls",
  -- "fortls",
  -- "fsautocomplete",
  -- "fsharp_language_server",
  -- "fstar",
  -- "futhark_lsp",
  -- "gdscript",
  -- "gdshader_lsp",
  -- "gh_actions_ls",
  -- "ghcide",
  -- "ghdl_ls",
  -- "ginko_ls",
  -- "gitlab_ci_ls",
  -- "glasgow",
  -- "gleam",
  -- "glint",
  -- "glsl_analyzer",
  -- "glslls",
  -- "gnls",
  -- "golangci_lint_ls",
  "gopls",
  -- "gradle_ls",
  -- "grammarly",
  -- "graphql",
  -- "groovyls",
  -- "guile_ls",
  -- "harper_ls",
  -- "hdl_checker",
  -- "helm_ls",
  -- "herb_ls",
  -- "hhvm",
  -- "hie",
  -- "hlasm",
  -- "hls",
  -- "hoon_ls",
  -- "html",
  -- "htmx",
  -- "hydra_lsp",
  -- "hyprls",
  -- "idris2_lsp",
  -- "intelephense",
  -- "janet_lsp",
  -- "java_language_server",
  -- "jdtls",
  -- "jedi_language_server",
  -- "jinja_lsp",
  -- "jqls",
  "jsonls",
  -- "jsonnet_ls",
  -- "julials",
  -- "just",
  -- "kcl",
  -- "koka",
  -- "kotlin_language_server",
  -- "kotlin_lsp",
  -- "kulala_ls",
  -- "laravel_ls",
  -- "lean3ls",
  -- "lelwel_ls",
  -- "lemminx",
  -- "lexical",
  -- "lsp_ai",
  -- "ltex",
  -- "ltex_plus",
  "lua_ls",
  -- "lwc_ls",
  -- "m68k",
  -- "markdown_oxide",
  -- "marko-js",
  -- "marksman",
  -- "matlab_ls",
  -- "mdx_analyzer",
  -- "mesonlsp",
  -- "metals",
  -- "millet",
  -- "mint",
  -- "mlir_lsp_server",
  -- "mlir_pdll_lsp_server",
  -- "mm0_ls",
  -- "mojo",
  -- "motoko_lsp",
  -- "move_analyzer",
  -- "msbuild_project_tools_server",
  -- "muon",
  -- "mutt_ls",
  -- "n_lsp",
  -- "neocmake",
  -- "nextflow_ls",
  -- "nextls",
  -- "nginx_language_server",
  -- "nickel_ls",
  -- "nil_ls",
  -- "nim_langserver",
  -- "nimls",
  -- "nixd",
  -- "nomad_lsp",
  -- "ntt",
  -- "nushell",
  -- "nxls",
  -- "ocamlls",
  -- "ocamllsp",
  -- "ols",
  "omnisharp",
  -- "opencl_ls",
  -- "openscad_ls",
  -- "openscad_lsp",
  -- "oxlint",
  -- "pact_ls",
  -- "pasls",
  -- "pbls",
  -- "perlls",
  -- "perlnavigator",
  -- "perlpls",
  -- "pest_ls",
  -- "phan",
  -- "phpactor",
  -- "pico8_ls",
  -- "please",
  -- "pli",
  -- "poryscript_pls",
  -- "postgres_lsp",
  -- "powershell_es",
  -- "prismals",
  -- "prolog_ls",
  -- "prosemd_lsp",
  -- "protols",
  -- "protobuf_language_server",
  -- "psalm",
  -- "pug",
  -- "puppet",
  -- "purescriptls",
  -- "pylsp",
  -- "pylyzer",
  -- "pyre",
  -- "pyrefly",
  -- "pyright",
  -- "qmlls",
  -- "quick_lint_js",
  -- "r_language_server",
  -- "racket_langserver",
  -- "raku_navigator",
  -- "reason_ls",
  -- "regal",
  -- "regols",
  -- "remark_ls",
  -- "rescriptls",
  -- "rls",
  -- "rnix",
  -- "robotcode",
  -- "robotframework_ls",
  -- "roc_ls",
  -- "rome",
  -- "roslyn_ls",
  -- "rpmspec",
  -- "rubocop",
  -- "ruby_lsp",
  -- "ruff",
  -- "ruff_lsp",
  -- "rune_languageserver",
  -- "rust_analyzer",
  -- "salt_ls",
  -- "scheme_langserver",
  -- "scry",
  -- "selene3p_ls",
  -- "serve_d",
  -- "shopify_theme_ls",
  -- "sixtyfps",
  -- "slangd",
  -- "slint_lsp",
  -- "smarty_ls",
  -- "smithy_ls",
  -- "snakeskin_ls",
  -- "snyk_ls",
  -- "solang",
  -- "solargraph",
  -- "solc",
  -- "solidity",
  -- "solidity_ls",
  -- "solidity_ls_nomicfoundation",
  -- "somesass_ls",
  -- "sorbet",
  -- "sourcekit",
  -- "spectral",
  -- "spyglassmc_language_server",
  -- "sqlls",
  -- "sqls",
  -- "sqruff",
  -- "standardrb",
  -- "starlark_rust",
  -- "starpls",
  -- "statix",
  -- "steep",
  -- "stimulus_ls",
  -- "stylelint_lsp",
  -- "st3p_ls",
  -- "superhtml",
  -- "svelte",
  -- "svlangserver",
  -- "svls",
  -- "swift_mesonls",
  -- "syntax_tree",
  -- "systemd_ls",
  -- "tabby_ml",
  -- "tailwindcss",
  "taplo", -- for toml files
  -- "tblgen_lsp_server",
  -- "teal_ls",
  -- "templ",
  -- "termux_language_server",
  -- "terraform_lsp",
  -- "terraformls",
  -- "texlab",
  -- "textlsp",
  -- "tflint",
  -- "theme_check",
  -- "thriftls",
  -- "tilt_ls",
  -- "tinymist",
  -- "tofu_ls",
  -- "tombi",
  -- "ts_ls",
  -- "ts_query_ls",
  -- "tsp_server",
  -- "ttags",
  -- "turbo_ls",
  -- "turtle_ls",
  -- "tvm_ffi_navigator",
  -- "twiggy_language_server",
  -- "ty",
  -- "typeprof",
  -- "typos_lsp",
  -- "typst_lsp",
  -- "uiua",
  -- "ungrammar_languageserver",
  -- "unison",
  -- "unocss",
  -- "uvls",
  -- "v_analyzer",
  -- "vacuum",
  -- "vala_ls",
  -- "vale_ls",
  -- "vectorcode_server",
  -- "verible",
  -- "veridian",
  -- "veryl_ls",
  -- "vespa_ls",
  -- "vhdl_ls",
  -- "vimls",
  -- "visualforce_ls",
  -- "vls",
  -- "volar",
  -- "vscoqtop",
  "vtsls",
  "vue_ls",
  -- "wasm_language_tools",
  -- "wgsl_analyzer",
  "yamlls",
  -- "yang_lsp",
  -- "yls",
  -- "ziggy",
  -- "ziggy_schema",
  -- "zk",
  -- "zls",
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.lsp.inlay_hint.enable(true)

    -- Information
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = args.buf, desc = "Hover" })

    -- Code actions
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { buffer = args.buf, desc = "Code Action" })
    vim.keymap.set("n", "<leader>cr", vim.lsp.buf.rename, { buffer = args.buf, desc = "Rename" })
    vim.keymap.set("n", "<leader>cl", vim.lsp.codelens.run, { buffer = args.buf, desc = "CodeLens" })

    -- Diagnostics
    vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { buffer = args.buf, desc = "Open Diagnostic" })
    vim.keymap.set("n", "<leader>cD", vim.diagnostic.setloclist, { buffer = args.buf, desc = "Quickfix Diagnostics" })

    -- Code actions
    vim.keymap.set("n", "gd", function()
      Snacks.picker.lsp_definitions()
    end, { desc = "Definitions", buffer = args.buf })
    vim.keymap.set("n", "gD", function()
      Snacks.picker.lsp_declarations()
    end, { desc = "Declarations", buffer = args.buf })
    vim.keymap.set("n", "gr", function()
      Snacks.picker.lsp_references()
    end, { nowait = true, desc = "References", buffer = args.buf })
    vim.keymap.set("n", "gi", function()
      Snacks.picker.lsp_implementations()
    end, { desc = "Implementation", buffer = args.buf })
    vim.keymap.set("n", "gt", function()
      Snacks.picker.lsp_type_definitions()
    end, { desc = "Type Definition", buffer = args.buf })
  end,
})

vim.env.PATH = vim.env.PATH .. ":" .. vim.fn.stdpath("data") .. "/mason/bin"
return {
  "neovim/nvim-lspconfig", -- default configs for lsps
  "mason-org/mason.nvim", -- package manager
}
