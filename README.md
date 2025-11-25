# Neovim

A modular and opinionated -- which is should be -- Neovim config. It's using _lazy.nvim_, modern lsp configuration, autoformatting, automatic light/dark mode... and more.

## Some features

- **Package Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim).
- **LSP & Formatting:** Full LSP support with auto-formatting.
- **LaTeX:** robust LaTeX support with [VimTeX](https://github.com/lervag/vimtex). It auto-compiles on save and opens your PDF viewer:
  - [Skim](https://skim-app.sourceforge.io/) on macOS
  - [Zathura](https://pwmt.org/projects/zathura/) on Linux/Windows
- **Theme:** [Catppuccin](https://github.com/catppuccin/nvim) that automatically syncs with your system's Light/Dark mode.
- **File Management:** [Neo-tree](https://github.com/nvim-neo-tree/neo-tree.nvim) for the visual tree structure. [Oil.nvim](https://github.com/stevearc/oil.nvim) for editing directories like buffers.
- **Git:** [LazyGit](https://github.com/jesseduffield/lazygit) integration via [Snacks.nvim](https://github.com/folke/snacks.nvim) floating window, and [Fugitive](https://github.com/tpope/vim-fugitive).
- **Shell:** Prefers [NuShell](https://www.nushell.sh/) on Windows if available.

## Prerequisites

- [Neovim](https://neovim.io/) (v0.10+)
- [Nerd Font](https://www.nerdfonts.com/) (required for icons)
- [Ripgrep](https://github.com/BurntSushi/ripgrep) (required for Telescope search)
- **GCC/Make** (required for Telescope FZF sorting)
- [Lazygit](https://github.com/jesseduffield/lazygit) (optional, for the git integration)
- **Skim** (macOS) or **Zathura** (Linux/Windows) for LaTeX preview.

## Installation

1.  **Clone this repo:**

    ```bash
    git clone https://github.com/lov3b/neovim ~/.config/nvim
    ```

2.  **Start Neovim:**
    Run `nvim`. The plugins will install themselves.

3.  **Profit?**

## Some keymaps

**Files & Navigation**

- `<leader>ff` — Find files (Telescope)
- `<leader>fg` — Live Grep (text search)
- `<leader>fe` — Toggle File Explorer (Neo-tree)
- `<leader>-` — Edit directory (Oil)
- `<leader>bp` / `<leader>bn` — Previous/Next buffer

**Coding**

- `gd` — Go to Definition
- `K` — Hover documentation
- `<leader>rn` — Rename variable (smart rename)
- `<leader>F` — Manual Format

**Git**

- `<leader>gg` — Open Lazygit (Floating)
- `<leader>gs` — Git Status (Fugitive)

**LaTeX**

- Just save the file (`:w`) to trigger compilation.
