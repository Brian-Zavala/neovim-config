#!/usr/bin/env bash
# Install everything this Neovim config uses on Arch / Omarchy (pacman).
#
# Safe to re-run (--needed). Without these tools the config still starts
# cleanly (Mason skips packages whose toolchain is missing; see
# lua/config/toolchains.lua and `:checkhealth config`), you just get fewer
# features.
set -euo pipefail

if ! command -v pacman >/dev/null 2>&1; then
  echo "pacman not found. On other distros install the equivalents of:" >&2
  echo "  git neovim nodejs npm python python-pip go rustup ripgrep fd lazygit" >&2
  echo "  github-cli gcc make cmake ninja curl tar unzip tree-sitter-cli" >&2
  exit 1
fi

pkgs=(
  git neovim              # core
  base-devel              # C compiler + make: treesitter parsers, LuaSnip jsregexp
  curl tar unzip          # Mason downloads
  tree-sitter-cli         # nvim-treesitter (main) parser builds
  nodejs npm              # npm-based LSPs/formatters (vtsls, prettier, ...)
  python python-pip       # basedpyright, debugpy, sqlfluff, ...
  go                      # gopls, gofumpt, goimports, delve
  rustup                  # rust-analyzer for rustaceanvim
  ripgrep fd lazygit      # pickers, grug-far, <leader>gg
  github-cli              # octo / gh extras
  cmake ninja             # cmake-tools
  wl-clipboard            # clipboard over SSH/tmux (remote_clipboard.lua)
)

sudo pacman -S --needed --noconfirm "${pkgs[@]}"

if command -v rustup >/dev/null 2>&1; then
  rustup default >/dev/null 2>&1 || rustup default stable
  rustup component add rust-analyzer clippy rustfmt
fi

echo
echo "Done. Start nvim; the first start installs plugins, LSPs and parsers."
echo "Check with :checkhealth config"
