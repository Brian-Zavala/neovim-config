return {
  -- LuaSnip for advanced HTML snippets
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local sn = ls.snippet_node
      local t = ls.text_node
      local i = ls.insert_node
      local f = ls.function_node
      local c = ls.choice_node
      local d = ls.dynamic_node
      local r = ls.restore_node
      local fmt = require("luasnip.extras.fmt").fmt
      local rep = require("luasnip.extras").rep

      -- Configure LuaSnip
      ls.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
        enable_autosnippets = true,
      })

      -- HTML5 Document snippets
      local html_snippets = {
        -- HTML5 Boilerplate
        s("html5", {
          t({
            "<!DOCTYPE html>",
            '<html lang="en">',
            "<head>",
            '  <meta charset="UTF-8">',
            '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
            '  <meta http-equiv="X-UA-Compatible" content="ie=edge">',
            "  <title>"
          }),
          i(1, "Document"),
          t({
            "</title>",
            "</head>",
            "<body>",
            "  "
          }),
          i(0),
          t({
            "",
            "</body>",
            "</html>"
          }),
        }),

        -- Form with all attributes
        s("form:full", fmt([[
          <form action="{}" method="{}" enctype="{}" name="{}" id="{}" class="{}" autocomplete="{}">
            {}
          </form>
        ]], {
          i(1, ""),
          c(2, {t("POST"), t("GET")}),
          c(3, {t("multipart/form-data"), t("application/x-www-form-urlencoded")}),
          i(4, ""),
          i(5, ""),
          i(6, ""),
          c(7, {t("on"), t("off")}),
          i(0),
        })),

        -- Input with all attributes
        s("input:full", fmt([[
          <input type="{}" name="{}" id="{}" value="{}" placeholder="{}" required="{}" class="{}" autocomplete="{}" />
        ]], {
          c(1, {
            t("text"), t("email"), t("password"), t("number"), t("tel"),
            t("url"), t("search"), t("date"), t("time"), t("datetime-local"),
            t("month"), t("week"), t("color"), t("file"), t("hidden"),
            t("checkbox"), t("radio"), t("submit"), t("reset"), t("button")
          }),
          i(2, ""),
          i(3, ""),
          i(4, ""),
          i(5, ""),
          c(6, {t(""), t("required")}),
          i(7, ""),
          i(0, ""),
        })),

        -- Image with responsive attributes
        s("img:responsive", fmt([[
          <img
            src="{}"
            alt="{}"
            srcset="{}"
            sizes="{}"
            loading="{}"
            decoding="{}"
            width="{}"
            height="{}"
            class="{}" />
        ]], {
          i(1, ""),
          i(2, ""),
          i(3, ""),
          i(4, "(max-width: 768px) 100vw, 50vw"),
          c(5, {t("lazy"), t("eager")}),
          c(6, {t("async"), t("sync"), t("auto")}),
          i(7, ""),
          i(8, ""),
          i(0, ""),
        })),

        -- Link with all attributes
        s("a:full", fmt([[
          <a href="{}" target="{}" rel="{}" title="{}" class="{}" download="{}">{}</a>
        ]], {
          i(1, "#"),
          c(2, {t("_self"), t("_blank"), t("_parent"), t("_top")}),
          c(3, {t("noopener noreferrer"), t("nofollow"), t(""), t("prefetch")}),
          i(4, ""),
          i(5, ""),
          i(6, ""),
          i(0, "Link text"),
        })),

        -- Video with all controls
        s("video:full", fmt([[
          <video
            src="{}"
            controls
            autoplay="{}"
            muted="{}"
            loop="{}"
            poster="{}"
            preload="{}"
            width="{}"
            height="{}"
            class="{}">
            <source src="{}" type="video/mp4">
            Your browser does not support the video tag.
          </video>
        ]], {
          i(1, ""),
          c(2, {t(""), t("autoplay")}),
          c(3, {t(""), t("muted")}),
          c(4, {t(""), t("loop")}),
          i(5, ""),
          c(6, {t("auto"), t("metadata"), t("none")}),
          i(7, ""),
          i(8, ""),
          i(9, ""),
          i(0, ""),
        })),

        -- Section with ARIA
        s("section:aria", fmt([[
          <section class="{}" id="{}" role="{}" aria-labelledby="{}" aria-describedby="{}">
            {}
          </section>
        ]], {
          i(1, ""),
          i(2, ""),
          c(3, {t("region"), t(""), t("main"), t("complementary")}),
          i(4, ""),
          i(5, ""),
          i(0),
        })),

        -- Button with all attributes
        s("button:full", fmt([[
          <button type="{}" name="{}" id="{}" class="{}" onclick="{}" disabled="{}" aria-label="{}">
            {}
          </button>
        ]], {
          c(1, {t("button"), t("submit"), t("reset")}),
          i(2, ""),
          i(3, ""),
          i(4, ""),
          i(5, ""),
          c(6, {t(""), t("disabled")}),
          i(7, ""),
          i(0, "Button text"),
        })),

        -- Meta tags collection
        s("meta:viewport", t('<meta name="viewport" content="width=device-width, initial-scale=1.0">')),
        s("meta:description", fmt('<meta name="description" content="{}">', {i(1, "")})),
        s("meta:keywords", fmt('<meta name="keywords" content="{}">', {i(1, "")})),
        s("meta:author", fmt('<meta name="author" content="{}">', {i(1, "")})),
        s("meta:og", fmt([[
          <meta property="og:title" content="{}">
          <meta property="og:description" content="{}">
          <meta property="og:image" content="{}">
          <meta property="og:url" content="{}">
          <meta property="og:type" content="{}">
        ]], {
          i(1, ""),
          i(2, ""),
          i(3, ""),
          i(4, ""),
          c(5, {t("website"), t("article"), t("product")}),
        })),

        -- Table with accessibility
        s("table:accessible", fmt([[
          <table class="{}" role="table" aria-label="{}">
            <caption>{}</caption>
            <thead>
              <tr>
                <th scope="col">{}</th>
                <th scope="col">{}</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>{}</td>
                <td>{}</td>
              </tr>
            </tbody>
          </table>
        ]], {
          i(1, ""),
          i(2, ""),
          i(3, "Table caption"),
          i(4, "Column 1"),
          i(5, "Column 2"),
          i(6, "Data 1"),
          i(0, "Data 2"),
        })),

        -- Select with options
        s("select:options", fmt([[
          <select name="{}" id="{}" class="{}" required="{}" multiple="{}">
            <option value="" disabled selected>Choose an option</option>
            <option value="{}">{}</option>
            <option value="{}">{}</option>
            {}
          </select>
        ]], {
          i(1, ""),
          i(2, ""),
          i(3, ""),
          c(4, {t(""), t("required")}),
          c(5, {t(""), t("multiple")}),
          i(6, "value1"),
          i(7, "Option 1"),
          i(8, "value2"),
          i(9, "Option 2"),
          i(0),
        })),

        -- Picture element for responsive images
        s("picture:responsive", fmt([[
          <picture>
            <source media="(min-width: 1200px)" srcset="{}">
            <source media="(min-width: 768px)" srcset="{}">
            <img src="{}" alt="{}" loading="lazy">
          </picture>
        ]], {
          i(1, "large.jpg"),
          i(2, "medium.jpg"),
          i(3, "small.jpg"),
          i(0, ""),
        })),

        -- Article with schema.org
        s("article:schema", fmt([[
          <article class="{}" itemscope itemtype="http://schema.org/Article">
            <header>
              <h1 itemprop="headline">{}</h1>
              <time itemprop="datePublished" datetime="{}">{}</time>
            </header>
            <div itemprop="articleBody">
              {}
            </div>
          </article>
        ]], {
          i(1, ""),
          i(2, "Article Title"),
          i(3, "2024-01-01"),
          i(4, "January 1, 2024"),
          i(0),
        })),

        -- Dialog element
        s("dialog:modal", fmt([[
          <dialog id="{}" class="{}" aria-labelledby="{}" aria-describedby="{}">
            <header>
              <h2 id="{}">{}</h2>
              <button aria-label="Close" onclick="this.closest('dialog').close()">×</button>
            </header>
            <div id="{}">
              {}
            </div>
            <footer>
              <button onclick="this.closest('dialog').close()">Close</button>
            </footer>
          </dialog>
        ]], {
          i(1, "modal"),
          i(2, ""),
          i(3, "modal-title"),
          i(4, "modal-desc"),
          rep(3),
          i(5, "Modal Title"),
          rep(4),
          i(0),
        })),
      }

      -- Add snippets to multiple filetypes
      local ft_list = {"html", "javascriptreact", "typescriptreact", "vue", "svelte", "php", "blade"}
      for _, ft in ipairs(ft_list) do
        ls.add_snippets(ft, html_snippets)
      end

      -- Load VSCode-style snippets from friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- Key mappings for LuaSnip
      vim.keymap.set({"i", "s"}, "<C-k>", function()
        if ls.expand_or_jumpable() then
          ls.expand_or_jump()
        end
      end, {silent = true, desc = "LuaSnip expand or jump"})

      vim.keymap.set({"i", "s"}, "<C-j>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        end
      end, {silent = true, desc = "LuaSnip jump backward"})

      vim.keymap.set({"i", "s"}, "<C-l>", function()
        if ls.choice_active() then
          ls.change_choice(1)
        end
      end, {silent = true, desc = "LuaSnip cycle choice"})
    end,
  },
}