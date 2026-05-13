local node_dir = vim.fn.stdpath('data') .. '/node'
local node_bin = node_dir .. '/bin/node'

-- Prepend to PATH so Mason finds npm/node before any plugins load
vim.env.PATH = node_dir .. '/bin:' .. vim.env.PATH

local function install_node()
  local arch_map = { x64 = "x64", arm64 = "arm64" }
  local os_map   = { Linux = "linux", OSX = "darwin" }
  local arch = arch_map[jit.arch]
  local os   = os_map[jit.os]

  if not arch or not os then
    vim.notify(
      string.format("node: unsupported platform %s/%s", jit.os, jit.arch),
      vim.log.levels.ERROR
    )
    return
  end

  vim.notify("node: not found, downloading LTS…", vim.log.levels.INFO)
  vim.fn.mkdir(node_dir, "p")

  local cmd = string.format(
    'set -e; '
    .. 'VER=$(curl -sf https://nodejs.org/dist/index.json'
    .. ' | grep -m1 \'"lts":"\' | sed \'s/.*"version":"//;s/".*//' .. '\'); '
    .. 'curl -sL "https://nodejs.org/dist/$VER/node-$VER-%s-%s.tar.xz"'
    .. ' | tar -xJ --strip-components=1 -C "%s"',
    os, arch, node_dir
  )

  vim.fn.jobstart({ "sh", "-c", cmd }, {
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("node: installed — restart Neovim to activate LSP servers", vim.log.levels.INFO)
      else
        vim.notify("node: installation failed (check internet connection)", vim.log.levels.ERROR)
      end
    end,
  })
end

if vim.fn.filereadable(node_bin) == 0 then
  install_node()
end
