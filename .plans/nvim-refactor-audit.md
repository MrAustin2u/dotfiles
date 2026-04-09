# Neovim Config Refactor Audit — Phased Plan

Generated after completing the earlier P1 bundle, mise LSP fixes, treesitter/angularls bugfixes, noice opts bug, and lsp-progress removal. See `git log` for the landed commits.

## Executive summary

Config health is **good to excellent**. Remaining findings are mostly small correctness bugs, lazy-loading misses, and stylistic/architectural cleanups.

---

## P1 — High-impact, low-risk

### 1.1 — Obsidian keymap malformed
- **Location:** `plugins/obsidian.lua:65`
- **Problem:** Keymap RHS is `"ObsidianOpen<cr>"` (literal text) instead of a command.
- **Fix:** `"<cmd>ObsidianOpen<cr>"`.
- **Risk:** Low · **Effort:** XS

### 1.2 — GraphQL LSP cmd may be stale
- **Location:** `lsp/graphql.lua:3`
- **Problem:** Uses `graphql-lsp server -m stream`; modern `graphql-language-service-cli` may just want `graphql-lsp`.
- **Fix:** Verify via `graphql-lsp --help` and upstream docs.
- **Risk:** Medium · **Effort:** S

### 1.3 — Oil.nvim loads at VimEnter
- **Location:** `plugins/oil.lua:3`
- **Problem:** `event = { "VimEnter" }` defeats the plugin's own `keys` spec.
- **Fix:** Remove the `event` line; rely on `keys` + `default_file_explorer = true`.
- **Risk:** Low · **Effort:** XS

### 1.4 — Navic not lazy-loaded
- **Location:** `plugins/navic.lua`
- **Problem:** No `lazy = true`, no `event`, no `ft`. Loads at startup despite only being used via LSP attach.
- **Fix:** Add `lazy = true` (LSP attach `pcall(require, "nvim-navic")` loads it on demand).
- **Risk:** Low · **Effort:** XS

### 1.5 — Devicons at VeryLazy
- **Location:** `plugins/devicons.lua`
- **Problem:** Can cause icon flicker on plugins that load before it.
- **Fix:** Change `event = "VeryLazy"` to `lazy = true` — consumers already declare it as a dependency.
- **Risk:** Low · **Effort:** XS

### 1.6 — CodeCompanion log_level = DEBUG
- **Location:** `plugins/codecompanion.lua:15`
- **Problem:** Logs will spam in normal usage.
- **Fix:** Change to `"WARN"` or delete the line.
- **Risk:** Low · **Effort:** XS

---

## P2 — Consolidation & cleanup

### 2.1 — Duplicate LSP kind icon tables
- **Location:** `config/utils.lua` (`icons.kinds`) vs `plugins/blink.lua:85-118`
- **Fix:** `kind_icons = require("config.utils").icons.kinds`.
- **Risk:** Low · **Effort:** S

### 2.2 — Unused `icons.misc` / `icons.ft`
- **Location:** `config/utils.lua:169-180`
- **Fix:** Grep for usage; trim unused entries.
- **Risk:** Low · **Effort:** S

### 2.3 — Dead `M.create_autocmd` wrapper
- **Location:** `config/utils.lua:230-250`
- **Fix:** Delete function (zero call sites).
- **Risk:** Low · **Effort:** XS

### 2.4 — `(unpack or table.unpack)` unnecessary on LuaJIT
- **Location:** `config/utils.lua:184`
- **Fix:** Use `unpack` directly.
- **Risk:** Low · **Effort:** XS

### 2.5 — gitsigns on_attach uses `package.loaded.gitsigns`
- **Location:** `plugins/gitsigns.lua:44`
- **Fix:** Use `require("gitsigns")` for clarity.
- **Risk:** Low · **Effort:** XS

### 2.6 — angularls helpers run at module load
- **Location:** `lsp/angularls.lua:1-64`
- **Problem:** `vim.fn.system`, `fs_stat`, package.json read all happen at LSP config load, not when server attaches.
- **Fix:** Move logic into a `root_dir` callback / lazy init.
- **Risk:** Medium · **Effort:** M

### 2.7 — **Conform format_on_save returns `{}` when disabled** (real bug)
- **Location:** `plugins/conform.lua:89`
- **Problem:** Returning `{}` triggers formatting with default opts; should return `nil` to skip.
- **Fix:** `return` (implicit nil) or `return nil`.
- **Risk:** Medium · **Effort:** XS

### 2.8 — Unactionable TODOs in snacks picker
- **Location:** `plugins/snacks/init.lua:69,84`
- **Fix:** Triage — implement, file issue, or remove.
- **Risk:** Low · **Effort:** S

### 2.9 — none-ls zsh diagnostics
- **Location:** `plugins/none-ls.lua:25`
- **Fix:** Consider removing; zsh diagnostics quality is low and may conflict with future bash LSP.
- **Risk:** Low · **Effort:** S

### 2.10 — Commented-out sidebar in cokeline
- **Location:** `plugins/cokeline.lua:35-44`
- **Fix:** Delete dead commented block.
- **Risk:** Low · **Effort:** XS

### 2.11 — Tokyonight `"moon"` style hardcoded twice
- **Location:** `plugins/lualine.lua:5` + `plugins/tokyonight.lua:9`
- **Fix:** Extract to shared constant or read from tokyonight at runtime.
- **Risk:** Low · **Effort:** S

---

## P3 — Architectural / stylistic

### 3.1 — Leader keys duplicated in init.lua and options.lua
- **Fix:** Remove from options.lua (init.lua must set them before lazy loads).
- **Risk:** Low · **Effort:** XS

### 3.2 — Missing modern Neovim 0.11/0.12 defaults
- **Location:** `config/options.lua`
- **Fix:** Add `foldlevelstart = 99`, `jumpoptions = "view"`, fold fillchars, etc.
- **Risk:** Low · **Effort:** M

### 3.3 — `cache_dir` local in options.lua
- **Fix:** Inline `vim.fn.stdpath("cache")` or move to utils.lua.
- **Risk:** Low · **Effort:** S

### 3.4 — `keymaps.lua` is 623 lines
- **Fix:** Split into `keymaps/core.lua` + `keymaps/plugins.lua`, or push more into plugin `keys` specs.
- **Risk:** Low · **Effort:** L

### 3.5 — Treesitter `lazy = false`
- **Location:** `plugins/treesitter.lua:4`
- **Fix:** `event = { "BufReadPost", "BufNewFile" }` — test thoroughly.
- **Risk:** Medium · **Effort:** S

### 3.6 — Dashboard ASCII art hardcoded
- **Location:** `plugins/snacks/init.lua:26-32`
- **Fix:** Extract to `config/dashboard-header.lua`.
- **Risk:** Low · **Effort:** S

### 3.7 — Edgy uses `opts = function` but only mutates
- **Location:** `plugins/edgy.lua:3`
- **Fix:** Static table or `opts_extend`.
- **Risk:** Low · **Effort:** S

### 3.8 — `vim.cmd.syntax "off"` redundant with treesitter
- **Location:** `config/options.lua:40`
- **Fix:** Delete or clarify the comment.
- **Risk:** Low · **Effort:** XS

### 3.9 — Conform `*_formatters` computed at module load
- **Location:** `plugins/conform.lua:32-35`
- **Problem:** Stale across projects with different biome/prettier configs.
- **Fix:** Move to a per-format-call lookup or `formatters_by_ft` function.
- **Risk:** Medium · **Effort:** M

### 3.10 — Commented `event = 'VimEnter'` in tabby
- **Location:** `plugins/tabby.lua:3`
- **Fix:** Delete line.
- **Risk:** Low · **Effort:** XS

### 3.11 — Obsidian `vault_dir` has shell-escaped spaces
- **Location:** `plugins/obsidian.lua:1`
- **Fix:** Remove backslashes.
- **Risk:** Low · **Effort:** XS

### 3.12 — `client/registerCapability` handler uses `nvim_get_current_buf()`
- **Location:** `core/lsp.lua:130`
- **Problem:** Wrong buffer if user switched during LSP startup.
- **Fix:** Track per-client bufnr at attach time.
- **Risk:** Low · **Effort:** M

### 3.13 — Stale mix-format timeout comment
- **Location:** `plugins/conform.lua:67-71,80`
- **Fix:** Measure, decide, update comment.
- **Risk:** Low · **Effort:** S

---

## Execution order (recommended)

1. **Quick-wins pass** — 1.1, 1.3, 1.4, 1.5, 1.6, 2.3, 2.4, 2.5, 2.10, 3.1, 3.10, 3.11 (one cleanup commit).
2. **Correctness bugs** — 2.7, 1.2, 3.12.
3. **Lazy-loading audit** — 1.4, 1.5, 2.6, 3.5, 3.9.
4. **Consolidation** — 2.1, 2.2, 2.11.
5. **Architecture** — 3.4, 3.2, 3.3, 3.6, 3.7, 3.8, 3.13.

## Anti-recommendations — do NOT do these

- Do **not** remove the `vim.lsp.buf.hover`/`signature_help` wrappers in `core/lsp.lua:161-179` — noice is explicitly configured around them.
- Do **not** lazy-load tokyonight or snacks (they need `priority = 1000, lazy = false`).
- Do **not** re-add `.git` to LSP root markers.
- Do **not** centralize keymaps already expressed via plugin `keys` specs — that breaks lazy loading.

---

## Session progress log

- **Plan saved:** after P1 bundle and hotfixes shipped to `origin/master`.
- **First three bundles to execute** (this session): conform `format_on_save` bug (2.7), obsidian keymap (1.1), quick-wins omnibus.
