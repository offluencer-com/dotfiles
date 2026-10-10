# Neovim Config Cheatsheet

Leader key: `<Space>` (mapleader and maplocalleader are both Space).

---

## 1. Coding Workflow

### Startup & plugin management
- `:Lazy` — plugin status, updates, `:Lazy profile` to check startup time
- `:Mason` — install/remove/inspect LSP servers manually
- `:checkhealth` — general diagnostics if something misbehaves

### Opening a project
```sh
cd ~/your-project && nvim .
```
`<leader>e` toggles the file tree (nvim-tree) on the left.

Inside the tree:
| Key | Action |
|---|---|
| `Enter` / `o` | open file/folder |
| `a` | create file/folder |
| `d` | delete |
| `r` | rename |
| `x` | cut |
| `p` | paste |
| `y` | copy name |

Git status (modified/new/staged) is shown automatically if the project has `git init`.

### Finding things — Telescope
| Key | Action |
|---|---|
| `<leader>ff` | find files by name |
| `<leader>fg` | live grep (needs `ripgrep`: `sudo pacman -S ripgrep`) |
| `<leader>fb` | switch between open buffers |
| `<leader>fh` | search Neovim help docs |
| `<leader>fr` | recently opened files |

**Inside any Telescope picker**, before pressing Enter:
| Key | Action |
|---|---|
| `<C-v>` | open selection in a vertical split |
| `<C-x>` | open selection in a horizontal split |
| `<C-t>` | open selection in a new tab |

### Windows vs tabs vs buffers
- **Buffer** = an open file in memory (visible or not)
- **Window/split** = a visible pane showing a buffer
- **Tab** (real Vim tab) = a whole separate layout of splits — rarely used here; buffers + splits cover almost everything

Splits use native Vim commands (no custom keybind):
| Command / Key | Action |
|---|---|
| `:vsplit` / `:vs` | split vertically |
| `:split` / `:sp` | split horizontally |
| `<C-h/j/k/l>` | move between splits (custom mapped) |
| `<C-w>q` or `:q` | close current split |
| `<C-w>=` | equalize split sizes |

### LSP
Attaches automatically based on filetype.
| Key | Action |
|---|---|
| `K` | hover docs |
| `gd` | go to definition (Telescope picker) |
| `gr` | find references |
| `gi` | go to implementation |
| `<leader>rn` | rename symbol project-wide |
| `<leader>ca` | code actions |
| `<leader>d` | full diagnostic message for current line |
| `<leader>ds` | document symbols |
| `<leader>ws` | workspace symbols |

Diagnostics show inline as virtual text + gutter signs automatically. Jumping between them (`]d`/`[d`) isn't mapped yet — ask if you want it added.

### Completion (insert mode)
| Key | Action |
|---|---|
| `<Tab>` / `<S-Tab>` | next / previous suggestion |
| `<Enter>` | accept |
| `<C-Space>` | force-trigger manually |

### Other coding tools
- `gcc` — comment/uncomment current line
- `gc` + motion (e.g. `gcap`) — comment a block
- Brackets/quotes auto-close as you type
- Gitsigns shows `+`/`~`/`-` in the gutter for uncommitted changes (hunk-stage/preview keymaps not set up yet)
- `<leader>t` or `` Ctrl+` `` — toggle terminal at the bottom

---

## 2. Writing Workflow

### What triggers it
Automatic on opening any `.md`, `.tex` / `.latex`, or `.txt` file — no manual toggle.

### What changes automatically
- Soft-wrap at word boundaries (no sideways scroll, no mid-word breaks)
- Spellcheck on (`en_us`)
  - `z=` — suggestions for word under cursor
  - `]s` / `[s` — jump to next/previous misspelled word
  - `zg` — add word to dictionary permanently
- `j` / `k` move by **visual** line, not logical line (natural navigation through wrapped paragraphs)
- Line numbers and sign column hidden
- Buffer/path completion noise turned off (LSP completions from `marksman`/`texlab` still work — headings, citation keys, etc.)

### Zen mode (manual)
`<leader>z` or `:ZenMode` — centers text in a fixed-width column, dims everything outside the current paragraph via Twilight. Toggle again to leave.

### Markdown extras
- `render-markdown.nvim` — always on for `.md`: headers, bold/italic, lists render visually inline as you type, no preview pane needed
- `vim-table-mode` — `:TableModeToggle` (default `<leader>tm`), then typing `|` auto-aligns table columns

### LaTeX (vimtex)
Since `maplocalleader` = Space here too, vimtex's default mappings become:
| Key | Action |
|---|---|
| `<leader>ll` | compile (continuous/watch mode via `latexmk`; run again to stop) |
| `<leader>lv` | open compiled PDF in Zathura, with forward search |
| `<leader>lc` | clean aux/log files |
| `<leader>lt` | table of contents / outline |

For a one-off compile without watch mode: open a terminal (`<leader>t`) and run `latexmk yourfile.tex` directly.

### Exporting to PDF
- **LaTeX → PDF**: native, via `<leader>ll` / `<leader>lv` above.
- **Markdown/plain text → PDF**: not wired into the editor yet. Use `pandoc`:
  ```sh
  sudo pacman -S pandoc texlive-core   # texlive gives pandoc a PDF engine
  pandoc mynovel.md -o mynovel.pdf
  ```
  A `:Export` command that shells out to this automatically can be added — just ask.

### Structuring longer writing (e.g. a novel)
- One file per chapter (`chapters/01-arrival.md`, `chapters/02-departure.md`, ...), navigated via the tree/Telescope rather than one giant file
- Use `#` / `##` markdown headers for scene/section breaks — `render-markdown` gives visual hierarchy for free
- For LaTeX manuscripts: a `main.tex` pulling in chapters via `\input{chapters/ch1}` — vimtex auto-detects the main file project-wide, so compiling/viewing works from inside any chapter file
- Draft inside zen mode (`<leader>z`) for a session, exit it to reorganize/navigate between files

---

## Quick reference: all custom keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>e` | n | Toggle file tree |
| `<leader>ff` | n | Telescope: find files |
| `<leader>fg` | n | Telescope: live grep |
| `<leader>fb` | n | Telescope: buffers |
| `<leader>fh` | n | Telescope: help tags |
| `<leader>fr` | n | Telescope: recent files |
| `<C-h/j/k/l>` | n | Move between windows |
| `<leader>w` | n | Save |
| `<leader>q` | n | Quit |
| `<Esc>` | n | Clear search highlight |
| `J` / `K` | v | Move selected lines down/up |
| `<leader>z` | n | Toggle Zen mode |
| `<leader>t` / `` <C-`> `` | n | Toggle terminal |
| `gd` | n | Go to definition |
| `gr` | n | Find references |
| `gi` | n | Go to implementation |
| `K` | n | Hover docs |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n | Code action |
| `<leader>d` | n | Line diagnostics |
| `<leader>ds` | n | Document symbols |
| `<leader>ws` | n | Workspace symbols |
| `gcc` / `gc`+motion | n/v | Comment toggle |
