return {
  "nvim-neo-tree/neo-tree.nvim",
  -- Neo-tree is the file explorer: selected via `vim.g.lazyvim_explorer`
  -- in options.lua, so the `editor.neo-tree` extra owns all explorer keys.
  -- Snacks explorer stays disabled (disable-snacks-explorer.lua).
  opts = {
    filesystem = {
      use_libuv_file_watcher = true, -- auto-refresh when files change
      hijack_netrw_behavior = "open_current", -- prevent netrw from opening
    },
    window = {
      mappings = {
        ["<space>"] = "none", -- disable space mapping that might conflict
      },
    },
    event_handlers = {
      -- ═══════════════════════════════════════════════════════════════════
      -- LSP File Rename: Update imports when renaming/moving files
      -- Only prompts when the LSP supports willRenameFiles capability
      -- ═══════════════════════════════════════════════════════════════════
      {
        event = "file_renamed",
        handler = function(args)
          local source = args.source
          local destination = args.destination

          -- Check if any attached LSP client supports willRenameFiles
          local clients = vim.lsp.get_clients()
          local supported_client = nil

          for _, client in ipairs(clients) do
            if
              client.server_capabilities.workspace
              and client.server_capabilities.workspace.fileOperations
              and client.server_capabilities.workspace.fileOperations.willRename
            then
              supported_client = client
              break
            end
          end

          if supported_client then
            -- Prompt user since LSP can update imports
            vim.ui.select({ "Yes", "No" }, {
              prompt = "Update imports for renamed file?",
            }, function(choice)
              if choice == "Yes" then
                -- Send willRenameFiles request to LSP
                local params = {
                  files = {
                    {
                      oldUri = vim.uri_from_fname(source),
                      newUri = vim.uri_from_fname(destination),
                    },
                  },
                }

                local result = supported_client.request_sync("workspace/willRenameFiles", params, 5000)
                if result and result.result then
                  vim.lsp.util.apply_workspace_edit(result.result, supported_client.offset_encoding)
                  vim.notify("Imports updated!", vim.log.levels.INFO)
                end
              end
            end)
          end
          -- If no LSP supports it, silently do nothing (no prompt)
        end,
      },
      {
        event = "file_moved",
        handler = function(args)
          local source = args.source
          local destination = args.destination

          -- Check if any attached LSP client supports willRenameFiles
          local clients = vim.lsp.get_clients()
          local supported_client = nil

          for _, client in ipairs(clients) do
            if
              client.server_capabilities.workspace
              and client.server_capabilities.workspace.fileOperations
              and client.server_capabilities.workspace.fileOperations.willRename
            then
              supported_client = client
              break
            end
          end

          if supported_client then
            -- Prompt user since LSP can update imports
            vim.ui.select({ "Yes", "No" }, {
              prompt = "Update imports for moved file?",
            }, function(choice)
              if choice == "Yes" then
                -- Send willRenameFiles request to LSP
                local params = {
                  files = {
                    {
                      oldUri = vim.uri_from_fname(source),
                      newUri = vim.uri_from_fname(destination),
                    },
                  },
                }

                local result = supported_client.request_sync("workspace/willRenameFiles", params, 5000)
                if result and result.result then
                  vim.lsp.util.apply_workspace_edit(result.result, supported_client.offset_encoding)
                  vim.notify("Imports updated!", vim.log.levels.INFO)
                end
              end
            end)
          end
          -- If no LSP supports it, silently do nothing (no prompt)
        end,
      },
    },
  },
}
