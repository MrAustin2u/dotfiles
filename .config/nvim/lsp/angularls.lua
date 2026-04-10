local root_dir = vim.fn.getcwd()
local node_modules_dir = vim.fs.find("node_modules", { path = root_dir, upward = true })[1]
local project_root = node_modules_dir and vim.fs.dirname(node_modules_dir) or "?"

local function get_probe_dir()
  return project_root and (project_root .. "/node_modules") or ""
end

local function get_angular_core_version()
  if not project_root then
    return ""
  end

  local package_json = project_root .. "/package.json"
  if not vim.uv.fs_stat(package_json) then
    return ""
  end

  local file = io.open(package_json)
  if not file then
    return ""
  end
  local contents = file:read "*a"
  file:close()

  local ok, json = pcall(vim.json.decode, contents)
  if not ok or not json or not json.dependencies then
    return ""
  end

  local angular_core_version = json.dependencies["@angular/core"]

  angular_core_version = angular_core_version and angular_core_version:match "%d+%.%d+%.%d+"

  return angular_core_version
end

local default_probe_dir = get_probe_dir()
local default_angular_core_version = get_angular_core_version()

-- structure should be like
-- - $EXTENSION_PATH
--   - @angular
--     - language-server
--       - bin
--         - ngserver
--   - typescript
local ngserver_exe = vim.fn.exepath "ngserver"
local ngserver_path = #(ngserver_exe or "") > 0 and vim.fs.dirname(vim.uv.fs_realpath(ngserver_exe)) or "?"
local extension_path = vim.fs.normalize(vim.fs.joinpath(ngserver_path, "../../../"))

-- Resolve mise-installed typescript as an additional ts probe location so
-- ngserver can find `typescript/lib/tsserverlibrary` when the project's
-- node_modules doesn't provide TypeScript itself. mise installs typescript to
-- <mise>/installs/npm-typescript/<ver>/lib/node_modules/typescript/..., so its
-- `lib/` dir works as a node `require.resolve` probe base.
local function mise_typescript_probe_dir()
  local result = vim.fn.system { "mise", "where", "npm:typescript" }
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local path = vim.trim(result)
  if path == "" then
    return nil
  end
  local probe = vim.fs.joinpath(path, "lib")
  return (vim.uv.fs_stat(probe) ~= nil) and probe or nil
end

local mise_ts_probe = mise_typescript_probe_dir()

-- angularls will get module by `require.resolve(PROBE_PATH, MODULE_NAME)` of nodejs
local ts_probe_dirs = vim.iter({ default_probe_dir, extension_path, mise_ts_probe }):filter(function(p)
  return p ~= nil and p ~= ""
end):join ","
local ng_probe_dirs = vim
  .iter({ extension_path, default_probe_dir })
  :filter(function(p)
    return p ~= nil and p ~= ""
  end)
  :map(function(p)
    return vim.fs.joinpath(p, "/@angular/language-server/node_modules")
  end)
  :join ","

---@type vim.lsp.Config
return {
  cmd = {
    "ngserver",
    "--stdio",
    "--tsProbeLocations",
    ts_probe_dirs,
    "--ngProbeLocations",
    ng_probe_dirs,
    "--angularCoreVersion",
    default_angular_core_version,
  },
  filetypes = { "typescript", "html", "typescriptreact", "typescript.tsx", "htmlangular" },
  root_markers = { "angular.json", "nx.json" },
}
