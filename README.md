# Neovim

A modular and opinionated Neovim config.
It's using _lazy.nvim_, modern lsp configuration, autoformatting, automatic light/dark mode, and more.

## Features

- **Package Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim).
- **LSP & Formatting:** Full LSP support with auto-formatting.
- **LaTeX:** Robust LaTeX support with [VimTeX](https://github.com/lervag/vimtex).
  Auto-compiles on save and opens your PDF viewer (Skim on macOS & Zathura on Linux).
- **Theme:** [Catppuccin](https://github.com/catppuccin/nvim) that automatically
  syncs with your system's Light/Dark mode.
- **File Management:** [Snacks.nvim](https://github.com/folke/snacks.nvim)
  Explorer for the visual tree structure.
  [Oil.nvim](https://github.com/stevearc/oil.nvim) for editing directories like buffers.
- **Fuzzy Finder:** [Snacks.nvim](https://github.com/folke/snacks.nvim)
  Picker for finding files, grep, and LSP symbols.
- **Git:** [LazyGit](https://github.com/jesseduffield/lazygit) integration,
  and [Fugitive](https://github.com/tpope/vim-fugitive).
- **Shell:** Prefers [NuShell](https://www.nushell.sh/) on Windows if available.
- **Remaps:** Ctrl+j & Ctrl+k mapped to Escape.

## Installer Script

Included is a `nvim-installer.py` script to easily install or upgrade Neovim from GitHub Releases.
This isn't recommended if your distrobution is providing a recent neovim version.

**Usage:**

```bash
sudo python3 nvim-installer.py
```

- **Installs to:** `/opt/nvim`
- **Symlink:** `/usr/local/bin/nvim`
- **Requirements:** Python 3, `sudo` access.

## Prerequisites

- [Neovim](https://neovim.io/) (has to be recent)
- [Nerd Font](https://www.nerdfonts.com/) (required for icons)
- [Ripgrep](https://github.com/BurntSushi/ripgrep) (required for live grepping)
- **Python 3** (required for the installer script)
- [Lazygit](https://github.com/jesseduffield/lazygit)
- **Skim** (macOS) or **Zathura** (Linux) for LaTeX preview.

## Installation

1.  **Clone this repo:**

    ```bash
    git clone https://github.com/lov3b/neovim ~/.config/nvim
    ```

2.  **Start Neovim:**
    Run `nvim`. The plugins will install themselves.

## Keymaps

**Files & Navigation**

- `<leader>ff` — Find files
- `<leader>fg` — Live Grep
- `<leader>fe` — Toggle Explorer
- `<leader>-` — Edit directory
- `<leader>bp` / `<leader>bn` — Previous/Next buffer

**Coding & LSP**

- `gd` — Go to Definition
- `gr` — Go to References
- `K` — Hover documentation
- `<leader>rn` — Rename a variable with the LSP
- `<leader>F` — Manual Format

**Git**

- `<leader>gg` — Open Lazygit (Floating)
- `<leader>gs` — Git Status (Fugitive)

**LaTeX**

- Just save the file (`:w`) to trigger compilation.

## Remap caps and control (recommended)

### macOS

**Remap:**

```bash
hidutil property --set '{
  "UserKeyMapping": [
    {
      "HIDKeyboardModifierMappingSrc": 0x700000039,
      "HIDKeyboardModifierMappingDst": 0x7000000E0
    },
    {
      "HIDKeyboardModifierMappingSrc": 0x7000000E0,
      "HIDKeyboardModifierMappingDst": 0x700000039
    }
  ]
}'
```

**Reset:**

```bash
hidutil property --set '{"UserKeyMapping":[]}'
```
