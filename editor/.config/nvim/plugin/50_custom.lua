vim.o.swapfile = false

local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end
local nxmap_leader = function(suffix, rhs, desc)
  vim.keymap.set({ "n", "x" }, "<Leader>" .. suffix, rhs, { desc = desc })
end

local add = vim.pack.add
local now, later = Config.now, Config.later

now(function()
  add({ "https://github.com/rebelot/kanagawa.nvim" })

  require("kanagawa").setup({
    compile = false,
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
  add({ "https://github.com/mfussenegger/nvim-dap" })
  add({ "https://github.com/igorlfs/nvim-dap-view" })
  add({ "https://github.com/leoluz/nvim-dap-go" })
  add({ "https://github.com/theHamsta/nvim-dap-virtual-text" })

  local dap = require("dap")
  local dv = require("dap-view")
  local dg = require("dap-go")

  dv.setup()
  dg.setup()
  require("nvim-dap-virtual-text").setup({})

  for _, ev in ipairs({ "attach", "launch" }) do
    dap.listeners.before[ev]["dap-view"] = function()
      dv.open()
    end
  end
  for _, ev in ipairs({ "event_terminated", "event_exited" }) do
    dap.listeners.before[ev]["dap-view"] = function()
      dv.close()
    end
  end

  nmap_leader("db", dap.toggle_breakpoint, "[d]ebug [b]reakpoint")
  nmap_leader("dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, "[d]ebug [B]reakpoint (conditional)")
  nmap_leader("dc", dap.continue, "[d]ebug [c]ontinue")
  nmap_leader("dC", dap.run_to_cursor, "[d]ebug run to [C]ursor")
  nmap_leader("dg", dap.goto_, "[d]ebug [g]o to line")
  nmap_leader("do", dap.step_over, "[d]ebug step [o]ver")
  nmap_leader("di", dap.step_into, "[d]ebug step [i]nto")
  nmap_leader("dO", dap.step_out, "[d]ebug step [O]ut")
  nmap_leader("dt", dap.terminate, "[d]ebug [t]erminate")
  nmap_leader("du", function()
    dv.toggle()
  end, "[d]ebug [u]i toggle")
  nmap_leader("de", function()
    require("dap-view").eval()
  end, "[d]ebug [e]val")
  nmap_leader("dn", dg.debug_test, "[d]ebug [n]earest test")
  nmap_leader("dL", dg.debug_last_test, "[d]ebug [L]ast test")
end)

later(function()
  add({ "https://github.com/antoinemadec/FixCursorHold.nvim" })
  add({ "https://github.com/nvim-neotest/nvim-nio" })
  add({ "https://github.com/nvim-neotest/neotest" })
  add({ "https://github.com/nvim-neotest/neotest-plenary" })
  add({ "https://github.com/nvim-neotest/neotest-vim-test" })
  add({ "https://github.com/fredrikaverpil/neotest-golang" })

  local neotest = require("neotest")

  neotest.setup({
    adapters = {
      require("neotest-golang")({
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
    php = { "phpstan", "phpcs", "psalm", "php" },
    typescript = { "eslint" },
    javascript = { "eslint" },
  }

  local psalm = require("lint").linters.psalm
  psalm.ignore_exitcode = true

  vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
    callback = function()
      require("lint").try_lint()
    end,
  })
end)

vim.lsp.codelens.enable(true)

vim.opt.fillchars:append({
  diff = "╱",
  msgsep = "‾",
})

later(function()
  add({ "https://github.com/folke/sidekick.nvim" })

  local sidekick = require("sidekick")
  local cli = require("sidekick.cli")

  sidekick.setup({
    nes = { enabled = false },
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
  })

  vim.keymap.set("n", "<Tab>", function()
    if not sidekick.nes_jump_or_apply() then
      return "<Tab>"
    end
  end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

  vim.keymap.set({ "n", "t", "i", "x" }, "<C-.>", function()
    cli.toggle({ name = "claude" })
  end, { desc = "Sidekick Toggle Claude" })

  nmap_leader("aa", function()
    cli.toggle()
  end, "Sidekick Toggle Cli")
  nmap_leader("as", function()
    cli.select()
  end, "Select CLI")
  nmap_leader("ad", function()
    cli.close()
  end, "Detach a CLI Session")
  nmap_leader("af", function()
    cli.send({ msg = "{file}" })
  end, "Send File")
  nmap_leader("ac", function()
    cli.toggle({ name = "claude", focus = true })
  end, "Sidekick Toggle Claude")

  nxmap_leader("at", function()
    cli.send({ msg = "{this}" })
  end, "Send This")
  nxmap_leader("av", function()
    cli.send({ msg = "{selection}" })
  end, "Send Visual Selection")
  nxmap_leader("ap", function()
    cli.prompt()
  end, "Sidekick Select Prompt")
end)

later(function()
  add({ "https://github.com/zbirenbaum/copilot.lua" })

  require("copilot").setup({
    panel = { enabled = false },
    suggestion = {
      enabled = true,
      auto_trigger = true,
      hide_during_completion = true,
      debounce = 75,
      keymap = {
        accept = false,
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    nes = { enabled = false },
    filetypes = {
      markdown = true,
      gitcommit = true,
    },
  })

  vim.keymap.set("i", "<C-y>", function()
    local ok, s = pcall(require, "copilot.suggestion")
    if ok and s.is_visible() then
      s.accept()
    end
  end, { desc = "Copilot accept suggestion" })

  vim.api.nvim_create_autocmd("CompleteChanged", {
    callback = function()
      vim.b.copilot_suggestion_hidden = true
    end,
  })
  vim.api.nvim_create_autocmd("CompleteDone", {
    callback = function()
      vim.b.copilot_suggestion_hidden = false
    end,
  })
end)
