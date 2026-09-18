local GFK = GazetteerFieldKit
GFK.Events = {}

local seenGuids = {}
local seenGossip = {}
local lastLootSig
local lastInstanceKey
local lastInstance

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

local function creatureId(guid)
  return guid and guid:match("^Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
end

local function objectId(guid)
  return guid and guid:match("^GameObject%-%d+%-%d+%-%d+%-%d+%-(%d+)%-")
end

local function interactUnit()
  if UnitExists("npc") then
    return "npc"
  end
  if UnitExists("target") then
    return "target"
  end
end

local function interactNpc()
  local unit = interactUnit()
  if not unit then
    return nil, nil, nil
  end
  local guid = UnitGUID(unit)
  return UnitName(unit), guid, creatureId(guid)
end

local function questTitle(questId)
  if questId and C_QuestLog and C_QuestLog.GetTitleForQuestID then
    local title = C_QuestLog.GetTitleForQuestID(questId)
    if title and title ~= "" then
      return title
    end
  end
  if GetTitleText then
    local title = GetTitleText()
    if title and title ~= "" then
      return title
    end
  end
end

local function itemIdFromLink(link)
  return link and link:match("|Hitem:(%d+)")
end

local function lootItems()
  local n = GetNumLootItems and GetNumLootItems() or 0
  local items = {}
  for slot = 1, n do
    local _, name, quantity, d, e, f, g = GetLootSlotInfo(slot)
    local quality, locked, isQuestItem
    if type(e) == "boolean" then
      quality, locked = d, e
    else
      quality, locked, isQuestItem = e, f, g
    end
    local link = GetLootSlotLink and GetLootSlotLink(slot) or nil
    local sourceGuid
    if GetLootSourceInfo then
      sourceGuid = GetLootSourceInfo(slot)
    end
    items[#items + 1] = {
      name = name,
      quantity = quantity,
      quality = quality,
      itemId = itemIdFromLink(link),
      locked = locked,
      isQuestItem = isQuestItem,
      sourceGuid = sourceGuid,
      sourceNpcId = creatureId(sourceGuid),
      sourceObjectId = objectId(sourceGuid),
    }
  end
  return items
end

local function lootSig(items)
  local parts = {}
  for i = 1, #items do
    local it = items[i]
    parts[#parts + 1] = tostring(it.itemId or it.name or "") .. ":" .. tostring(it.quantity or 0)
  end
  return table.concat(parts, ",")
end

local function gossipFromC()
  local available, active = {}, {}
  if not C_GossipInfo then
    return nil
  end
  local function copy(list, dest)
    if not list then
      return
    end
    for _, q in pairs(list) do
      if type(q) == "table" then
        dest[#dest + 1] = {
          questId = q.questID or q.questId,
          title = q.title,
        }
      end
    end
  end
  if C_GossipInfo.GetAvailableQuests then
    copy(C_GossipInfo.GetAvailableQuests(), available)
  end
  if C_GossipInfo.GetActiveQuests then
    copy(C_GossipInfo.GetActiveQuests(), active)
  end
  return available, active
end

local function packOldGossip(dest, getter)
  if not getter then
    return
  end
  local raw = { getter() }
  -- Classic: title, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored (repeat)
  local i = 1
  while raw[i] do
    dest[#dest + 1] = { title = raw[i] }
    i = i + 7
  end
end

local function greetingQuests()
  local available, active = {}, {}
  local nAvail = GetNumAvailableQuests and GetNumAvailableQuests() or 0
  for i = 1, nAvail do
    available[#available + 1] = {
      title = GetAvailableTitle and GetAvailableTitle(i) or nil,
    }
  end
  local nActive = GetNumActiveQuests and GetNumActiveQuests() or 0
  for i = 1, nActive do
    active[#active + 1] = {
      title = GetActiveTitle and GetActiveTitle(i) or nil,
    }
  end
  return available, active
end

local function gossipSig(guid, available, active)
  local parts = { guid or "" }
  local function ids(list)
    for i = 1, #list do
      parts[#parts + 1] = tostring(list[i].questId or list[i].title or "")
    end
  end
  ids(available)
  ids(active)
  return table.concat(parts, "|")
end

local function logGossip(available, active)
  local name, guid, npcId = interactNpc()
  local sig = gossipSig(guid, available, active)
  if seenGossip[sig] then
    return
  end
  seenGossip[sig] = true
  add("gossip", {
    name = name,
    guid = guid,
    npcId = npcId,
    available = available,
    active = active,
  })
end

local function checkInstance()
  if not GetInstanceInfo then
    return
  end
  local name, instanceType, difficultyID, difficultyName, maxPlayers, _, _, instanceID = GetInstanceInfo()
  local inInst = instanceType and instanceType ~= "" and instanceType ~= "none"
  if not inInst then
    if lastInstance then
      add("instance_leave", {
        name = lastInstance.name,
        instanceType = lastInstance.instanceType,
        difficultyID = lastInstance.difficultyID,
        difficultyName = lastInstance.difficultyName,
        maxPlayers = lastInstance.maxPlayers,
        instanceID = lastInstance.instanceID,
      })
      lastInstance = nil
      lastInstanceKey = nil
    end
    return
  end
  local key = tostring(instanceType) .. ":" .. tostring(instanceID or name)
  if lastInstanceKey == key then
    return
  end
  lastInstanceKey = key
  lastInstance = {
    name = name,
    instanceType = instanceType,
    difficultyID = difficultyID,
    difficultyName = difficultyName,
    maxPlayers = maxPlayers,
    instanceID = instanceID,
  }
  add("instance_enter", {
    name = name,
    instanceType = instanceType,
    difficultyID = difficultyID,
    difficultyName = difficultyName,
    maxPlayers = maxPlayers,
    instanceID = instanceID,
  })
end

function GFK.Events:ClearSeen()
  seenGuids = {}
  seenGossip = {}
  lastLootSig = nil
end

function GFK.Events:Register()
  local f = CreateFrame("Frame")
  f:RegisterEvent("LOOT_READY")
  f:RegisterEvent("CHAT_MSG_LOOT")
  f:RegisterEvent("QUEST_ACCEPTED")
  f:RegisterEvent("QUEST_TURNED_IN")
  f:RegisterEvent("PLAYER_TARGET_CHANGED")
  f:RegisterEvent("GOSSIP_SHOW")
  f:RegisterEvent("QUEST_GREETING")
  f:RegisterEvent("PLAYER_ENTERING_WORLD")
  f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
  f:SetScript("OnEvent", function(_, event, ...)
    if event == "LOOT_READY" then
      local items = lootItems()
      if #items == 0 then
        return
      end
      local sig = lootSig(items)
      if sig == lastLootSig then
        return
      end
      lastLootSig = sig
      local src = UnitGUID("target")
      if not src or src == "" then
        src = items[1] and items[1].sourceGuid
      end
      add("loot_ready", {
        sourceGuid = src,
        sourceNpcId = creatureId(src),
        sourceObjectId = objectId(src),
        items = items,
      })
    elseif event == "CHAT_MSG_LOOT" then
      local text, playerName = ...
      local me = UnitName("player")
      if playerName and playerName ~= "" and me and playerName ~= me then
        return
      end
      add("chat_loot", { text = text })
    elseif event == "QUEST_ACCEPTED" then
      local first, second = ...
      local questId = second
      if not questId and first then
        if C_QuestLog and C_QuestLog.GetQuestIDForLogIndex then
          questId = C_QuestLog.GetQuestIDForLogIndex(first)
        end
        questId = questId or first
      end
      local npcName, npcGuid, npcId = interactNpc()
      add("quest_accepted", {
        questId = questId,
        title = questTitle(questId),
        npcName = npcName,
        npcGuid = npcGuid,
        npcId = npcId,
      })
    elseif event == "QUEST_TURNED_IN" then
      local questId = ...
      local npcName, npcGuid, npcId = interactNpc()
      add("quest_turned_in", {
        questId = questId,
        title = questTitle(questId),
        npcName = npcName,
        npcGuid = npcGuid,
        npcId = npcId,
      })
    elseif event == "PLAYER_TARGET_CHANGED" then
      if not UnitExists("target") then
        return
      end
      local guid = UnitGUID("target")
      if not guid or not guid:find("^Creature%-") then
        return
      end
      if seenGuids[guid] then
        return
      end
      seenGuids[guid] = true
      add("target", {
        name = UnitName("target"),
        guid = guid,
        npcId = creatureId(guid),
      })
    elseif event == "GOSSIP_SHOW" then
      local available, active = gossipFromC()
      if not available then
        available, active = {}, {}
        packOldGossip(available, GetGossipAvailableQuests)
        packOldGossip(active, GetGossipActiveQuests)
      end
      logGossip(available, active)
    elseif event == "QUEST_GREETING" then
      local available, active = greetingQuests()
      logGossip(available, active)
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
      checkInstance()
    end
  end)
end
