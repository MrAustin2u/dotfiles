local schemaStoreSchemas = require('schemastore').yaml.schemas()

local ownSchemas = {
  ['http://json.schemastore.org/github-workflow'] = '.github/workflows/*',
  ['http://json.schemastore.org/github-action'] = '.github/action.{yml,yaml}',
  ['http://json.schemastore.org/prettierrc'] = '.prettierrc.{yml,yaml}',
}

local schemas = vim.list_extend(ownSchemas, schemaStoreSchemas)

return {
  setup = function()
    return {
      settings = {
        -- https://github.com/redhat-developer/vscode-redhat-telemetry#how-to-disable-telemetry-reporting
        redhat = { telemetry = { enabled = false } },

        yaml = {
          schemaStore = {
            -- Must disable built-in schemaStore support using the SchemaStore
            -- plugin and its advanced options like `ignore`.
            enable = false,
            -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
            url = '',
          },
          schemas = schemas,
          format = { enabled = false },
          validate = true,
          completion = true,
          hover = true,
        },
      },

      on_attach = function(_client, bufnr)
        -- disable and reset diagnostics for helm files (because the LS can't
        -- read them properly)
        if vim.bo[bufnr].buftype ~= '' or vim.bo[bufnr].filetype == 'helm' then
          vim.diagnostic.disable(bufnr)
          vim.defer_fn(function()
            vim.diagnostic.reset(nil, bufnr)
          end, 1000)
        end
      end,
    }
  end,
}
