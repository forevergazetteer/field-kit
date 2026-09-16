local GFK = GazetteerFieldKit
GFK.UI = {}

function GFK.UI:Toggle()
  if not self.frame then
    self:Create()
  end
  if self.frame:IsShown() then
    self.frame:Hide()
  else
    self:Refresh()
    self.frame:Show()
  end
end

function GFK.UI:Create()
  local f = CreateFrame("Frame", "GFKLogFrame", UIParent, "BasicFrameTemplateWithInset")
  f:SetSize(360, 280)
  f:SetPoint("CENTER")
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()
  f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  f.title:SetPoint("TOP", 0, -6)
  f.title:SetText("Gazetteer Field Kit")
  f.body = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  f.body:SetPoint("TOPLEFT", 16, -36)
  f.body:SetPoint("BOTTOMRIGHT", -16, 16)
  f.body:SetJustifyH("LEFT")
  f.body:SetJustifyV("TOP")
  self.frame = f
end

function GFK.UI:Refresh()
  if not self.frame then
    return
  end
  local lines = {}
  for _, row in ipairs(GFK.DB:Last(20)) do
    lines[#lines + 1] = (row.kind or "?")
  end
  if #lines == 0 then
    self.frame.body:SetText("No events yet.")
  else
    self.frame.body:SetText(table.concat(lines, "\n"))
  end
end
