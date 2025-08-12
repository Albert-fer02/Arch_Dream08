-- Node.js configuration for Neovim
-- Prefer neovim-node-host when available; avoid forcing environment managers

local M = {}

-- Detect and configure the correct Node host for Neovim
local function setup_nodejs(silent)
  -- 1) Prefer an installed neovim-node-host in PATH
  local host = vim.fn.exepath("neovim-node-host")
  if host ~= nil and host ~= "" then
    vim.g.node_host_prog = host
    return true, nil
  end

  -- 2) Prefer Nix-managed neovim-node-host if available
  local nix_host = vim.fn.expand("~/.nix-profile/bin/neovim-node-host")
  if vim.fn.executable(nix_host) == 1 then
    vim.g.node_host_prog = nix_host
    return true, nil
  end

  -- 3) Fallback: try to locate npm's global neovim host script
  local ok_root, npm_root = pcall(vim.fn.system, "npm root -g 2>/dev/null")
  if ok_root and vim.v.shell_error == 0 and type(npm_root) == "string" then
    npm_root = npm_root:gsub("%s+$", "")
    local cli = npm_root .. "/neovim/bin/cli.js"
    if vim.fn.filereadable(cli) == 1 then
      -- Use the node executable to run the host cli.js
      local node = vim.fn.exepath("node")
      if node ~= nil and node ~= "" then
        vim.g.node_host_prog = node .. " " .. cli
        return true, nil
      end
    end
  end

  -- 4) As a last resort, ensure a recent node is present (some plugins may still work)
  local node_bin = vim.fn.exepath("node")
  if node_bin ~= nil and node_bin ~= "" then
    local out = vim.fn.system(node_bin .. " --version 2>/dev/null")
    if vim.v.shell_error == 0 then
      local version = (out or ""):gsub("\n", ""):gsub("v", "")
      local major = tonumber(version:match("^(%d+)"))
      if major and major >= 18 then
        if not silent then
          vim.notify("Node.js detected (v" .. version .. ") but neovim-node-host is missing.", vim.log.levels.WARN)
        end
        return true, version
      end
    end
  end

  if not silent then
    vim.notify("Node host not found. Install with: npm i -g neovim", vim.log.levels.ERROR)
  end
  return false, nil
end

-- Function to check if we're using a recent Node.js version
local function check_node_version()
  local node_bin = vim.fn.exepath("node")
  if node_bin == nil or node_bin == "" then
    return false
  end
  local version_output = vim.fn.system(node_bin .. " --version 2>/dev/null")
  if vim.v.shell_error ~= 0 then
    return false
  end
  local version = version_output:gsub("\n", ""):gsub("v", "")
  local major_version = tonumber(version:match("^(%d+)"))
  if major_version and major_version >= 22 then
    return true, version
  elseif major_version and major_version >= 18 then
    if vim.g.debug_nodejs then
      vim.notify("ℹ️  Node.js v" .. version .. " works (v22+ recommended).", vim.log.levels.INFO)
    end
    return true, version
  else
    vim.notify("⚠️  Node.js v" .. version .. " is too old. Require v18+.", vim.log.levels.WARN)
    return false, version
  end
end

-- Setup function to be called from init.lua
function M.setup(opts)
  opts = opts or {}
  local success = setup_nodejs(opts.silent)
  if success and not opts.silent then
    check_node_version()
  end
  return success
end

-- Function to get current Node.js info
function M.info()
  local display = {}
  if vim.g.node_host_prog then
    table.insert(display, "Node host: " .. vim.g.node_host_prog)
  else
    table.insert(display, "Node host: <not configured>")
  end
  local node_bin = vim.fn.exepath("node")
  if node_bin ~= nil and node_bin ~= "" then
    local version_output = vim.fn.system(node_bin .. " --version 2>/dev/null")
    local version = "unknown"
    if vim.v.shell_error == 0 then
      version = version_output:gsub("\n", ""):gsub("v", "")
    end
    table.insert(display, "node: " .. node_bin .. " (v" .. version .. ")")
  else
    table.insert(display, "node: <not found>")
  end
  print(table.concat(display, "\n"))
end

-- User commands
vim.api.nvim_create_user_command("NodeRefresh", function()
  M.setup({ silent = false })
  M.info()
end, { desc = "Refresh Node.js configuration" })

vim.api.nvim_create_user_command("NodeInfo", function()
  M.info()
end, { desc = "Show Node.js configuration info" })

vim.api.nvim_create_user_command("NodeDebug", function()
  vim.g.debug_nodejs = true
  print("=== Node.js Debug Mode Enabled ===")
  M.setup({ silent = false })
  M.info()
  print("=== Current PATH ===")
  print(vim.env.PATH)
  vim.g.debug_nodejs = false
end, { desc = "Debug Node.js configuration and PATH" })

return M
