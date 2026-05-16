#!/bin/bash
set -euo pipefail

# ─────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────

info()    { printf '\e[1;34m::\e[0m %s\n' "$*"; }
success() { printf '\e[1;32m✓\e[0m  %s\n' "$*"; }
skip()    { printf '\e[1;33m–\e[0m  %s (already done, skipping)\n' "$*"; }
die()     { printf '\e[1;31mERROR:\e[0m %s\n' "$*" >&2; exit 1; }

require_cmd() {
    command -v "$1" &>/dev/null || die "Required command '$1' not found. Please install it first."
}

# Collect PATH entries to print at the end
PATH_ENTRIES=()

# ─────────────────────────────────────────────
# 1. NeoVim
# ─────────────────────────────────────────────

install_neovim() {
    info "NeoVim: checking installation"

    local target="/opt/nvim-linux-x86_64"
    local tarball="nvim-linux-x86_64.tar.gz"
    local url="https://github.com/neovim/neovim/releases/download/v0.12.1/${tarball}"
    local tmpfile
    tmpfile="$(mktemp --suffix=".tar.gz")"

    require_cmd curl
    require_cmd sudo

    info "NeoVim: downloading latest release"
    curl -L --progress-bar -o "$tmpfile" "$url"

    info "NeoVim: removing existing installation at ${target}"
    sudo rm -rf "$target"

    info "NeoVim: extracting to /opt"
    sudo tar -C /opt -xzf "$tmpfile"
    rm -f "$tmpfile"

    success "NeoVim installed to ${target}"
    PATH_ENTRIES+=("/opt/nvim-linux-x86_64/bin")
}

install_neovim

# ─────────────────────────────────────────────
# 2. Roslyn (C#) LSP
# ─────────────────────────────────────────────

install_roslyn() {
    info "Roslyn: checking .NET SDK"

    if ! command -v dotnet &>/dev/null; then
        info "Roslyn: installing dotnet-sdk-10.0 via apt"
        sudo apt-get update -qq
        sudo apt-get install -y dotnet-sdk-10.0
    else
        skip "Roslyn: dotnet already available ($(dotnet --version))"
    fi

    # Ensure dotnet tools path exists
    mkdir -p "$HOME/.dotnet/tools"

    if command -v roslyn-language-server &>/dev/null \
       || [ -f "$HOME/.dotnet/tools/roslyn-language-server" ]; then
        skip "Roslyn: roslyn-language-server already installed"
    else
        info "Roslyn: updating packages"
        sudo apt-get update -qq
        info "Roslyn: installing roslyn-language-server dotnet tool"
        # Temporarily add dotnet tools to PATH for this session
        export PATH="$PATH:$HOME/.dotnet/tools"
        dotnet tool install --global roslyn-language-server --prerelease
        success "Roslyn: roslyn-language-server installed"
    fi

    local wrapper="$HOME/.local/bin/Microsoft.CodeAnalysis.LanguageServer"
    mkdir -p "$HOME/.local/bin"

    if [ -x "$wrapper" ]; then
        skip "Roslyn: wrapper script already exists at ${wrapper}"
    else
        info "Roslyn: creating wrapper script at ${wrapper}"
        cat > "$wrapper" <<'EOF'
#!/bin/bash
roslyn-language-server "$@"
EOF
        chmod +x "$wrapper"
        success "Roslyn: wrapper script created"
    fi

    PATH_ENTRIES+=("\$HOME/.dotnet/tools")
    PATH_ENTRIES+=("\$HOME/.local/bin")
}

install_roslyn

# ─────────────────────────────────────────────
# 3. Lua LSP
# ─────────────────────────────────────────────

install_lua_ls() {
    local version="3.18.0"
    local install_dir="$HOME/.local/share/lua-language-server"
    local binary="${install_dir}/bin/lua-language-server"

    info "Lua LSP: checking installation"

    if [ -x "$binary" ]; then
        skip "Lua LSP: lua-language-server already present at ${binary}"
    else
        require_cmd curl

        local tarball="lua-language-server-${version}-linux-x64.tar.gz"
        local url="https://github.com/LuaLS/lua-language-server/releases/download/${version}/${tarball}"
        local tmpfile
        tmpfile="$(mktemp --suffix=".tar.gz")"

        info "Lua LSP: downloading lua-language-server ${version}"
        curl -L --progress-bar -o "$tmpfile" "$url"

        mkdir -p "$install_dir"
        info "Lua LSP: extracting to ${install_dir}"
        tar -C "$install_dir" -xzf "$tmpfile"
        rm -f "$tmpfile"

        success "Lua LSP: installed to ${install_dir}"
    fi

    PATH_ENTRIES+=("\$HOME/.local/share/lua-language-server/bin")
}

install_lua_ls

# ─────────────────────────────────────────────
# 4. Bash LSP (shellcheck + Node.js)
# ─────────────────────────────────────────────

install_bash_ls() {
    info "Bash LSP: checking shellcheck"

    if command -v shellcheck &>/dev/null; then
        skip "Bash LSP: shellcheck already installed"
    else
        info "Bash LSP: installing shellcheck via apt"
        sudo apt-get install -y shellcheck
        success "Bash LSP: shellcheck installed"
    fi

    local node_version="24.14.1"
    local node_dir="$HOME/.local/share/node"
    local node_binary="${node_dir}/node-v${node_version}-linux-x64/bin/node"

    info "Bash LSP: checking Node.js"

    if [ -x "$node_binary" ]; then
        skip "Bash LSP: Node.js ${node_version} already present"
    else
        require_cmd curl

        local tarball="node-v${node_version}-linux-x64.tar.xz"
        local url="https://nodejs.org/dist/v${node_version}/${tarball}"
        local tmpfile
        tmpfile="$(mktemp --suffix=".tar.xz")"

        info "Bash LSP: downloading Node.js ${node_version}"
        curl -L --progress-bar -o "$tmpfile" "$url"

        mkdir -p "$node_dir"
        info "Bash LSP: extracting to ${node_dir}"
        tar -C "$node_dir" -xf "$tmpfile"
        rm -f "$tmpfile"

        success "Bash LSP: Node.js installed to ${node_dir}"
    fi

    PATH_ENTRIES+=("\$HOME/.local/share/node/node-v${node_version}-linux-x64/bin")
}

install_bash_ls

# ─────────────────────────────────────────────
# 5. Rust
# ─────────────────────────────────────────────

install_rust() {
    info "Rust: Checking for rustup"
    if command -v rustup &>/dev/null; then
        skip "Rust: rustup already available"
    else
        info "Rust: installing rustup via script"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        success "Rust: rustup installed"
    fi
    info "Rust: Checking for rust-analyzer"
    if command -v rust-analyzer &>/dev/null; then
        skip "Rust: rust-analyzer already available"
    else
        info "Rust: installing rust-analyzer via rustup"
        rustup component add rust-analyzer
        success "Rust: rust-analyzer installed"
    fi
    info "Installing cargo binstall via script"
    curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
}

install_rust

# ─────────────────────────────────────────────
# 6. Treesitter dependency: tree-sitter cli
# ─────────────────────────────────────────────

install_tree_sitter() {
    info "Treesitter: checking for tree-sitter"
    if command -v tree-sitter &>/dev/null; then
        skip "Treesitter: tree-sitter already available"
    else
        info "Treesitter: installing tree-sitter via cargo binstall"
        cargo binstall tree-sitter-cli
    fi
}

install_tree_sitter

# ─────────────────────────────────────────────
# 7. Treesitter dependency: C compiler (cc)
# ─────────────────────────────────────────────

install_cc() {
    info "Treesitter: checking for C compiler (cc)"

    if command -v cc &>/dev/null; then
        skip "Treesitter: cc already available"
    else
        info "Treesitter: installing clang via apt"
        sudo apt-get install -y clang
        success "Treesitter: clang installed"
    fi
}

install_cc

# ─────────────────────────────────────────────
# 8. Telescope dependency: ripgrep
# ─────────────────────────────────────────────

install_ripgrep() {
  info "Telescope: checking for ripgrep dependency"

  if command -v rg &>/dev/null; then
    skip "Telescope: ripgrep already available"
  else
    info "Telescope: installing ripgrep via apt"
    sudo apt-get install -y ripgrep
    success "Telescope: ripgrep installed"
  fi
}

install_ripgrep

# ─────────────────────────────────────────────
# 9. Vue, Svelte & TypeScript language servers
# ─────────────────────────────────────────────

install_vue_typescript() {
  local node_version="24.14.1"
  local node_dir="$HOME/.local/share/node"
  local npm_binary="${node_dir}/node-v${node_version}-linux-x64/bin/npm"

  info "Vue, Svelte & TypeScript: installing / updating Vue & TypeScript language servers"

  $npm_binary install -g typescript typescript-language-server @vtsls/language-server @vue/language-server svelte-language-server

  success "Vue & TypeScript language servers installed"
}

install_vue_typescript

# ─────────────────────────────────────────────
# 10. Python language server
# ─────────────────────────────────────────────

install_python() {
  info "Python: Installing python through apt"
  sudo apt-get update
  sudo apt-get install -y python3 python3-pip python3-venv
  info "Python: Installing python lsp through pip"
  pip install --break-system-packages python-lsp-server
  success "Python: Python and python lsp installed"
}

install_python

# ─────────────────────────────────────────────
# 11. Terraform language server
# ─────────────────────────────────────────────

install_terraform() {
    info "Terraform: checking installation"
    if ! command -v terraform-ls &>/dev/null; then

        require_cmd unzip

        info "Terraform: downloading terraform-ls_0.38.6_linux_amd64"

        local zipfile="terraform-ls_0.38.6_linux_amd64.zip"
        local url="https://releases.hashicorp.com/terraform-ls/0.38.6/${zipfile}"
        local tmpfile
        tmpfile="$(mktemp --suffix=".zip")"

        curl -L --progress-bar -o "$tmpfile" "$url"

        info "Extracing to /usr/local/bin"

        sudo unzip "$tmpfile" -d "/usr/local/bin" -x "LICENSE.txt"

        rm -f "$tmpfile"

        success "Terraform language server installed to /usr/local/bin"
    else
        success "Terraform already installed"
    fi

    if ! command -v tflint &>/dev/null; then
        require_cmd unzip
        info "Terraform: Downloading tflint_linux_amd64.zip"
        local version="0.62.0"
        local zipfile="tflint_linux_amd64.zip"
        local url="https://github.com/terraform-linters/tflint/releases/download/v${version}/${zipfile}"
        local tmpfile
        tmpfile="$(mktemp --suffix=".zip")"
        curl -L --progress-bar -o "$tmpfile" "$url"
        info "Extracing to /usr/local/bin"
        sudo unzip "$tmpfile" -d "/usr/local/bin"
        rm -f "$tmpfile"
        success "Terraform linter installed to /usr/local/bin"
    else
        success "Terraform linter already installed"
    fi
}

install_terraform

# ─────────────────────────────────────────────
# 11. Apply NeoVim config
# ─────────────────────────────────────────────

apply_config() {
    local config_dir="$HOME/.config/nvim"
    local source_file
    # Resolve relative to the script's own directory so it works from any CWD
    source_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/nvim/init.lua"

    [ -f "$source_file" ] || die "Could not find nvim/init.lua relative to this script"

    info "Config: ensuring ${config_dir} exists"
    mkdir -p "$config_dir"

    info "Config: copying init.lua to ${config_dir}/"
    cp "$source_file" "$config_dir/init.lua"
    success "Config: init.lua installed to ${config_dir}/init.lua"
}

apply_config

# ─────────────────────────────────────────────
# 12. Summary: PATH entries to add
# ─────────────────────────────────────────────

printf '\n'
info "Done! Add the following entries to your shell config (e.g. ~/.bashrc or ~/.zshrc):"
printf '\n'
for entry in "${PATH_ENTRIES[@]}"; do
    printf '    export PATH="$PATH:%s"\n' "$entry"
done
printf '\n'

