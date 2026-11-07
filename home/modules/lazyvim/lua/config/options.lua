-- Fall back to copy-only OSC 52 when Neovim finds no real clipboard tool, such
-- as over SSH on a headless host. "OSC 52" is Neovim's own fallback, which also
-- reads through the terminal, so it doesn't count as a real tool.
local detected = vim.g.clipboard == nil and vim.fn["provider#clipboard#Executable"]()
if detected == "" or detected == "OSC 52" then
  local osc52 = require("vim.ui.clipboard.osc52")
  local last = {} -- Pasting from "+" and "*" returns what this Neovim last copied.

  local function copy(reg)
    local send = osc52.copy(reg)
    return function(lines, regtype)
      last[reg] = { lines, regtype }
      send(lines)
    end
  end

  local function paste(reg)
    return function()
      return last[reg] or { { "" }, "v" }
    end
  end

  vim.g.clipboard = {
    name = "OSC 52 (copy only)",
    copy = { ["+"] = copy("+"), ["*"] = copy("*") },
    paste = { ["+"] = paste("+"), ["*"] = paste("*") },
  }
  vim.opt.clipboard = "unnamedplus"

  -- Detection above already loaded the provider, so reload it to use g:clipboard.
  vim.g.loaded_clipboard_provider = nil
  vim.cmd.runtime("autoload/provider/clipboard.vim")
end
