-- ludo_match.lua
local M = {}

function M.match_init(context, params)
  local state = {
    players = {},
    created_at = os.time()
  }
  -- Tick rate of 1 = 1 call to match_loop per second
  local tick_rate = 1
  return state, tick_rate
end

function M.match_join_attempt(context, dispatcher, tick, state, presence, metadata)
  -- Accept all join attempts for now
  local accept = true
  local reject_reason = nil
  return state, accept, reject_reason
end

function M.match_join(context, dispatcher, tick, state, presences)
  for _, p in ipairs(presences) do
    state.players[p.user_id] = p
    nk.logger_info("Player joined: " .. p.user_id)
  end
  return state
end

function M.match_leave(context, dispatcher, tick, state, presences)
  for _, p in ipairs(presences) do
    state.players[p.user_id] = nil
    nk.logger_info("Player left: " .. p.user_id)
  end
  return state
end

function M.match_loop(context, dispatcher, tick, state, messages)
  -- Add your game logic here
  return state
end

function M.match_terminate(context, dispatcher, tick, state, grace_seconds)
  return state
end

-- Crucial: Return the module table so Nakama can register it
return M