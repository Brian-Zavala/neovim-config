# 💤 LazyVim

My Neovim config, built on [LazyVim](https://github.com/LazyVim/LazyVim). It runs on native Windows 11 and on Omarchy/Arch.

## New machine

**Windows** (PowerShell):

```powershell
git clone https://github.com/Brian-Zavala/neovim-config.git $env:LOCALAPPDATA\nvim
powershell -ExecutionPolicy Bypass -File $env:LOCALAPPDATA\nvim\scripts\install-deps.ps1
# open a new terminal so PATH updates, then:
nvim
```

**Omarchy / Arch**:

```bash
git clone https://github.com/Brian-Zavala/neovim-config.git ~/.config/nvim
~/.config/nvim/scripts/install-deps.sh
nvim
```

The first start installs the plugins, then Mason's LSPs/formatters/debuggers and the treesitter parsers in the background. Give it a minute.

### Missing tools don't cause errors

You can skip the install script. Mason packages whose toolchain is missing (Go, Node/npm, python.org Python) are skipped rather than failing on every start. Those language features come back automatically once the toolchain is installed and nvim is restarted.

- `:checkhealth config` shows each toolchain, which packages were skipped and why, and how to install what's missing.
- The toolchain mapping lives in `lua/config/toolchains.lua`. The guard that applies it is `lua/plugins/zz-toolchain-guard.lua`.

### Windows notes

- Mason needs the **python.org** Python, not MSYS2's. MSYS2's builds Linux-style venvs that Mason can't use. If MSYS2's `python` comes first on PATH, `options.lua` puts `%LOCALAPPDATA%\Programs\Python\Python3*` ahead of it inside Neovim.
- The shell is `pwsh` (PowerShell 7) when it's installed. Otherwise it falls back to Windows PowerShell.

### Theme

`lua/plugins/theme.lua` is machine-local and not tracked in git:
- Omarchy symlinks it to the current theme.
- omarchy-win writes a stand-in.

When it's missing, `lua/plugins/omarchy-theme.lua` loads the Omarchy theme directly on Omarchy (and restores the symlink), or falls back to tokyonight.
