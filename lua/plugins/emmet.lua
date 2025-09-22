return {
  -- Custom Emmet expansion with boilerplate attributes for ALL HTML tags
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Create a universal Tab keybinding for Emmet expansion
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

            -- Debug: Uncomment to see what abbreviation we captured
            -- vim.notify("Emmet abbr: '" .. abbr .. "'", vim.log.levels.INFO)

            -- Delete the abbreviation text
            vim.api.nvim_buf_set_text(0, row - 1, start_col, row - 1, col, {""})

            -- Define comprehensive boilerplate attributes for ALL HTML5 tags
            local tag_attributes = {
              -- Form elements with all common attributes
              form = 'action="" method="POST" enctype="multipart/form-data" name="" id="" class="" autocomplete="on"',
              input = 'type="text" name="" id="" value="" placeholder="" required class="" autocomplete="" minlength="" maxlength="" pattern=""',
              button = 'type="button" name="" id="" class="" onclick="" disabled=""',
              select = 'name="" id="" class="" required multiple size=""',
              option = 'value="" selected disabled',
              textarea = 'name="" id="" rows="10" cols="30" placeholder="" required class="" minlength="" maxlength=""',
              label = 'for="" class=""',
              fieldset = 'name="" class="" disabled',
              legend = 'class=""',
              datalist = 'id=""',
              output = 'name="" for="" class=""',
              optgroup = 'label="" disabled',

              -- Media elements with comprehensive attributes
              img = 'src="" alt="" width="" height="" loading="lazy" decoding="async" class="" srcset="" sizes=""',
              video = 'src="" controls width="" height="" autoplay muted loop poster="" preload="auto" class=""',
              audio = 'src="" controls autoplay loop muted preload="auto"',
              source = 'src="" type="" media="" srcset="" sizes=""',
              track = 'src="" kind="subtitles" srclang="" label="" default',
              picture = 'class=""',

              -- Links and meta with all attributes
              a = 'href="" title="" target="" rel="noopener noreferrer" class="" download="" hreflang=""',
              link = 'rel="stylesheet" href="" type="text/css" media="all" crossorigin="anonymous" integrity=""',
              meta = 'name="" content="" charset="UTF-8" http-equiv="" property=""',
              base = 'href="" target=""',

              -- Embedding with security attributes
              iframe = 'src="" width="" height="" frameborder="0" loading="lazy" sandbox="" allow="" class="" title=""',
              embed = 'src="" type="" width="" height="" class=""',
              object = 'data="" type="" width="" height="" class="" name=""',
              param = 'name="" value=""',

              -- Tables with accessibility
              table = 'class="" id="" role="table" aria-label=""',
              th = 'scope="col" class="" colspan="" rowspan="" abbr=""',
              td = 'class="" colspan="" rowspan="" headers=""',
              caption = 'class=""',
              thead = 'class=""',
              tbody = 'class=""',
              tfoot = 'class=""',
              tr = 'class=""',
              col = 'span="" class=""',
              colgroup = 'span="" class=""',

              -- HTML5 Semantic Structure with ARIA
              div = 'class="" id="" role="" aria-label="" data-""',
              span = 'class="" id="" role="" aria-label=""',
              section = 'class="" id="" role="" aria-labelledby="" aria-describedby=""',
              article = 'class="" id="" role="article" aria-labelledby="" itemscope itemtype=""',
              aside = 'class="" id="" role="complementary" aria-label=""',
              header = 'class="" id="" role="banner"',
              footer = 'class="" id="" role="contentinfo"',
              main = 'class="" id="" role="main"',
              nav = 'class="" id="" role="navigation" aria-label=""',
              figure = 'class="" id="" role="figure"',
              figcaption = 'class=""',

              -- Interactive HTML5 elements
              details = 'open class="" id=""',
              summary = 'class=""',
              dialog = 'open class="" id="" role="dialog" aria-labelledby="" aria-describedby=""',
              canvas = 'width="" height="" id="" class=""',
              svg = 'width="" height="" viewBox="" xmlns="http://www.w3.org/2000/svg" class="" role="img" aria-label=""',

              -- Script and style with modern attributes
              script = 'src="" type="module" async defer crossorigin="anonymous" integrity="" nonce=""',
              style = 'type="text/css" media="all" nonce=""',
              noscript = 'class=""',
              template = 'id="" class=""',

              -- Interactive map
              area = 'shape="rect" coords="" href="" alt="" target="" rel=""',
              map = 'name="" id=""',

              -- Progress indicators
              meter = 'value="" min="0" max="100" low="" high="" optimum=""',
              progress = 'value="" max="100" class=""',

              -- Lists with classes
              ul = 'class="" id="" role="list"',
              ol = 'class="" id="" start="" type="" role="list"',
              li = 'class="" role="listitem"',
              dl = 'class="" id="" role="definition"',
              dt = 'class=""',
              dd = 'class=""',
              menu = 'type="" label="" class=""',

              -- Text elements with semantic attributes
              p = 'class="" id="" lang=""',
              h1 = 'class="" id="" role="heading" aria-level="1"',
              h2 = 'class="" id="" role="heading" aria-level="2"',
              h3 = 'class="" id="" role="heading" aria-level="3"',
              h4 = 'class="" id="" role="heading" aria-level="4"',
              h5 = 'class="" id="" role="heading" aria-level="5"',
              h6 = 'class="" id="" role="heading" aria-level="6"',
              blockquote = 'cite="" class="" id=""',
              cite = 'class=""',
              code = 'class="" id=""',
              pre = 'class="" id=""',
              abbr = 'title="" class=""',
              address = 'class="" id=""',
              b = 'class=""',
              strong = 'class=""',
              i = 'class=""',
              em = 'class=""',
              mark = 'class=""',
              small = 'class=""',
              del = 'datetime="" cite="" class=""',
              ins = 'datetime="" cite="" class=""',
              sub = 'class=""',
              sup = 'class=""',
              q = 'cite="" class=""',
              dfn = 'class="" title=""',
              kbd = 'class=""',
              samp = 'class=""',
              var = 'class=""',
              time = 'datetime="" class=""',
              bdi = 'class="" dir=""',
              bdo = 'dir="" class=""',
              ruby = 'class=""',
              rt = 'class=""',
              rp = 'class=""',
              wbr = '',

              -- Data elements
              data = 'value="" class=""',

              -- Default for any unspecified tag
              __default = 'class="" id="" data-""',
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

            -- Manually expand patterns with our custom attributes
            local expanded = nil

            -- PRIORITY 1: Handle simple single tags (like "form", "input", "div")
            local simple_tag = abbr:match("^(%w+)$")
            if simple_tag then
              local attrs = tag_attributes[simple_tag]
              -- If no specific attributes, use default for common HTML elements
              if attrs == nil and simple_tag:match("^[a-z]+$") then
                attrs = tag_attributes.__default or ""
              end

              if attrs ~= nil then
                if attrs ~= "" then
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
              end
            end

            -- PRIORITY 2: Handle list patterns specifically
            if not expanded then
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
            end

            -- PRIORITY 3: Handle simple li*N pattern
            if not expanded then
              local li_count = abbr:match("^li%*(%d+)$")
              if li_count then
                local count = tonumber(li_count)
                local items = {}
                for i = 1, count do
                  table.insert(items, "<li></li>")
                end
                expanded = table.concat(items, "\n")
              end
            end

            -- PRIORITY 4: Handle tag*N patterns with boilerplate attributes
            if not expanded then
              local tag, tag_count = abbr:match("^(%w+)%*(%d+)$")
              if tag and tag_count then
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
            else
              -- Fallback to LSP expansion for truly complex patterns
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

          -- Map Tab to Emmet expansion
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
}