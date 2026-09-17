local GFK = GazetteerFieldKit
GFK.Events = {}

local function where()
  local map = GetRealZoneText()
  local mapID = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local x, y
  if mapID and C_Map.GetPlayerMapPosition then
    local pos = C_Map.GetPlayerMapPosition(mapID, "player")
    if pos then
      x = pos.x
      y = pos.y
    end
  end
  return { map = map, mapID = mapID, x = x, y = y }
end

local function add(kind, payload)
  payload = payload or {}
  local loc = where()
  payload.map = loc.map
  payload.mapID = loc.mapID
  payload.x = loc.x
  payload.y = loc.y
  GFK.DB:Add(kind, payload)
end

function GFK.Events:Register()
  local f = CreateFrame("Frame")
  f:RegisterEvent("LOOT_READY")
  f:RegisterEvent("CHAT_MSG_LOOT")
  f:RegisterEvent("QUEST_ACCEPTED")
  f:RegisterEvent("QUEST_TURNED_IN")
  f:RegisterEvent("PLAYER_TARGET_CHANGED")
  f:SetScript("OnEvent", function(_, event, ...)
    if event == "LOOT_READY" then
      add("loot_ready", { lootable = ... })
    elseif event == "CHAT_MSG_LOOT" then
      local text = ...
      add("chat_loot", { text = text })
    elseif event == "QUEST_ACCEPTED" then
      local _, questId = ...
      add("quest_accepted", { questId = questId })
    elseif event == "QUEST_TURNED_IN" then
      local questId = ...
      add("quest_turned_in", { questId = questId })
    elseif event == "PLAYER_TARGET_CHANGED" then
      if UnitExists("target") then
        add("target", {
          name = UnitName("target"),
          guid = UnitGUID("target"),
        })
      end
    end
  end)
end
