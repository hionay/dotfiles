vim.o.swapfile = false

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end

local add = vim.pack.add
local now, later = Config.now, Config.later

now(function()
  add({ "https://github.com/rebelot/kanagawa.nvim" })

  require("kanagawa").setup({
    compile = true,
    transparent = true,
    colors = {
      theme = {
        all = {
          ui = {
            bg_gutter = "none",
          },
        },
      },
    },
    overrides = function(colors)
      local theme = colors.theme
      return {
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },
        NormalDark = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m3 },
      }
    end,
    theme = "dragon",
    background = {
      dark = "dragon",
      light = "lotus",
    },
  })

  if vim.fn.has("mac") == 1 then
    vim.fn.system("defaults read -g AppleInterfaceStyle")
    vim.o.background = vim.v.shell_error ~= 0 and "light" or "dark"
  end

  vim.cmd("color kanagawa")
end)

later(function()
  add({
    "https://github.com/nvim-lua/plenary.nvim",
    "https://github.com/sindrets/diffview.nvim",
    "https://github.com/nvim-mini/mini.pick",
    "https://github.com/NeogitOrg/neogit",
  })

  require("neogit").setup({
    graph_style = "kitty",
    process_spinner = true,
    diff_viewer = "diffview",
    integrations = {
      diffview = true,
      mini_pick = true,
    },
  })
  nmap_leader("gg", function()
    require("neogit").open()
  end, "Show Neogit")
end)

later(function()
  add({ "https://github.com/alexghergh/nvim-tmux-navigation" })

  require("nvim-tmux-navigation").setup({
    disable_when_zoomed = true,
    keybindings = {
      left = "<C-h>",
      down = "<C-j>",
      up = "<C-k>",
      right = "<C-l>",
      last_active = "<C-\\>",
      next = "<C-Space>",
    },
  })
end)

later(function()
  add({ "https://github.com/wakatime/vim-wakatime" })
end)

later(function()
  add({ "https://github.com/github/copilot.vim" })
end)

later(function()
  add({ "https://github.com/nvim-lua/plenary.nvim" })
  add({ "https://github.com/nvim-neotest/nvim-nio" })
  add({ "https://github.com/antoinemadec/FixCursorHold.nvim" })
  add({ "https://github.com/nvim-neotest/neotest" })
  add({ "https://github.com/nvim-neotest/neotest-plenary" })
  add({ "https://github.com/nvim-neotest/neotest-vim-test" })
  add({
    "https://github.com/fredrikaverpil/neotest-golang",
    "https://github.com/leoluz/nvim-dap-go",
  })

  local neotest = require("neotest")
  local nt_go = require("neotest-golang")

  neotest.setup({
    adapters = {
      nt_go({
        go_test_args = {
          "-v",
          "-race",
          "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
        },
      }),
      require("neotest-plenary"),
      require("neotest-vim-test"),
    },
  })

  nmap_leader("ta", function()
    neotest.run.attach()
  end, "[t]est [a]ttach")
  nmap_leader("tf", function()
    neotest.run.run(vim.fn.expand("%"))
  end, "[t]est run [f]ile")
  nmap_leader("tA", function()
    neotest.run.run(vim.uv.cwd())
  end, "[t]est [A]ll files")
  nmap_leader("tS", function()
    neotest.run.run({ suite = true })
  end, "[t]est [S]uite")
  nmap_leader("tn", function()
    neotest.run.run()
  end, "[t]est [n]earest")
  nmap_leader("tl", function()
    neotest.run.run_last()
  end, "[t]est [l]ast")
  nmap_leader("ts", function()
    neotest.summary.toggle()
  end, "[t]est [s]ummary")
  nmap_leader("to", function()
    neotest.output.open({ enter = true, auto_close = true })
  end, "[t]est [o]utput")
  nmap_leader("tO", function()
    neotest.output_panel.toggle()
  end, "[t]est [O]utput panel")
  nmap_leader("tt", function()
    neotest.run.stop()
  end, "[t]est [t]erminate")
  nmap_leader("td", function()
    neotest.run.run({ suite = false, strategy = "dap" })
  end, "Debug nearest test")
  nmap_leader("tD", function()
    neotest.run.run({ vim.fn.expand("%"), strategy = "dap" })
  end, "Debug current file")
end)

later(function()
  add({ "https://github.com/mfussenegger/nvim-dap" })
end)

later(function()
  add({ "https://github.com/nvim-neotest/nvim-nio" })
  add({ "https://github.com/mfussenegger/nvim-dap" })
  add({ "https://github.com/rcarriga/nvim-dap-ui" })
  add({ "https://github.com/theHamsta/nvim-dap-virtual-text" })

  local dap = require("dap")
  local dapui = require("dapui")

  dapui.setup({})

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open({})
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close({})
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close({})
  end

  require("nvim-dap-virtual-text").setup({})

  nmap_leader("db", function()
    dap.toggle_breakpoint()
  end, "toggle [d]ebug [b]reakpoint")
  nmap_leader("dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, "[d]ebug [B]reakpoint")
  nmap_leader("dc", function()
    dap.continue()
  end, "[d]ebug [c]ontinue (start here)")
  nmap_leader("dC", function()
    dap.run_to_cursor()
  end, "[d]ebug [C]ursor")
  nmap_leader("dg", function()
    dap.goto_()
  end, "[d]ebug [g]o to line")
  nmap_leader("do", function()
    dap.step_over()
  end, "[d]ebug step [o]ver")
  nmap_leader("dO", function()
    dap.step_out()
  end, "[d]ebug step [O]ut")
  nmap_leader("di", function()
    dap.step_into()
  end, "[d]ebug [i]nto")
  nmap_leader("dj", function()
    dap.down()
  end, "[d]ebug [j]ump down")
  nmap_leader("dk", function()
    dap.up()
  end, "[d]ebug [k]ump up")
  nmap_leader("dl", function()
    dap.run_last()
  end, "[d]ebug [l]ast")
  nmap_leader("dp", function()
    dap.pause()
  end, "[d]ebug [p]ause")
  nmap_leader("dr", function()
    dap.repl.toggle()
  end, "[d]ebug [r]epl")
  nmap_leader("dR", function()
    dap.clear_breakpoints()
  end, "[d]ebug [R]emove breakpoints")
  nmap_leader("ds", function()
    dap.session()
  end, "[d]ebug [s]ession")
  nmap_leader("dt", function()
    dap.terminate()
  end, "[d]ebug [t]erminate")
  nmap_leader("dw", function()
    require("dap.ui.widgets").hover()
  end, "[d]ebug [w]idgets")

  nmap_leader("du", function()
    dapui.toggle({})
  end, "[d]ap [u]i")
  nmap_leader("de", function()
    dapui.eval()
  end, "[d]ap [e]val")
end)

local function set_goos(goos)
  if goos == nil then
    vim.env.GOOS = nil
    vim.notify("GOOS unset (using host OS)")
  else
    vim.env.GOOS = goos
    vim.notify("GOOS set to " .. goos)
  end
  vim.cmd("lsp restart gopls")
end

vim.api.nvim_create_user_command("GoOS", function()
  local pick = require("mini.pick")

  local items = {
    { text = "unset (host default)", goos = nil },
    { text = "windows", goos = "windows" },
    { text = "linux", goos = "linux" },
    { text = "darwin", goos = "darwin" },
    { text = "freebsd", goos = "freebsd" },
  }

  pick.start({
    source = {
      name = ("Select GOOS (current: %s)"):format(vim.env.GOOS or "unset"),
      items = items,
      choose = function(item)
        if item then
          set_goos(item.goos)
        end
      end,
    },
  })
end, {})

local function complete_packages()
  return vim
    .iter(vim.pack.get())
    :map(function(pack)
      return pack.spec.name
    end)
    :totable()
end

vim.api.nvim_create_user_command("PackUpdate", function(info)
  if #info.fargs ~= 0 then
    vim.pack.update(info.fargs, { force = info.bang })
  else
    vim.pack.update(nil, { force = info.bang })
  end
end, {
  desc = "Update packages",
  nargs = "*",
  bang = true,
  complete = complete_packages,
})

vim.api.nvim_create_user_command("PackDelete", function(info)
  vim.pack.del(info.fargs, { force = info.bang })
end, {
  desc = "Delete packages",
  nargs = "+",
  bang = true,
  complete = complete_packages,
})

vim.api.nvim_create_user_command("PackClean", function()
  local clean = vim
    .iter(vim.pack.get())
    :filter(function(pack)
      return not pack.active
    end)
    :map(function(pack)
      return pack.spec.name
    end)
    :totable()
  vim.pack.del(clean)
end, { desc = "Delete all inactive packages" })

later(function()
  add({ "https://github.com/mfussenegger/nvim-lint" })

  require("lint").linters_by_ft = {
    php = { "phpstan", "phpcs" },
  }

  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end)
