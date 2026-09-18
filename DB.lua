local GFK = GazetteerFieldKit
GFK.DB = {}

function GFK.DB:Init()
  GazetteerFieldKitDB = GazetteerFieldKitDB or {}
  local db = GazetteerFieldKitDB
  db.version = GFK.VERSION
  db.events = db.events or {}
  -- Older builds copied every row into session; drop it so logout does not rewrite a duplicate table.
  db.session = nil
end

function GFK.DB:Add(kind, payload)
  local row = {
    t = time(),
    kind = kind,
    data = payload or {},
  }
  table.insert(GazetteerFieldKitDB.events, row)
  if GFK.UI and GFK.UI.Refresh then
    GFK.UI:Refresh()
  end
end

function GFK.DB:Last(n)
  n = n or 20
  local events = GazetteerFieldKitDB.events or {}
  local out = {}
  local start = math.max(1, #events - n + 1)
  for i = start, #events do
    out[#out + 1] = events[i]
  end
  return out
end

function GFK.DB:ClearSession()
  if GFK.Events and GFK.Events.ClearSeen then
    GFK.Events:ClearSeen()
  end
end

function GFK.DB:Export()
  local events = GazetteerFieldKitDB.events or {}
  GFK:Print(#events .. " events stored. Upload is not in-game; SavedVariables file after logout.")
end
