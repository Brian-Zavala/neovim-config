-- Persist a colorscheme picked inside Neovim across restarts, on top of the
-- Omarchy-owned lua/plugins/theme.lua. See lua/config/colorscheme_pin.lua.
--
-- NOTE: this module must sort after "plugins.theme" (lazy.nvim imports spec
-- modules in modname order) so the opts function below runs after Omarchy's
-- table merge and wins.
local pin = require("config.colorscheme_pin")

return {
	{
		"LazyVim/LazyVim",
		opts = function(_, opts)
			local pinned = pin.read()
			if not pinned then
				return
			end
			-- No Omarchy theme.lua off Arch (e.g. Windows): fall back to LazyVim's default
			local fallback = opts.colorscheme or "tokyonight"
			-- LazyVim accepts a function; lazy.nvim's ColorSchemePre hook still
			-- lazy-loads the colorscheme plugin inside vim.cmd.colorscheme.
			opts.colorscheme = function()
				if not pcall(vim.cmd.colorscheme, pinned) then
					pin.clear()
					vim.notify(
						"Pinned colorscheme '" .. pinned .. "' not found, following Omarchy",
						vim.log.levels.WARN
					)
					vim.cmd.colorscheme(fallback)
				end
			end
		end,
	},
	{
		name = "colorscheme-pin",
		dir = vim.fn.stdpath("config"),
		lazy = false,
		config = function()
			-- Record interactive picks. ev.match is the colorscheme name. Startup
			-- applies happen before VimEnter and the hotreload plugin sets
			-- pin.applying, so neither gets recorded as a pin.
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("colorscheme-pin", { clear = true }),
				callback = function(ev)
					if pin.applying or vim.v.vim_did_enter == 0 then
						return
					end
					pin.write(ev.match)
				end,
			})

			vim.api.nvim_create_user_command("ThemePin", function(o)
				pin.write(o.args ~= "" and o.args or vim.g.colors_name)
			end, { nargs = "?", complete = "color", desc = "Pin a Neovim colorscheme over the Omarchy theme" })

			vim.api.nvim_create_user_command("ThemeUnpin", function()
				pin.clear()
				local omarchy = pin.omarchy()
				if omarchy then
					pin.applying = true
					pcall(vim.cmd.colorscheme, omarchy)
					pin.applying = false
				end
			end, { desc = "Follow the Omarchy theme colorscheme again" })

			vim.api.nvim_create_user_command("ThemeStatus", function()
				local pinned = pin.read()
				if pinned then
					print("pinned: " .. pinned)
				else
					print("following Omarchy: " .. tostring(pin.omarchy()))
				end
			end, { desc = "Show whether the Neovim colorscheme is pinned" })
		end,
	},
}
