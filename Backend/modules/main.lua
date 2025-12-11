-- main.lua
-- Central loader for Nakama Lua modules. Uses safe_require so a broken module
-- doesn't stop the whole runtime from starting.

local nk = require("nakama")

-- 0) Optional helpers (non-fatal)
pcall(function() require("main_helpers") end)

-- Helper: safely require a module and log any error without crashing startup.
local function safe_require(name)
  local ok, result = pcall(require, name)
  if not ok then
    -- result contains the error message when pcall fails
    nk.logger_error("main.lua: require '" .. name .. "' failed: " .. tostring(result))
    return nil, result
  end
  nk.logger_info("main.lua: required '" .. name .. "'")
  return result, nil
end

-- 1) Low-level helpers that other modules depend on should be loaded first.
-- Ensure you have ./modules/utils_rpc.lua (it provides parse_rpc_payload etc.)
safe_require("utils_rpc")

-- 2) Register core RPCs that create/update user storage and support account lifecycle.
-- Load cleanup early so it is available (you may also want it scheduled / called by admin).
local rpc_first = {
  "create_guest_profile",
  "create_user",
  "convert_guest_to_permanent",
  "admin_delete_account",
  "guest_cleanup"
}

for _, m in ipairs(rpc_first) do
  safe_require(m)
end

-- 3) Load match and gameplay modules (ludo_match + any authoritative match handlers).
-- If ludo_match.lua returns a match module table, Nakama will register it automatically.
local match_mod, match_err = safe_require("ludo_match")
if not match_mod then
  nk.logger_warn("main.lua: ludo_match not loaded or returned nil: " .. tostring(match_err))
end

-- 4) Load RPCs that depend on match or general services (load after match if needed).
local rpc_late = {
  "rpc_quick_join",
  "rpc_player_list",
  "rpc_match_start"
}

for _, m in ipairs(rpc_late) do
  safe_require(m)
end

-- 5) Final startup log
nk.logger_info("main.lua loaded: runtime modules required and RPCs registered.")
