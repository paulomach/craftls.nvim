# craft-ls nvim plugin

What say's in the tin.
Check [craft-ls](https://github.com/Batalex/craft-ls) for more information.

## Usage

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

```

```
