local GFK = GazetteerFieldKit
GFK.Events = {}

function GFK.Events:Register()
  local f = CreateFrame("Frame")
  f:RegisterEvent("LOOT_READY")
  f:RegisterEvent("CHAT_MSG_LOOT")
  f:RegisterEvent("QUEST_ACCEPTED")
  f:RegisterEvent("QUEST_TURNED_IN")
  f:RegisterEvent("PLAYER_TARGET_CHANGED")
  f:SetScript("OnEvent", function(_, event, ...)
    if event == "LOOT_READY" then
      GFK.DB:Add("loot_ready", { lootable = ... })
    elseif event == "CHAT_MSG_LOOT" then
      local text = ...
      GFK.DB:Add("chat_loot", { text = text })
    elseif event == "QUEST_ACCEPTED" then
      local _, questId = ...
      GFK.DB:Add("quest_accepted", { questId = questId })
    elseif event == "QUEST_TURNED_IN" then
      local questId = ...
      GFK.DB:Add("quest_turned_in", { questId = questId })
    elseif event == "PLAYER_TARGET_CHANGED" then
      if UnitExists("target") then
        GFK.DB:Add("target", {
          name = UnitName("target"),
          guid = UnitGUID("target"),
        })
      end
    end
  end)
end
