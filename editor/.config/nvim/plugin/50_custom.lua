-- Helpers
local nmap_leader = function(suffix, rhs, desc)
  vim.keymap.set("n", "<Leader>" .. suffix, rhs, { desc = desc })
end
local nxmap_leader = function(suffix, rhs, desc)
  vim.keymap.set({ "n", "x" }, "<Leader>" .. suffix, rhs, { desc = desc })
end

local add = vim.pack.add
local now, later = Config.now, Config.later

-- Package management commands
local function complete_packages()
  return vim
    .iter(vim.pack.get())
    :map(function(pack)
      return pack.spec.name
    end)
    :totable()
end

vim.api.nvim_create_user_command("PackUpdate", function(info)
  vim.pack.update(#info.fargs > 0 and info.fargs or nil, { force = info.bang })
end, { desc = "Update packages", nargs = "*", bang = true, complete = complete_packages })

vim.api.nvim_create_user_command("PackDelete", function(info)
  vim.pack.del(info.fargs, { force = info.bang })
end, { desc = "Delete packages", nargs = "+", bang = true, complete = complete_packages })

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

-- Colorscheme
now(function()
  add({ "https://github.com/rebelot/kanagawa.nvim" })

  require("kanagawa").setup({
    compile = false,
    transparent = true,
    colors = {
      theme = { all = { ui = { bg_gutter = "none" } } },
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
    background = { dark = "dragon", light = "lotus" },
  })

  vim.cmd("color kanagawa")
end)

-- LSP
later(function()
  vim.lsp.codelens.enable(true)
end)

-- Git
later(function()
  add({
    "https://github.com/esmuellert/codediff.nvim",
    "https://github.com/NeogitOrg/neogit",
  })

  require("neogit").setup({
    graph_style = "kitty",
    diff_viewer = "codediff",
    integrations = { codediff = true, mini_pick = true },
  })

  nmap_leader("gg", function()
    require("neogit").open()
  end, "Show Neogit")
end)

-- Navigation
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

-- Wakatime
later(function()
  add({ "https://github.com/wakatime/vim-wakatime" })
end)

-- Linting
later(function()
  add({ "https://github.com/mfussenegger/nvim-lint" })

  local lint = require("lint")

  lint.linters_by_ft = {
    php = { "phpstan", "phpcs", "psalm", "php" },
    typescript = { "eslint" },
    javascript = { "eslint" },
  }

  lint.linters.psalm.ignore_exitcode = true

  local group = vim.api.nvim_create_augroup("nvim-lint", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    callback = function()
      lint.try_lint()
    end,
  })
  vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function()
      -- phpstan, phpcs and psalm are too slow to run on every file open
      lint.try_lint(vim.bo.filetype == "php" and { "php" } or nil)
    end,
  })
end)

-- Debug (DAP)
later(function()
  add({ "https://github.com/mfussenegger/nvim-dap" })
  add({ "https://github.com/igorlfs/nvim-dap-view" })
  add({ "https://github.com/leoluz/nvim-dap-go" })

  local dap = require("dap")
  local dv = require("dap-view")
  local dg = require("dap-go")

  dv.setup({
    auto_toggle = "keep_terminal",
    virtual_text = { enabled = true },
  })
  dg.setup()

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
    dv.eval()
  end, "[d]ebug [e]val")
  nmap_leader("dn", dg.debug_test, "[d]ebug [n]earest test")
  nmap_leader("dL", dg.debug_last_test, "[d]ebug [L]ast test")
end)

-- Testing (Neotest)
later(function()
  add({ "https://github.com/nvim-lua/plenary.nvim" })
  add({ "https://github.com/nvim-neotest/nvim-nio" })
  add({ "https://github.com/nvim-neotest/neotest" })
  add({ "https://github.com/nvim-neotest/neotest-plenary" })
  add({ "https://github.com/fredrikaverpil/neotest-golang" })
  add({ "https://github.com/olimorris/neotest-phpunit" })
  add({ "https://github.com/V13Axel/neotest-pest" })

  local neotest = require("neotest")

  neotest.setup({
    adapters = {
      require("neotest-golang")({
        go_test_args = function()
          return { "-v", "-race", "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out" }
        end,
      }),
      require("neotest-phpunit"),
      require("neotest-pest"),
      require("neotest-plenary"),
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

-- Go utilities
later(function()
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
    local items = {
      { text = "unset (host default)", goos = nil },
      { text = "windows", goos = "windows" },
      { text = "linux", goos = "linux" },
      { text = "darwin", goos = "darwin" },
      { text = "freebsd", goos = "freebsd" },
    }

    require("mini.pick").start({
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
end)

-- Sidekick (AI CLI)
later(function()
  add({ "https://github.com/folke/sidekick.nvim" })

  local cli = require("sidekick.cli")

  -- Forward Vertex AI vars from nvim's env: tmux panes spawned by sidekick
  -- don't run a login shell, so they never source zsh_secrets
  local vertex_env = {
    GOOGLE_CLOUD_PROJECT = vim.env.GOOGLE_CLOUD_PROJECT,
    GOOGLE_CLOUD_LOCATION = vim.env.GOOGLE_CLOUD_LOCATION,
    GOOGLE_GENAI_USE_VERTEXAI = vim.env.GOOGLE_GENAI_USE_VERTEXAI,
  }

  require("sidekick").setup({
    nes = { enabled = false },
    cli = {
      -- Use real tmux splits instead of :terminal so that OSC escape
      -- sequences (system theme detection) are properly proxied.
      mux = { backend = "tmux", enabled = true, create = "split" },
      tools = {
        agy = { cmd = { "agy" }, env = vertex_env },
        gemini = { cmd = { "gemini" }, env = vertex_env },
      },
    },
  })

  vim.keymap.set({ "n", "t", "i", "x" }, "<C-.>", function()
    cli.toggle({ name = "claude" })
  end, { desc = "Sidekick Toggle Claude" })

  nmap_leader("aa", cli.toggle, "Sidekick Toggle Cli")
  nmap_leader("as", cli.select, "Select CLI")
  nmap_leader("ad", cli.close, "Detach a CLI Session")
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
  nxmap_leader("ap", cli.prompt, "Sidekick Select Prompt")
end)
