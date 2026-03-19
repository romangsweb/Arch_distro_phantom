-- ╔══════════════════════════════════════════════════════════════╗
-- ║  NEOVIM — Custom Keymaps                                     ║
-- ╚══════════════════════════════════════════════════════════════╝

local map = vim.keymap.set

-- ── General ──────────────────────────────────────────────────
map("n", ";", ":", { desc = "CMD mode" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>bd<cr>", { desc = "Close buffer" })
map("n", "<Esc>", "<cmd>noh<cr>", { desc = "Clear search" })

-- ── Splits ───────────────────────────────────────────────────
map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })

-- ── Debug (DAP) ──────────────────────────────────────────────
map("n", "<leader>db", "<cmd>lua require('dap').toggle_breakpoint()<cr>", { desc = "Toggle breakpoint" })
map("n", "<leader>dc", "<cmd>lua require('dap').continue()<cr>", { desc = "Continue" })
map("n", "<leader>di", "<cmd>lua require('dap').step_into()<cr>", { desc = "Step into" })
map("n", "<leader>do", "<cmd>lua require('dap').step_over()<cr>", { desc = "Step over" })
map("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<cr>", { desc = "REPL" })
map("n", "<leader>du", "<cmd>lua require('dapui').toggle()<cr>", { desc = "DAP UI" })

-- ── Git ──────────────────────────────────────────────────────
map("n", "<leader>gd", "<cmd>DiffviewOpen<cr>", { desc = "Diff view" })
map("n", "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
map("n", "<leader>gl", "<cmd>lua require('gitsigns').blame_line()<cr>", { desc = "Blame line" })

-- ── Diagnostics ──────────────────────────────────────────────
map("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Trouble diagnostics" })
map("n", "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })
map("n", "<leader>ts", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols" })

-- ── Search ───────────────────────────────────────────────────
map("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })

-- ── Jupyter / Molten ─────────────────────────────────────────
map("n", "<leader>mi", "<cmd>MoltenInit<cr>", { desc = "Molten init" })
map("n", "<leader>mr", "<cmd>MoltenEvaluateOperator<cr>", { desc = "Molten run" })
map("n", "<leader>ml", "<cmd>MoltenEvaluateLine<cr>", { desc = "Molten run line" })
map("v", "<leader>mr", ":<C-u>MoltenEvaluateVisual<cr>", { desc = "Molten run selection" })

-- ── Testing ──────────────────────────────────────────────────
map("n", "<leader>tn", "<cmd>lua require('neotest').run.run()<cr>", { desc = "Run nearest test" })
map("n", "<leader>tf", "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>", { desc = "Run file tests" })
map("n", "<leader>to", "<cmd>lua require('neotest').output_panel.toggle()<cr>", { desc = "Test output" })

-- ── Oil (File Explorer) ──────────────────────────────────────
map("n", "-", "<cmd>Oil<cr>", { desc = "Oil file explorer" })

-- ── Session ──────────────────────────────────────────────────
map("n", "<leader>qs", "<cmd>lua require('persistence').load()<cr>", { desc = "Restore session" })
map("n", "<leader>ql", "<cmd>lua require('persistence').load({ last = true })<cr>", { desc = "Last session" })

-- ── Markdown ─────────────────────────────────────────────────
map("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", { desc = "Markdown preview" })
