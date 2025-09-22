-- HTML/CSS/Emmet LSP Configuration for LazyVim
return {
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Setup capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()

      -- Enable snippet support
      capabilities.textDocument.completion.completionItem.snippetSupport = true
      capabilities.textDocument.completion.completionItem.resolveSupport = {
        properties = { "documentation", "detail", "additionalTextEdits" }
      }

      -- Get blink capabilities if available
      local has_blink, blink = pcall(require, "blink.cmp")
      if has_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      opts.servers = opts.servers or {}

      -- HTML Language Server
      opts.servers.html = {
        cmd = { "vscode-html-language-server", "--stdio" },
        filetypes = { "html", "htm", "shtml", "xhtml" },
        init_options = {
          configurationSection = { "html", "css", "javascript" },
          embeddedLanguages = {
            css = true,
            javascript = true
          },
          provideFormatter = true
        },
        settings = {
          html = {
            customData = {
              vim.fn.expand("~/.config/nvim/lua/plugins/html-custom-data.json")
            },
            format = {
              enable = true,
              wrapLineLength = 120,
              unformatted = "wbr",
              contentUnformatted = "pre,code,textarea",
              indentInnerHtml = true,
              preserveNewLines = true,
              maxPreserveNewLines = 2,
              indentHandlebars = true,
              endWithNewline = false,
              extraLiners = "head, body, /html",
              wrapAttributes = "auto",
              templating = true,
              unformattedContentDelimiter = ""
            },
            suggest = {
              html5 = true
            },
            validate = {
              scripts = true,
              styles = true
            },
            hover = {
              documentation = true,
              references = true
            },
            completion = {
              attributeDefaultValue = "doublequotes"
            },
            autoClosingTags = true
          }
        },
        capabilities = capabilities
      }

      -- CSS Language Server
      opts.servers.cssls = {
        cmd = { "vscode-css-language-server", "--stdio" },
        filetypes = { "css", "scss", "less" },
        settings = {
          css = {
            validate = true,
            completion = {
              completePropertyWithSemicolon = true,
              triggerPropertyValueCompletion = true
            }
          },
          scss = {
            validate = true
          },
          less = {
            validate = true
          }
        },
        capabilities = capabilities
      }

      -- Emmet Language Server
      opts.servers.emmet_language_server = {
        filetypes = {
          "html", "css", "scss", "javascript", "javascriptreact",
          "typescript", "typescriptreact", "vue", "svelte"
        },
        init_options = {
          includeLanguages = {
            javascript = "javascriptreact",
            typescript = "typescriptreact"
          },
          preferences = {
            showExpandedAbbreviation = "always",
            showAbbreviationSuggestions = true,
            showSuggestionsAsSnippets = true
          }
        },
        capabilities = capabilities
      }

      return opts
    end
  },

  -- Mason configuration - CORRECT PACKAGE NAMES
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "html-lsp",           -- NOT vscode-html-language-server
        "css-lsp",            -- NOT vscode-css-language-server
        "emmet-language-server"
      })
      return opts
    end
  },

  -- Mason-LSPconfig for automatic setup
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "html",      -- Server name for lspconfig
        "cssls",     -- Server name for lspconfig
        "emmet_language_server"
      }
    }
  }
}