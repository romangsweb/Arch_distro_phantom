-- ╔══════════════════════════════════════════════════════════════╗
-- ║  NEOVIM — LSP Server Configs                                 ║
-- ╚══════════════════════════════════════════════════════════════╝

local lspconfig = require("lspconfig")
local nvlsp = require("nvchad.configs.lspconfig")

local servers = {
  "pyright", "ts_ls", "rust_analyzer", "gopls",
  "bashls", "dockerls", "yamlls", "jsonls",
  "html", "cssls", "tailwindcss", "terraformls",
  "ansiblels", "marksman", "lua_ls",
}

for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
end

-- Python specific
lspconfig.pyright.setup({
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        diagnosticSeverityOverrides = {
          reportMissingImports = "warning",
          reportMissingModuleSource = "none",
        },
      },
    },
  },
})

-- Lua specific (for Neovim config)
lspconfig.lua_ls.setup({
  on_attach = nvlsp.on_attach,
  capabilities = nvlsp.capabilities,
  settings = {
    Lua = {
      diagnostics = { globals = { "vim" } },
      workspace = { checkThirdParty = false },
    },
  },
})
