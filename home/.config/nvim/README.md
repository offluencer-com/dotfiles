# Minimal fast nvim config

## Install (Arch)

```sh
sudo pacman -S neovim git ripgrep fd unzip
# ripgrep -> telescope live_grep, fd -> faster file finding, unzip/git -> lazy.nvim / mason

mv ~/.config/nvim ~/.config/nvim.bak   # back up the old one first
git clone <this repo or wherever you host it> ~/.config/nvim
nvim
```

First launch will bootstrap `lazy.nvim` and install everything (~10s), then
`:Mason` will pull LSP servers in the background. Restart nvim once that's done.

## What's what

- `<leader>e` — toggle file tree (nvim-tree)
- `<leader>ff / fg / fb / fh / fr` — telescope: files / grep / buffers / help / recent
- `<leader>z` — zen mode (distraction-free, works anywhere but most useful in prose)
- Coding files (`.py .js .lua .rs` etc) get LSP, completion, autopairs, treesitter highlighting as normal.
- `.md`, `.tex`/`.latex`, `.txt` automatically switch to writing mode: soft wrap,
  spellcheck on, no line numbers/colorcolumn, `j`/`k` move by visual line, autopairs
  and buffer/path completion noise turned off.
- LaTeX gets `vimtex` (set `vim.g.vimtex_view_method` in `lua/plugins/writing.lua`
  to whatever PDF viewer you actually use, currently set to zathura).

## Trim it further

- `lua/plugins/lsp.lua` — the `ensure_installed` / `servers` lists have a broad
  set for "mix of languages". Delete whatever you don't use, one line each.
- `lua/plugins/treesitter.lua` — same idea, trim `ensure_installed`.
- Colors come straight from your terminal (pywal), no colorscheme plugin at all.
  If you ever want to override that, set `termguicolors = true` in
  `lua/config/options.lua` and add a `colorscheme.lua` plugin spec.

## Notes

- `mason-lspconfig` installs servers in the background on first open of a
  matching filetype — the very first coding session for each language will
  briefly lack LSP until that install finishes.
- If startup still feels slow after this, run `:Lazy profile` — it'll show
  you exactly which plugin is costing time.
