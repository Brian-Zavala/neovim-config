<#
.SYNOPSIS
  Install everything this Neovim config uses on Windows (winget).

.DESCRIPTION
  Safe to re-run: anything already on PATH is skipped. Without these tools
  the config still starts cleanly (Mason skips packages whose toolchain is
  missing; see lua/config/toolchains.lua and `:checkhealth config`), you
  just get fewer features.

.EXAMPLE
  pwsh -File scripts/install-deps.ps1
  powershell -ExecutionPolicy Bypass -File scripts\install-deps.ps1 -WhatIf
#>
[CmdletBinding(SupportsShouldProcess)]
param()

$ErrorActionPreference = 'Stop'

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  throw 'winget not found. Install "App Installer" from the Microsoft Store, then re-run.'
}

# Id, command that proves it's installed, extra winget args, why
$packages = @(
  @{ Id = 'Git.Git';                          Cmd = 'git';        Why = 'plugin manager (lazy.nvim)' }
  @{ Id = 'Neovim.Neovim';                    Cmd = 'nvim';       Why = 'Neovim itself' }
  @{ Id = 'Microsoft.PowerShell';             Cmd = 'pwsh';       Why = ':terminal / :! shell' }
  @{ Id = 'OpenJS.NodeJS.LTS';                Cmd = 'npm';        Why = 'npm-based LSPs/formatters (vtsls, prettier, ...)' }
  # Per-user python.org install; options.lua puts it ahead of MSYS2's python.
  @{ Id = 'Python.Python.3.13';               Cmd = $null;        Why = 'Python LSP/debugger (basedpyright, debugpy)'; Args = @('--scope', 'user') }
  @{ Id = 'GoLang.Go';                        Cmd = 'go';         Why = 'Go tools (gopls, gofumpt, delve)' }
  @{ Id = 'Rustlang.Rustup';                  Cmd = 'rustup';     Why = 'Rust (rustaceanvim needs rust-analyzer)' }
  @{ Id = 'BurntSushi.ripgrep.MSVC';          Cmd = 'rg';         Why = 'grep pickers, grug-far' }
  @{ Id = 'sharkdp.fd';                       Cmd = 'fd';         Why = 'file pickers' }
  @{ Id = 'JesseDuffield.lazygit';            Cmd = 'lazygit';    Why = '<leader>gg' }
  @{ Id = 'GitHub.cli';                       Cmd = 'gh';         Why = 'octo / gh extras' }
  # The C compiler LazyVim recommends for building treesitter parsers.
  @{ Id = 'BrechtSanders.WinLibs.POSIX.UCRT'; Cmd = 'gcc';        Why = 'C compiler for treesitter parsers, C++ builds' }
  @{ Id = 'Kitware.CMake';                    Cmd = 'cmake';      Why = 'cmake-tools' }
  @{ Id = 'Ninja-build.Ninja';                Cmd = 'ninja';      Why = 'cmake-tools generator' }
)

function Test-PythonOrg {
  # MSYS2's python doesn't count (Mason can't use its venvs).
  Test-Path "$env:LOCALAPPDATA\Programs\Python\Python3*\python.exe"
}

$installed = @()
foreach ($p in $packages) {
  $have = if ($p.Cmd) { [bool](Get-Command $p.Cmd -ErrorAction SilentlyContinue) } else { Test-PythonOrg }
  if ($have) {
    Write-Host ("  ok       {0,-34} {1}" -f $p.Id, $p.Why) -ForegroundColor DarkGray
    continue
  }
  if ($PSCmdlet.ShouldProcess($p.Id, 'winget install')) {
    Write-Host ("  install  {0,-34} {1}" -f $p.Id, $p.Why) -ForegroundColor Cyan
    $wingetArgs = @('install', '--id', $p.Id, '-e', '--silent', '--accept-source-agreements', '--accept-package-agreements') + @($p.Args | Where-Object { $_ })
    & winget @wingetArgs
    if ($LASTEXITCODE -ne 0) {
      Write-Warning "winget install $($p.Id) failed (exit $LASTEXITCODE); continuing"
    } else {
      $installed += $p.Id
    }
  }
}

# Pick up PATH changes from the installers for the rest of this script.
$env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')

if (Get-Command rustup -ErrorAction SilentlyContinue) {
  if ($PSCmdlet.ShouldProcess('rust-analyzer, clippy, rustfmt', 'rustup component add')) {
    & rustup component add rust-analyzer clippy rustfmt
  }
}

Write-Host ''
if ($WhatIfPreference) {
  Write-Host 'Dry run: nothing was installed.'
} elseif ($installed.Count) {
  Write-Host "Installed: $($installed -join ', ')" -ForegroundColor Green
  Write-Host 'Open a NEW terminal so PATH changes apply, then start nvim.'
} else {
  Write-Host 'Everything is already installed.' -ForegroundColor Green
}
Write-Host 'First nvim start installs plugins, LSPs and parsers; check with :checkhealth config'
