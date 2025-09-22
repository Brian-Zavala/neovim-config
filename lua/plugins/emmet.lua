return {
  -- Configure blink.cmp
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          lsp = {
            score_offset = 100,
          },
        },
      },
      keymap = {
        preset = "super-tab",
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        documentation = {
          auto_show = true,
        },
      },
    },
  },
  -- Configure emmet-language-server with basic settings
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if has_blink then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      opts.servers = opts.servers or {}

      opts.servers.emmet_language_server = {
        filetypes = {
          "html",
          "css",
          "scss",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "vue",
          "svelte",
          "jsx",
          "tsx",
        },
        capabilities = capabilities,
      }

      opts.servers.html = {
        filetypes = { "html" },
        capabilities = capabilities,
      }

      return opts
    end,
  },
  -- Custom Emmet expansion with boilerplate attributes for ALL HTML tags
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Create a universal Ctrl+E keybinding for Emmet expansion
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "html", "css", "javascriptreact", "typescriptreact", "vue", "svelte" },
        callback = function(ev)
          -- Function to handle Emmet expansion
          local function emmet_expand()
            -- Get the current line and cursor position
            local line = vim.api.nvim_get_current_line()
            local row, col = unpack(vim.api.nvim_win_get_cursor(0))

            -- Find the start of the abbreviation (including numbers and operators)
            local start_col = col
            while start_col > 0 do
              local char = line:sub(start_col, start_col)
              if not char:match("[%w%+%*%>%.%#%$%-%@%!%[%]%(%)%{%}]") then
                break
              end
              start_col = start_col - 1
            end

            -- Extract the abbreviation
            local abbr = line:sub(start_col + 1, col)

            if abbr == "" then
              -- No abbreviation found, fallback to default behavior
              return vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-e>", true, false, true), "n", false)
            end

            -- Delete the abbreviation text
            vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, col, {""})

            -- Define boilerplate attributes for ALL HTML tags
            local tag_attributes = {
              -- Form elements
              form = 'action="" method="POST"',
              input = 'type="text" name="" id="" value=""',
              button = 'type="button" name="" id=""',
              select = 'name="" id=""',
              option = 'value=""',
              textarea = 'name="" id="" rows="10" cols="30"',
              label = 'for=""',
              fieldset = 'name=""',
              legend = '',
              datalist = 'id=""',
              output = 'name="" for=""',

              -- Media elements
              img = 'src="" alt="" width="" height=""',
              video = 'src="" controls width="" height=""',
              audio = 'src="" controls',
              source = 'src="" type=""',
              track = 'src="" kind="" srclang="" label=""',
              picture = '',

              -- Links and meta
              a = 'href="" title=""',
              link = 'rel="stylesheet" href=""',
              meta = 'name="" content=""',
              base = 'href=""',

              -- Embedding
              iframe = 'src="" width="" height="" frameborder="0"',
              embed = 'src="" type="" width="" height=""',
              object = 'data="" type="" width="" height=""',
              param = 'name="" value=""',

              -- Tables
              table = 'border="0" cellpadding="0" cellspacing="0"',
              th = 'scope="col"',
              td = 'valign="top"',
              caption = '',

              -- Structure
              div = 'class="" id=""',
              span = 'class=""',
              section = 'class="" id=""',
              article = 'class="" id=""',
              aside = 'class=""',
              header = 'class=""',
              footer = 'class=""',
              main = 'class=""',
              nav = 'class=""',

              -- Interactive
              details = 'open',
              dialog = 'open',
              canvas = 'width="" height="" id=""',

              -- Others
              script = 'src="" type="text/javascript"',
              style = 'type="text/css"',
              area = 'shape="" coords="" href="" alt=""',
              map = 'name=""',
              meter = 'value="" min="" max=""',
              progress = 'value="" max=""',

              -- Lists
              ul = 'class=""',
              ol = 'class=""',
              li = '',
              dl = 'class=""',
              dt = '',
              dd = '',

              -- Text
              p = 'class=""',
              h1 = 'class="" id=""',
              h2 = 'class="" id=""',
              h3 = 'class="" id=""',
              h4 = 'class="" id=""',
              h5 = 'class="" id=""',
              h6 = 'class="" id=""',
              blockquote = 'cite=""',
              cite = '',
              code = 'class=""',
              pre = 'class=""',

              -- Default for any unspecified tag
              __default = 'class="" id=""',
            }

            -- Function to get tag name from abbreviation (handles complex patterns)
            local function get_base_tag(abbr_str)
              -- Remove ID, class, and attribute selectors
              local base = abbr_str:gsub("#[%w%-_]+", ""):gsub("%.[%w%-_]+", ""):gsub("%[.-%]", "")
              -- Remove multiplication and child operators
              base = base:gsub("%*%d+", ""):gsub(">.*", ""):gsub("%+.*", "")
              -- Get just the tag name
              base = base:match("^(%w+)")
              return base
            end

            -- Manually expand common patterns that emmet-language-server might miss
            local expanded = nil

            -- Handle list patterns specifically
            local list_pattern = "^([uo]l)>li%*(%d+)$"
            local list_match = abbr:match(list_pattern)
            if list_match then
              local tag_type = abbr:match("^([uo]l)")
              local count = tonumber(abbr:match("%*(%d+)$"))
              local items = {}
              for i = 1, count do
                table.insert(items, "  <li></li>")
              end
              expanded = string.format("<%s>\n%s\n</%s>", tag_type, table.concat(items, "\n"), tag_type)
            end

            -- Handle simple li*N pattern
            local li_count = abbr:match("^li%*(%d+)$")
            if li_count then
              local count = tonumber(li_count)
              local items = {}
              for i = 1, count do
                table.insert(items, "<li></li>")
              end
              expanded = table.concat(items, "\n")
            end

            -- Handle ul*N or ol*N pattern
            local list_type, list_num = abbr:match("^([uo]l)%*(%d+)$")
            if list_type and list_num then
              local count = tonumber(list_num)
              local lists = {}
              for i = 1, count do
                table.insert(lists, string.format("<%s></%s>", list_type, list_type))
              end
              expanded = table.concat(lists, "\n")
            end

            -- Handle tag*N patterns with boilerplate attributes
            local tag, tag_count = abbr:match("^(%w+)%*(%d+)$")
            if tag and tag_count and not expanded then
              local count = tonumber(tag_count)
              local tags = {}
              local attrs = tag_attributes[tag] and (" " .. tag_attributes[tag]) or ""
              for i = 1, count do
                -- Check if it's a self-closing tag
                if tag == "input" or tag == "img" or tag == "link" or tag == "meta" or tag == "br" or
                   tag == "hr" or tag == "area" or tag == "base" or tag == "col" or tag == "embed" or
                   tag == "source" or tag == "track" or tag == "wbr" or tag == "param" then
                  table.insert(tags, string.format("<%s%s />", tag, attrs))
                else
                  table.insert(tags, string.format("<%s%s></%s>", tag, attrs, tag))
                end
              end
              expanded = table.concat(tags, "\n")
            end

            -- Handle single tags with boilerplate attributes (no multiplication)
            if not expanded then
              local base_tag = get_base_tag(abbr)
              if base_tag then
                -- Get attributes for this tag, or use default if not specified
                local attrs = tag_attributes[base_tag]
                if attrs == nil and base_tag:match("^%w+$") then
                  -- Use default attributes for unspecified HTML tags
                  attrs = tag_attributes.__default or ""
                end

                if attrs and attrs ~= "" then
                  attrs = " " .. attrs
                else
                  attrs = ""
                end

                -- Check if it's a self-closing tag
                if base_tag == "input" or base_tag == "img" or base_tag == "link" or base_tag == "meta" or
                   base_tag == "br" or base_tag == "hr" or base_tag == "area" or base_tag == "base" or
                   base_tag == "col" or base_tag == "embed" or base_tag == "source" or base_tag == "track" or
                   base_tag == "wbr" or base_tag == "param" then
                  expanded = string.format("<%s%s />", base_tag, attrs)
                else
                  expanded = string.format("<%s%s></%s>", base_tag, attrs, base_tag)
                end
              end
            end

            if expanded then
              -- Insert the expanded text
              local lines = vim.split(expanded, "\n")
              vim.api.nvim_put(lines, "c", false, true)

              -- Move cursor to first tag content
              local first_close = expanded:find("><")
              if first_close then
                vim.api.nvim_win_set_cursor(0, {row, start_col + first_close})
              end
            else
              -- Fallback to LSP expansion for complex patterns
              -- But first, check if we can handle it with our custom expansion
              local simple_tag = abbr:match("^(%w+)$")
              if simple_tag then
                -- It's just a simple tag name, expand it with attributes
                local attrs = tag_attributes[simple_tag]
                if attrs == nil then
                  -- Use default attributes for unspecified HTML tags
                  attrs = tag_attributes.__default or ""
                end

                if attrs and attrs ~= "" then
                  attrs = " " .. attrs
                else
                  attrs = ""
                end

                -- Check if it's a self-closing tag
                if simple_tag == "input" or simple_tag == "img" or simple_tag == "link" or simple_tag == "meta" or
                   simple_tag == "br" or simple_tag == "hr" or simple_tag == "area" or simple_tag == "base" or
                   simple_tag == "col" or simple_tag == "embed" or simple_tag == "source" or simple_tag == "track" or
                   simple_tag == "wbr" or simple_tag == "param" then
                  expanded = string.format("<%s%s />", simple_tag, attrs)
                else
                  expanded = string.format("<%s%s></%s>", simple_tag, attrs, simple_tag)
                end

                if expanded then
                  -- Insert the expanded text
                  local lines = vim.split(expanded, "\n")
                  vim.api.nvim_put(lines, "c", false, true)

                  -- Move cursor to first empty attribute or inside tag
                  local first_empty = expanded:find('=""')
                  if first_empty then
                    vim.api.nvim_win_set_cursor(0, {row, start_col + first_empty})
                  else
                    local first_close = expanded:find("><")
                    if first_close then
                      vim.api.nvim_win_set_cursor(0, {row, start_col + first_close})
                    end
                  end
                  return
                end
              end

              -- Complex pattern - restore abbreviation and use LSP
              vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, start_col, {abbr})

              -- Try to trigger completion
              vim.defer_fn(function()
                require("blink.cmp").show()
                vim.defer_fn(function()
                  local cmp = require("blink.cmp")
                  if cmp.is_visible() then
                    cmp.accept()
                  end
                end, 100)
              end, 10)
            end
          end

          -- Map both Ctrl+E and Tab to Emmet expansion
          vim.keymap.set("i", "<C-e>", emmet_expand, {
            buffer = ev.buf,
            desc = "Expand Emmet abbreviation",
            silent = true
          })

          vim.keymap.set("i", "<Tab>", emmet_expand, {
            buffer = ev.buf,
            desc = "Expand Emmet abbreviation with Tab",
            silent = true
          })
        end,
      })
    end,
  },
  -- LuaSnip for lorem text
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node

      local lorem_snippets = {
        s("lor", {
          t("Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
        }),
        s("lorem", {
          t("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."),
        }),
      }

      local ft_list = { "html", "javascriptreact", "typescriptreact", "vue", "svelte" }
      for _, ft in ipairs(ft_list) do
        ls.add_snippets(ft, lorem_snippets)
      end
    end,
  },
  -- Ensure Mason installs emmet-language-server
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "emmet-language-server",
        "html-lsp",
      })
      return opts
    end,
  },
}