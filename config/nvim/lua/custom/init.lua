-- ╔══════════════════════════════════════════════════════════════╗
-- ║  NEOVIM — Base Options & Phantom Settings                    ║
-- ╚══════════════════════════════════════════════════════════════╝

local opt = vim.opt

-- ── Editor ───────────────────────────────────────────────────
opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.cursorlineopt = "number"
opt.signcolumn = "yes"
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.wrap = false
opt.linebreak = true
opt.showmode = false
opt.termguicolors = true
opt.pumheight = 12
opt.pumblend = 0
opt.winblend = 0
opt.cmdheight = 1
opt.laststatus = 3
opt.splitbelow = true
opt.splitright = true

-- ── Indentation ──────────────────────────────────────────────
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.smartindent = true

-- ── Search ───────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

-- ── Persistence ──────────────────────────────────────────────
opt.undofile = true
opt.undolevels = 10000
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- ── Performance ──────────────────────────────────────────────
opt.updatetime = 200
opt.timeoutlen = 300
opt.redrawtime = 1500
opt.lazyredraw = false

-- ── Clipboard ────────────────────────────────────────────────
opt.clipboard = "unnamedplus"

-- ── Fold ─────────────────────────────────────────────────────
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99

-- ── Phantom highlights ───────────────────────────────────────
vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#BF616A" })
vim.api.nvim_set_hl(0, "DapStopped", { fg = "#7EC8A0" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#BF616A", bg = "#1a1010" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn", { fg = "#D4A76A", bg = "#1a1810" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextInfo", { fg = "#81A1C1", bg = "#10141a" })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextHint", { fg = "#7EC8A0", bg = "#101a14" })
