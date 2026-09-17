-- Gazetteer Field Kit
-- Free companion for forevergazetteer.com
-- No ads, no donations, no in-game prompts, no network calls.

GazetteerFieldKit = GazetteerFieldKit or {}
local GFK = GazetteerFieldKit

GFK.VERSION = "0.1.0-beta"

function GFK:Print(msg)
  print("|cffc4a574GFK|r " .. tostring(msg))
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event, ...)
  if event == "ADDON_LOADED" then
    local name = ...
    if name == "GazetteerFieldKit" then
      GFK.DB:Init()
      local version, build, buildDate, toc = GetBuildInfo()
      GazetteerFieldKitDB.build = {
        version = version,
        build = build,
        date = buildDate,
        toc = toc,
        product = "forever",
      }
    end
  elseif event == "PLAYER_LOGIN" then
    GFK:Print("loaded " .. GFK.VERSION .. " — /gfk")
    GFK.Events:Register()
  end
end)

SLASH_GAZETTEERFIELDKIT1 = "/gfk"
SlashCmdList["GAZETTEERFIELDKIT"] = function(msg)
  msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "export" then
    GFK.DB:Export()
  elseif msg == "ui" or msg == "" then
    GFK.UI:Toggle()
  elseif msg == "clear" then
    GFK.DB:ClearSession()
    GFK:Print("session log cleared")
  else
    GFK:Print("/gfk  /gfk export  /gfk clear")
  end
end
