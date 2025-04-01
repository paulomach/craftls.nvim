-- craft-ls.lua
-- A Neovim plugin for the Craft Language Server for *craft.yaml files

local M = {}

-- Configuration with defaults
M.setup = function(opts)
  opts = opts or {}

  -- Default configuration
  M.config = {
    cmd = opts.cmd or { "craft-ls" },
    root_dir = opts.root_dir
      or function(fname)
        -- Try to find the project root using common markers
        local util = require("lspconfig.util")
        return util.find_git_ancestor(fname)
          or util.find_node_modules_ancestor(fname)
          or util.path.dirname(fname)
      end,
    on_attach = opts.on_attach,
    capabilities = opts.capabilities,
    -- Use a filename pattern matcher for *craft.yaml files
    filetypes = { "yaml" },
    single_file_support = true,
    settings = vim.tbl_deep_extend("force", {
      craft = {
        -- Default craft-ls settings
        diagnostics = {
          enable = true,
        },
        formatting = {
          enable = true,
        },
        completion = {
          enable = true,
        },
      },
    }, opts.settings or {}),
  }

  -- Register the LSP server with Neovim
  require("lspconfig").craft_ls.setup(M.config)
end

-- Register the LSP server configuration
local configs = require("lspconfig.configs")
local util = require("lspconfig.util")

if not configs.craft_ls then
  configs.craft_ls = {
    default_config = {
      cmd = { "craft-ls" },
      filetypes = { "yaml" },
      root_dir = function(fname)
        return util.find_git_ancestor(fname) or util.path.dirname(fname)
      end,
      single_file_support = true,
      -- Only attach to files that match the pattern *craft.yaml
      autostart = false, -- We'll use a custom autocommand to start the server
      settings = {
        craft = {
          diagnostics = {
            enable = true,
          },
          formatting = {
            enable = true,
          },
          completion = {
            enable = true,
          },
        },
      },
    },
    docs = {
      description = [[
        Craft Language Server (craft-ls) for Neovim.
        https://github.com/Batalex/craft-ls

        Provides language server features for *craft.yaml files.
      ]],
      default_config = {
        root_dir = [[root_pattern(".git") or dirname]],
      },
    },
  }
end

-- Commands
function M.setup_commands()
  vim.api.nvim_create_user_command("CraftLSRestart", function()
    -- Find the client
    for _, client in ipairs(vim.lsp.get_active_clients()) do
      if client.name == "craft_ls" then
        vim.lsp.stop_client(client.id, true)
        vim.defer_fn(function()
          vim.cmd("LspStart craft_ls")
        end, 500)
        break
      end
    end
  end, {})

  vim.api.nvim_create_user_command("CraftFormat", function()
    vim.lsp.buf.format({ name = "craft_ls" })
  end, {})
end

-- Set up an autocommand to only start the LSP for *craft.yaml files
function M.setup_autocommands()
  vim.api.nvim_create_augroup("CraftLSPStart", { clear = true })
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    group = "CraftLSPStart",
    pattern = { "*craft.yaml" },
    callback = function()
      -- Check if the LSP is already running for this buffer
      local active = false
      for _, client in ipairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
        if client.name == "craft_ls" then
          active = true
          break
        end
      end

      if not active then
        vim.cmd("LspStart craft_ls")
      end
    end,
  })
end

-- Initialize everything
function M.init()
  M.setup_autocommands()
  M.setup_commands()
end

return M
