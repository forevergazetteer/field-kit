local GFK = GazetteerFieldKit
GFK.DB = {}

function GFK.DB:Init()
  GazetteerFieldKitDB = GazetteerFieldKitDB or {}
  local db = GazetteerFieldKitDB
  db.version = GFK.VERSION
  db.events = db.events or {}
  db.session = db.session or {}
end

function GFK.DB:Add(kind, payload)
  local row = {
    t = time(),
    kind = kind,
    data = payload or {},
  }
  table.insert(GazetteerFieldKitDB.events, row)
  table.insert(GazetteerFieldKitDB.session, row)
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
  GazetteerFieldKitDB.session = {}
end

function GFK.DB:Export()
  local events = GazetteerFieldKitDB.events or {}
  GFK:Print(#events .. " events stored. Upload is not in-game; SavedVariables file after logout.")
end
