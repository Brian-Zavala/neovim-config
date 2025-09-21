return {
  -- Auto close and rename HTML tags
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    config = function()
      require("nvim-ts-autotag").setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = true,
        },
      })
    end,
  },

  -- LuaSnip for HTML expansion
  {
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node

      -- Load VSCode-style snippets
      require("luasnip.loaders.from_vscode").lazy_load()

      -- HTML snippets for ALL tags - just type the tag name and press Tab
      -- Works for HTML, JSX, TSX, and React files
      local snippets = {
        s("div", {
          t("<div>"),
          i(1),
          t("</div>"),
        }),
        s("span", {
          t("<span>"),
          i(1),
          t("</span>"),
        }),
        s("p", {
          t("<p>"),
          i(1),
          t("</p>"),
        }),
        s("a", {
          t('<a href="'),
          i(1, "#"),
          t('">'),
          i(2),
          t("</a>"),
        }),
        s("ul", {
          t({"<ul>", "\t<li>"}),
          i(1),
          t({"</li>", "</ul>"}),
        }),
        s("li", {
          t("<li>"),
          i(1),
          t("</li>"),
        }),
        s("h1", {
          t("<h1>"),
          i(1),
          t("</h1>"),
        }),
        s("h2", {
          t("<h2>"),
          i(1),
          t("</h2>"),
        }),
        s("h3", {
          t("<h3>"),
          i(1),
          t("</h3>"),
        }),
        s("h4", {
          t("<h4>"),
          i(1),
          t("</h4>"),
        }),
        s("h5", {
          t("<h5>"),
          i(1),
          t("</h5>"),
        }),
        s("h6", {
          t("<h6>"),
          i(1),
          t("</h6>"),
        }),
        s("button", {
          t("<button>"),
          i(1),
          t("</button>"),
        }),
        s("section", {
          t("<section>"),
          i(1),
          t("</section>"),
        }),
        s("article", {
          t("<article>"),
          i(1),
          t("</article>"),
        }),
        s("header", {
          t("<header>"),
          i(1),
          t("</header>"),
        }),
        s("footer", {
          t("<footer>"),
          i(1),
          t("</footer>"),
        }),
        s("nav", {
          t("<nav>"),
          i(1),
          t("</nav>"),
        }),
        s("main", {
          t("<main>"),
          i(1),
          t("</main>"),
        }),
        s("aside", {
          t("<aside>"),
          i(1),
          t("</aside>"),
        }),
        s("form", {
          t("<form>"),
          i(1),
          t("</form>"),
        }),
        s("input", {
          t('<input type="'),
          i(1, "text"),
          t('" />'),
        }),
        s("label", {
          t('<label for="'),
          i(1),
          t('">'),
          i(2),
          t("</label>"),
        }),
        s("select", {
          t({"<select>", "\t<option>"}),
          i(1),
          t({"</option>", "</select>"}),
        }),
        s("option", {
          t("<option>"),
          i(1),
          t("</option>"),
        }),
        s("textarea", {
          t("<textarea>"),
          i(1),
          t("</textarea>"),
        }),
        s("img", {
          t('<img src="'),
          i(1),
          t('" alt="'),
          i(2),
          t('" />'),
        }),
        s("video", {
          t('<video src="'),
          i(1),
          t('">'),
          t("</video>"),
        }),
        s("audio", {
          t('<audio src="'),
          i(1),
          t('">'),
          t("</audio>"),
        }),
        s("canvas", {
          t("<canvas>"),
          i(1),
          t("</canvas>"),
        }),
        s("svg", {
          t("<svg>"),
          i(1),
          t("</svg>"),
        }),
        s("iframe", {
          t('<iframe src="'),
          i(1),
          t('">'),
          t("</iframe>"),
        }),
        s("table", {
          t({"<table>", "\t<tr>", "\t\t<td>"}),
          i(1),
          t({"</td>", "\t</tr>", "</table>"}),
        }),
        s("thead", {
          t("<thead>"),
          i(1),
          t("</thead>"),
        }),
        s("tbody", {
          t("<tbody>"),
          i(1),
          t("</tbody>"),
        }),
        s("tfoot", {
          t("<tfoot>"),
          i(1),
          t("</tfoot>"),
        }),
        s("tr", {
          t("<tr>"),
          i(1),
          t("</tr>"),
        }),
        s("td", {
          t("<td>"),
          i(1),
          t("</td>"),
        }),
        s("th", {
          t("<th>"),
          i(1),
          t("</th>"),
        }),
        s("caption", {
          t("<caption>"),
          i(1),
          t("</caption>"),
        }),
        s("colgroup", {
          t("<colgroup>"),
          i(1),
          t("</colgroup>"),
        }),
        s("col", {
          t("<col />"),
        }),
        s("fieldset", {
          t("<fieldset>"),
          i(1),
          t("</fieldset>"),
        }),
        s("legend", {
          t("<legend>"),
          i(1),
          t("</legend>"),
        }),
        s("datalist", {
          t("<datalist>"),
          i(1),
          t("</datalist>"),
        }),
        s("output", {
          t("<output>"),
          i(1),
          t("</output>"),
        }),
        s("progress", {
          t("<progress>"),
          i(1),
          t("</progress>"),
        }),
        s("meter", {
          t("<meter>"),
          i(1),
          t("</meter>"),
        }),
        s("details", {
          t("<details>"),
          i(1),
          t("</details>"),
        }),
        s("summary", {
          t("<summary>"),
          i(1),
          t("</summary>"),
        }),
        s("dialog", {
          t("<dialog>"),
          i(1),
          t("</dialog>"),
        }),
        s("template", {
          t("<template>"),
          i(1),
          t("</template>"),
        }),
        s("slot", {
          t("<slot>"),
          i(1),
          t("</slot>"),
        }),
        s("picture", {
          t("<picture>"),
          i(1),
          t("</picture>"),
        }),
        s("source", {
          t('<source src="'),
          i(1),
          t('" />'),
        }),
        s("track", {
          t('<track src="'),
          i(1),
          t('" />'),
        }),
        s("embed", {
          t('<embed src="'),
          i(1),
          t('" />'),
        }),
        s("object", {
          t("<object>"),
          i(1),
          t("</object>"),
        }),
        s("param", {
          t('<param name="'),
          i(1),
          t('" value="'),
          i(2),
          t('" />'),
        }),
        s("code", {
          t("<code>"),
          i(1),
          t("</code>"),
        }),
        s("pre", {
          t("<pre>"),
          i(1),
          t("</pre>"),
        }),
        s("blockquote", {
          t("<blockquote>"),
          i(1),
          t("</blockquote>"),
        }),
        s("cite", {
          t("<cite>"),
          i(1),
          t("</cite>"),
        }),
        s("q", {
          t("<q>"),
          i(1),
          t("</q>"),
        }),
        s("abbr", {
          t("<abbr>"),
          i(1),
          t("</abbr>"),
        }),
        s("address", {
          t("<address>"),
          i(1),
          t("</address>"),
        }),
        s("time", {
          t("<time>"),
          i(1),
          t("</time>"),
        }),
        s("mark", {
          t("<mark>"),
          i(1),
          t("</mark>"),
        }),
        s("del", {
          t("<del>"),
          i(1),
          t("</del>"),
        }),
        s("ins", {
          t("<ins>"),
          i(1),
          t("</ins>"),
        }),
        s("sub", {
          t("<sub>"),
          i(1),
          t("</sub>"),
        }),
        s("sup", {
          t("<sup>"),
          i(1),
          t("</sup>"),
        }),
        s("small", {
          t("<small>"),
          i(1),
          t("</small>"),
        }),
        s("strong", {
          t("<strong>"),
          i(1),
          t("</strong>"),
        }),
        s("em", {
          t("<em>"),
          i(1),
          t("</em>"),
        }),
        s("b", {
          t("<b>"),
          i(1),
          t("</b>"),
        }),
        s("i", {
          t("<i>"),
          i(1),
          t("</i>"),
        }),
        s("u", {
          t("<u>"),
          i(1),
          t("</u>"),
        }),
        s("s", {
          t("<s>"),
          i(1),
          t("</s>"),
        }),
        s("kbd", {
          t("<kbd>"),
          i(1),
          t("</kbd>"),
        }),
        s("var", {
          t("<var>"),
          i(1),
          t("</var>"),
        }),
        s("samp", {
          t("<samp>"),
          i(1),
          t("</samp>"),
        }),
        s("data", {
          t("<data>"),
          i(1),
          t("</data>"),
        }),
        s("br", {
          t("<br />"),
        }),
        s("hr", {
          t("<hr />"),
        }),
        s("wbr", {
          t("<wbr />"),
        }),
        s("area", {
          t("<area />"),
        }),
        s("base", {
          t("<base />"),
        }),
        s("link", {
          t('<link rel="'),
          i(1, "stylesheet"),
          t('" href="'),
          i(2),
          t('" />'),
        }),
        s("meta", {
          t('<meta name="'),
          i(1),
          t('" content="'),
          i(2),
          t('" />'),
        }),
        s("style", {
          t({"<style>", "\t"}),
          i(1),
          t({"", "</style>"}),
        }),
        s("script", {
          t({"<script>", "\t"}),
          i(1),
          t({"", "</script>"}),
        }),
        s("noscript", {
          t("<noscript>"),
          i(1),
          t("</noscript>"),
        }),
        s("title", {
          t("<title>"),
          i(1),
          t("</title>"),
        }),
        s("head", {
          t({"<head>", "\t"}),
          i(1),
          t({"", "</head>"}),
        }),
        s("body", {
          t({"<body>", "\t"}),
          i(1),
          t({"", "</body>"}),
        }),
        s("html", {
          t({"<html>", "\t"}),
          i(1),
          t({"", "</html>"}),
        }),
        s("doctype", {
          t("<!DOCTYPE html>"),
        }),
        s("figure", {
          t("<figure>"),
          i(1),
          t("</figure>"),
        }),
        s("figcaption", {
          t("<figcaption>"),
          i(1),
          t("</figcaption>"),
        }),
        s("menu", {
          t("<menu>"),
          i(1),
          t("</menu>"),
        }),
        s("menuitem", {
          t("<menuitem>"),
          i(1),
          t("</menuitem>"),
        }),
        s("dl", {
          t("<dl>"),
          i(1),
          t("</dl>"),
        }),
        s("dt", {
          t("<dt>"),
          i(1),
          t("</dt>"),
        }),
        s("dd", {
          t("<dd>"),
          i(1),
          t("</dd>"),
        }),
        s("ruby", {
          t("<ruby>"),
          i(1),
          t("</ruby>"),
        }),
        s("rt", {
          t("<rt>"),
          i(1),
          t("</rt>"),
        }),
        s("rp", {
          t("<rp>"),
          i(1),
          t("</rp>"),
        }),
        s("bdi", {
          t("<bdi>"),
          i(1),
          t("</bdi>"),
        }),
        s("bdo", {
          t("<bdo>"),
          i(1),
          t("</bdo>"),
        }),
        s("dfn", {
          t("<dfn>"),
          i(1),
          t("</dfn>"),
        }),
      }

      -- Add snippets to all relevant filetypes
      ls.add_snippets("html", snippets)
      ls.add_snippets("javascript", snippets)
      ls.add_snippets("javascriptreact", snippets)
      ls.add_snippets("typescript", snippets)
      ls.add_snippets("typescriptreact", snippets)
      ls.add_snippets("jsx", snippets)
      ls.add_snippets("tsx", snippets)

      -- Map Tab to expand snippets
      vim.keymap.set({"i"}, "<Tab>", function()
        if ls.expandable() then
          ls.expand()
        elseif ls.jumpable(1) then
          ls.jump(1)
        else
          return "<Tab>"
        end
      end, { expr = true, silent = true })

      -- Map Shift-Tab to jump backwards
      vim.keymap.set({"i", "s"}, "<S-Tab>", function()
        if ls.jumpable(-1) then
          ls.jump(-1)
        else
          return "<S-Tab>"
        end
      end, { expr = true, silent = true })
    end,
  },

  -- Configure blink.cmp to use the new snippets preset for LuaSnip
  {
    "saghen/blink.cmp",
    opts = {
      snippets = {
        preset = "luasnip",
      },
    },
  },
}