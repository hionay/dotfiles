return {
  settings = {
    gopls = {
      gofumpt = true,
      codelenses = {
        generate = true,
        regenerate_cgo = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
      },
      analyses = {
        nilness = true,
        unusedparams = true,
        unusedwrite = true,
        useany = true,
      },
      hints = {
        parameterNames = true,
        assignVariableTypes = true,
        constantValues = true,
        compositeLiteralTypes = true,
        compositeLiteralFields = true,
        functionTypeParameters = true,
      },
      usePlaceholders = false,
      staticcheck = true,
    },
  },
}
