local Utils = require("core.utils")

local catalog = Utils.read_json_schemas()

-- automatically download and cache json schemas
if not catalog then
  vim.notify("Can't find JSON Schemas Catalog, downloading...")
  Utils.download_json_schemas()
  catalog = Utils.read_json_schemas()
  vim.notify("Done downloading JSON Schemas Catalog")
end

if catalog then
  local opts = {
    settings = {
      json = {
        schemas = catalog.schemas,
      },
    },
  }
  return opts
else
  return {}
end
