# Installation

This is only maintained for the latest version of NeoVim and Debian/Ubuntu systems.

## NeoVim 0.12.1

Download the latest pre-built binary for linux:

```bash
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.1/nvim-linux-x86_64.tar.gz
```

Remove existing installation:

```bash
sudo rm -rf /opt/nvim-linux-x86_64
```

Extract:

```bash
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
```

Add folder with executable to PATH in shell config (~/.bashrc, ~/.zshrc, ...):

```bash
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
```

## Language Server Protocol Servers (LSP)

The config does not come with any packages language servers. They need to exist on the machine already,
while the neovim lsp configuration attempts to interact with them.

### Roslyn (C#)

Install .NET 10 SDK.
On Ubuntu version 24.04 or later, it is now an integral part of the ubuntu package registry:

```bash
sudo apt-get update && sudo apt-get install -y dotnet-sdk-10.0
```

Ensure that the dotnet tools is part of the PATH in your shell config:

```bash
export PATH="$PATH:$HOME/.dotnet/tools"
```

Install official roslyn language server:

```bash
dotnet tool install --global roslyn-language-server
```

The lua roslyn lsp configuration still wants an executable with the name of 'Microsoft.CodeAnalysis.LanguageServer'
available on PATH.

Create a wrapper script executable that's part of your PATH (e.g. ~/.local/bin):

```bash
touch ~/.local/bin/Microsoft.CodeAnalysis.LanguageServer
```

Write the following content in the file:

```bash
#!/bin/bash
roslyn-language-server $@

```

Make executable:

```bash
chmod +x ~/.local/bin/Microsoft.CodeAnalysis.LanguageServer
```

### Lua

Download language server binary:

```bash
curl -LO https://github.com/LuaLS/lua-language-server/releases/download/3.18.0/lua-language-server-3.18.0-linux-x64.tar.gz
```

Ensure directory exists for target extraction:

```bash
mkdir ~/.local/share/lua-language-server
```

Extract:

```bash
tar -C ~/.local/share/lua-language-server -xzf lua-language-server-3.18.0-linux-x64.tar.gz
```

Make sure the executable folder exists in the PATH of your shell config:

```bash
export PATH="$PATH:$HOME/.local/share/lua-language-server/bin"
```

### Bash

Install the `shellcheck` binary, which is the core functionality behind the language server:

```bash
sudo apt install -y shellcheck
```

For some god awful reason, the language server was implemented using typescript.
And the lsp config interacts with it using node.

Download standalone binary:

```bash
curl -LO https://nodejs.org/dist/v24.14.1/node-v24.14.1-linux-x64.tar.xz
```

Ensure directory exists for target extraction:

```bash
mkdir ~/.local/share/node
```

Extract:

```bash
tar -C ~/.local/share/node -xf node-v24.14.1-linux-x64.tar.xz
```

Make sure the executable folder exists in the PATH of your shell config:

```bash
export PATH="$PATH:$HOME/.local/share/node/bin"
```

## Treesitter

Treesitter needs a C compiler available on PATH. As of writing this, this specifically needs to be `cc` on Linux systems.

This can be easily be done by just installing `clang` from the ubuntu package registry:

```bash
sudo apt install -y clang
```

## Telescope

Telescope needs `ripgrep` to be able to text search

```bash
sudo apt install -y ripgrep
```

## Vue

Vue language server can be installed globally through npm:

```bash
npm install -g @vue/language-server
```

The language server only supports Vue 3 projects by default. For Vue 2 projects,
[additional configuration](https://github.com/vuejs/language-tools/blob/master/extensions/vscode/README.md?plain=1#L19) are required.

The Vue language server works in "hybrid mode" that exclusively manages the CSS/HTML sections. You need the `vtsls` server with `@vue/typescript-plugin`
plugin to support TypeScript in `.vue` files. See `vtsls` section and
https://github.com/vuejs/language-tools/wiki/Neovim for more information.

## Typescript

Install TypeScript, TypeScript language server and TypeScript Vue language server:

```bash
npm install -g typescript typescript-language-server @vtsls/language-server
```

*Tip: If you installed node as its standalone binary in your home directory, like this repository recommended,
you can find globally installed npm packages at: `~/.local/share/node/`.

## Apply Config

*At the root of the repository directory*.

Remove any existing configuration (make sure to back these files up if you want):

```bash
rm -rf ~/.config/nvim/*
```

Copy config:

```bash
cp nvim/init.lua ~/.config/nvim/
```

