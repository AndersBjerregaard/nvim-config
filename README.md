# Roslyn Analyzer

The roslyn analyzer nuget package for linux x64 is in the root directory of this repository through git large file store.

Alternatively, a different package - or more recent version - can be downloaded directly from the official roslyn repository's pipeline published artifacts:

https://dev.azure.com/dnceng-public/public/_build?definitionId=95

Click on the "* published* artifacts. And download the "Bootstrap Packages - Default" artifacts.

The `.nupkg` is just a compressed folder. It can be extracted with tools like `unzip` or `7z`.

It is recommended to extract the contents into a folder like `~/.local/share/roslyn-ls/`.

The compiled lsp is then located at a location like `~/.local/share/roslyn-ls/tools/net10.0/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll`.

You need to run it with the `dotnet` cli.

You can verify that it's working with a command like:

```bash
dotnet ~/.local/share/roslyn-ls/tools/net10.0/linux-x64/Microsoft.CodeAnalysis.LanguageServer.dll --version
```

# Installation

To properly get the personalized files of this configuration. Make sure you've backed up & removed existing personalized files:

```
rm -rfv ~/.config/nvim
```

Then copy the config folders from this working directory:

```
cp -rv ./.config ~
```
