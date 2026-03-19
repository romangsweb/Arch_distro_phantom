-- ╔══════════════════════════════════════════════════════════════╗
-- ║  NEOVIM — NvChad Custom Plugins (Phantom · Full Stack)       ║
-- ║  LSP · Formatters · Linters · AI · Debug · Git · Markdown    ║
-- ╚══════════════════════════════════════════════════════════════╝

local plugins = {

  -- ── LSP Configuration ──────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require("custom.configs.lspconfig")
    end,
  },

  -- LSP Installer
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Language servers
        "lua-language-server",
        "pyright",
        "typescript-language-server",
        "rust-analyzer",
        "gopls",
        "bash-language-server",
        "dockerfile-language-server",
        "yaml-language-server",
        "json-lsp",
        "html-lsp",
        "css-lsp",
        "tailwindcss-language-server",
        "terraform-ls",
        "ansible-language-server",
        "marksman",

        -- Formatters
        "black",
        "isort",
        "prettier",
        "stylua",
        "shfmt",
        "ruff",
        "goimports",
        "rustfmt",

        -- Linters
        "ruff",
        "eslint_d",
        "shellcheck",
        "hadolint",
        "yamllint",
        "markdownlint",
        "mypy",

        -- DAP (Debug)
        "debugpy",
        "js-debug-adapter",
        "codelldb",
        "delve",
      },
    },
  },

  -- Formatter
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "isort" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        rust = { "rustfmt" },
        go = { "goimports" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        toml = { "taplo" },
        terraform = { "terraform_fmt" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    },
  },

  -- Linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = {
        python = { "ruff", "mypy" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        sh = { "shellcheck" },
        bash = { "shellcheck" },
        dockerfile = { "hadolint" },
        yaml = { "yamllint" },
        markdown = { "markdownlint" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  -- ── Treesitter (Enhanced Syntax) ───────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "lua", "python", "rust", "go", "javascript", "typescript",
        "tsx", "html", "css", "json", "yaml", "toml", "bash",
        "dockerfile", "terraform", "hcl", "sql", "markdown",
        "markdown_inline", "vim", "vimdoc", "gitcommit", "diff",
        "regex", "c", "cpp", "cmake", "make",
      },
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    },
  },

  -- ── AI Coding ──────────────────────────────────────────────
  -- GitHub Copilot
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept = "<C-y>",
          accept_word = "<C-w>",
          accept_line = "<C-l>",
          next = "<C-]>",
          prev = "<C-[>",
          dismiss = "<C-e>",
        },
      },
      panel = { enabled = false },
    },
  },

  -- ChatGPT / LLM in editor
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {},
  },

  -- ── Debug Adapter Protocol ─────────────────────────────────
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
      "leoluz/nvim-dap-go",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      -- Auto open/close DAP UI
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end

      -- Python DAP
      require("dap-python").setup("python")

      -- Go DAP
      require("dap-go").setup()

      -- Signs
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint" })
      vim.fn.sign_define("DapStopped", { text = "▸", texthl = "DapStopped" })
    end,
  },

  -- ── Git Enhancement ────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "▎" },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 500,
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },

  -- ── Navigation & Search ────────────────────────────────────
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end },
    },
  },

  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {},
  },

  -- File explorer enhancement
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      default_file_explorer = false,
      columns = { "icon", "permissions", "size", "mtime" },
    },
  },

  -- ── UI Enhancements ────────────────────────────────────────
  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
      scope = { show_start = false, show_end = false },
    },
  },

  -- Color highlighter
  {
    "NvChad/nvim-colorizer.lua",
    opts = {
      user_default_options = {
        css = true,
        tailwind = true,
        mode = "virtualtext",
      },
    },
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    opts = {},
  },

  -- Better diagnostics
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
  },

  -- ── Jupyter / Data Science ─────────────────────────────────
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    ft = { "python", "quarto" },
    dependencies = { "3rd/image.nvim" },
  },

  -- ── Markdown Preview ───────────────────────────────────────
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview" },
    build = "cd app && npx --yes yarn install",
    ft = { "markdown" },
  },

  -- ── Docker / DevOps ────────────────────────────────────────
  {
    "dgrbrady/nvim-docker",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
    cmd = "DockerContainers",
  },

  -- ── Testing ────────────────────────────────────────────────
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
    },
    cmd = "Neotest",
  },

  -- ── Which Key (remind keybindings) ─────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
  },

  -- ── Session Management ─────────────────────────────────────
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
  },
}

return plugins
