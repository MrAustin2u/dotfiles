local utils = require("utils")

local catalog = utils.read_json_schemas()

-- automatically download and cache json schemas
if not catalog then
  vim.notify("Can't find JSON Schemas Catalog, downloading...")
  utils.download_json_schemas()
  catalog = utils.read_json_schemas()
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
