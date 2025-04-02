# craft-ls nvim plugin

What it says on the tin.
Check [craft-ls](https://github.com/Batalex/craft-ls) for more information.

## Usage

With craft-ls installed and in PATH, use the following configuration to enable it in your neovim setup on:

### Lazyvim

```lua
return {
  {
    "paulomach/craftls.nvim",
    requires = { "neovim/nvim-lspconfig" },
    config = function()
      require("craftls").init()
      require("craftls").setup({
        on_attach = function(client, bufnr) end,
      })
    end,
  },
}
```
