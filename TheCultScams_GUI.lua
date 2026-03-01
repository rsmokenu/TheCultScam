-- <The Cult Scams> Matte UI - v4.7 [KHAKI] TS: 11:31:02
local frame = CreateFrame("Frame", "TheCultScams_MobileFrame", UIParent)
frame:SetWidth(320); frame:SetHeight(450); frame:SetPoint("CENTER", 0, 0); frame:SetMovable(true); frame:SetResizable(true); frame:EnableMouse(true); frame:RegisterForDrag("LeftButton")
frame:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile=true, tileSize=32, edgeSize=16, insets={left=5,right=5,top=5,bottom=5}})
frame:SetBackdropColor(0.2, 0.2, 0.1, 0.95); frame:Hide()
local currentTab = "PLAYERS"; local currentGroup = "General"; local ExpandedPlayers = {}; local ExpandedProfs = {}

local function GetItemCountByName(name)
    if not name then return 0 end
    local count = 0; for bag=0, 4 do for slot=1, GetContainerNumSlots(bag) do local link = GetContainerItemLink(bag, slot); if link and string.find(link, name, 1, true) then local _, c = GetContainerItemInfo(bag, slot); count = count + c end end end
    return count
end

-- RECIPE CARD
local cb = CreateFrame("EditBox", "TheCultScams_Clipboard", frame, "InputBoxTemplate"); cb:SetWidth(200); cb:SetHeight(20); cb:SetPoint("CENTER", 0, 0); cb:SetFrameLevel(100); cb:Hide()
cb:SetScript("OnEscapePressed", function() this:Hide() end); cb:SetScript("OnEnterPressed", function() this:Hide() end)
local card = CreateFrame("Frame", "TheCultScams_RecipeCard", frame); card:SetWidth(280); card:SetHeight(180); card:SetPoint("CENTER", 0, 20); card:SetBackdrop({bgFile="Interface\\Tooltips\\UI-Tooltip-Background", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=12}); card:SetBackdropColor(0,0,0,1); card:SetFrameLevel(20); card:Hide(); card.rows = {}
for idx=1, 10 do local r = CreateFrame("Button", nil, card); r:SetWidth(260); r:SetHeight(16); r:SetPoint("TOPLEFT", 10, -30-(idx-1)*16); r.text = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); r.text:SetPoint("LEFT", 0, 0); r:RegisterForClicks("LeftButtonUp"); card.rows[idx] = r end
local cardTitle = card:CreateFontString(nil, "OVERLAY", "GameFontNormal"); cardTitle:SetPoint("TOP", 0, -10)
local function ShowRecipe(name, mats)
    if not name or not mats then return end
    cardTitle:SetText("|cffffff00"..name.."|r"); for _, r in pairs(card.rows) do r:Hide() end; local rowIdx = 1
    for m in string.gfind(mats, "([^,]+)") do if card.rows[rowIdx] then local r = card.rows[rowIdx]; r:Show(); m = string.gsub(m, "^%s*(.-)%s*$", "%1"); local mN, mC = string.match(m, "(.+) x(%d+)") or string.match(m, "(.+) %((%d+)%)"); if not mN then mN = m; mC = 1 end; local countInInv = GetItemCountByName(mN); local color = (countInInv >= tonumber(mC)) and "|cff00ff00" or "|cffaaaaaa"; r.text:SetText(color..m.." (Bag: "..countInInv..")|r"); r:SetScript("OnClick", function() cb:SetText(mN); cb:Show(); cb:SetFocus(); cb:HighlightText() end); rowIdx = rowIdx + 1 end end
    card:Show()
end

local function Row_OnClick()
    PlaySound("igMainMenuOptionCheckBoxOn")
    if this.action == "TOGGLE_PLAYER" then ExpandedPlayers[this.arg1] = not ExpandedPlayers[this.arg1]; TheCultScams_UpdateGUI()
    elseif this.action == "TOGGLE_PROF" then local pk = this.arg1.."_"..this.arg2; ExpandedProfs[pk] = not ExpandedProfs[pk]; TheCultScams_UpdateGUI()
    elseif this.action == "SHOW_RECIPE" then ShowRecipe(this.arg1, this.arg2)
    elseif this.action == "SELECT_GROUP" then currentGroup = this.arg1; TheCultScams_UpdateGUI()
    elseif this.action == "ADD_MEMBER" then StaticPopup_Show("SCAM_ADD_MEMBER")
    elseif this.action == "REMOVE_MEMBER" then TheCultScamsDB.CustomGroups[currentGroup][this.arg1] = nil; TheCultScams_UpdateGUI()
    elseif this.action == "WHISPER" then ChatFrame_OpenChat("/w " .. this.arg1 .. " ") end
end

local function CreateTab(id, text, x)
    local b = CreateFrame("Button", nil, frame); b:SetWidth(80); b:SetHeight(24); b:SetPoint("TOPLEFT", x, -35); b:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", edgeSize=12}); b:SetBackdropColor(0.15, 0.15, 0.1, 1); b.tabID = id; b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); b.text:SetPoint("CENTER", 0, 0); b.text:SetText(text); b:SetScript("OnClick", function() currentTab = this.tabID; TheCultScams_UpdateGUI() end)
end
CreateTab("PLAYERS", "ROSTER", 15); CreateTab("SEARCH", "SEARCH", 100); CreateTab("CHAT", "CHAT", 185)
local scrollFrame = CreateFrame("ScrollFrame", "TheCultScams_ScrollFrame", frame, "UIPanelScrollFrameTemplate"); scrollFrame:SetPoint("TOPLEFT", 15, -100); scrollFrame:SetPoint("BOTTOMRIGHT", -35, 60); local content = CreateFrame("Frame", nil, scrollFrame); content:SetWidth(250); content:SetHeight(100); scrollFrame:SetScrollChild(content); local rows = {}
local function GetRow(idx)
    if not rows[idx] then
        local r = CreateFrame("Button", "TheCultScamsRow"..idx, content)
        r:SetWidth(260); r:SetHeight(16); r:SetPoint("TOPLEFT", 0, -(idx-1)*16)
        r:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
        r:SetBackdropColor(1,1,1,0.05) -- Slight visible backdrop for hit testing
        r:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")
        r.text = r:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        r.text:SetPoint("LEFT", 5, 0)
        r:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        rows[idx] = r
    end
    rows[idx]:Show(); return rows[idx]
end
local groupInput = CreateFrame("EditBox", "TheCultScams_GroupInput", frame, "InputBoxTemplate"); groupInput:SetWidth(120); groupInput:SetHeight(20); groupInput:SetPoint("TOPLEFT", 15, -70); groupInput:SetAutoFocus(false); groupInput:Hide(); local groupBtn = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate"); groupBtn:SetWidth(60); groupBtn:SetHeight(20); groupBtn:SetPoint("LEFT", groupInput, "RIGHT", 5, 0); groupBtn:SetText("New"); groupBtn:Hide()
function TheCultScams_UpdateGUI()
    if not TheCultScamsDB then return end; for _, r in pairs(rows) do r:Hide() end; groupInput:Hide(); groupBtn:Hide(); card:Hide(); local rowIdx = 1
    local function AddRow(text, r, g, b, action, arg1, arg2) local row = GetRow(rowIdx); row.text:SetText(text); row.text:SetTextColor(r, g, b); row.action = action; row.arg1 = arg1; row.arg2 = arg2; row:SetScript("OnClick", Row_OnClick); rowIdx = rowIdx + 1 end
    if currentTab == "PLAYERS" then scrollFrame:SetPoint("TOPLEFT", 15, -70); local sortedPlayers = {}; for p in pairs(TheCultScamsDB.Players) do table.insert(sortedPlayers, p) end; table.sort(sortedPlayers); for _, p in ipairs(sortedPlayers) do local pData = TheCultScamsDB.Players[p]; local exp = ExpandedPlayers[p] and "[-] " or "[+] "; AddRow(exp.."|cffffff00["..p.."]|r", 1, 1, 1, "TOGGLE_PLAYER", p); if ExpandedPlayers[p] then for prof, recipes in pairs(pData) do local pk = p.."_"..prof; local prexp = ExpandedProfs[pk] and "  [-] " or "  [+] "; AddRow(prexp.."|cff00ff00"..prof.."|r", 0, 1, 0, "TOGGLE_PROF", p, prof); if ExpandedProfs[pk] then for rn, rd in pairs(recipes) do AddRow("    - "..rn, 0.8, 0.8, 0.8, "SHOW_RECIPE", rn, rd.mats) end end end end end
    elseif currentTab == "SEARCH" then local searchBox = getglobal("TheCultScams_SearchBox"); if searchBox then searchBox:Show() end; scrollFrame:SetPoint("TOPLEFT", 15, -100); local q = string.lower(getglobal("TheCultScams_SearchBox"):GetText() or ""); for p, pData in pairs(TheCultScamsDB.Players) do for prof, recipes in pairs(pData) do for rName, data in pairs(recipes) do if q ~= "" and string.find(string.lower(rName), q) then AddRow(data.link .. " (|cff00ff00" .. p .. "|r)", 1, 1, 1, "SHOW_RECIPE", rName, data.mats) end end end end
    elseif currentTab == "CHAT" then groupInput:Show(); groupBtn:Show(); scrollFrame:SetPoint("TOPLEFT", 15, -100); AddRow("|cff00ffff[GROUP MANAGER]|r", 0, 1, 1); for gName in pairs(TheCultScamsDB.CustomGroups) do local sel = (gName == currentGroup) and "> " or "  "; AddRow(sel..gName, 1, 1, 1, "SELECT_GROUP", gName); if gName == currentGroup and gName ~= "General" then AddRow("  |cff00ff00+ Add Member|r", 0, 1, 0, "ADD_MEMBER"); for mem in pairs(TheCultScamsDB.CustomGroups[gName]) do AddRow("    |cffff8000- "..mem.."|r", 1, 0.5, 0, "REMOVE_MEMBER", mem) end end end; AddRow("--- Messages ("..currentGroup..") ---", 0.5, 0.5, 0.5); local msgs = TheCultScamsDB.Messages[currentGroup] or {}; for _, m in ipairs(msgs) do AddRow("["..m.sender.."]: "..m.text, 0.8, 0.6, 0.8, "WHISPER", m.sender) end end
    content:SetHeight(rowIdx * 16)
end
StaticPopupDialogs["SCAM_ADD_MEMBER"] = { text = "Add player to " .. currentGroup, button1 = "Add", button2 = "Cancel", hasEditBox = 1, OnAccept = function() local n = getglobal(this:GetParent():GetName().."EditBox"):GetText(); if n ~= "" then TheCultScamsDB.CustomGroups[currentGroup][n] = true; TheCultScams_UpdateGUI() end end, timeout = 0, whileDead = 1, hideOnEscape = 1 }; groupBtn:SetScript("OnClick", function() local n = groupInput:GetText(); if n ~= "" then TheCultScamsDB.CustomGroups[n] = {}; TheCultScams_UpdateGUI() end end); frame:SetScript("OnShow", function() TheCultScams_UpdateGUI() end); frame:SetScript("OnDragStart", function() this:StartMoving() end); frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end); local resizer = CreateFrame("Button", nil, frame); resizer:SetWidth(10); resizer:SetHeight(10); resizer:SetPoint("BOTTOMRIGHT", 0, 0); resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up"); resizer:SetScript("OnMouseDown", function() this:GetParent():StartSizing("BOTTOMRIGHT") end); resizer:SetScript("OnMouseUp", function() this:GetParent():StopMovingOrSizing(); TheCultScams_UpdateGUI() end); local mainClose = CreateFrame("Button", "TheCultScams_MainCloseButton", frame, "UIPanelCloseButton"); mainClose:SetPoint("TOPRIGHT", -5, -5); mainClose:SetFrameLevel(10); mainClose:SetScript("OnClick", function() frame:Hide() end)
local searchBox = CreateFrame("EditBox", "TheCultScams_SearchBox", frame, "InputBoxTemplate"); searchBox:SetWidth(200); searchBox:SetHeight(20); searchBox:SetPoint("TOP", 0, -75); searchBox:SetAutoFocus(false); searchBox:SetScript("OnTextChanged", function() TheCultScams_UpdateGUI() end); searchBox:Hide()
local chatBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate"); chatBox:SetWidth(200); chatBox:SetHeight(20); chatBox:SetPoint("BOTTOMLEFT", 15, 35); chatBox:SetAutoFocus(false); chatBox:SetScript("OnEnterPressed", function() TheCultScamsCore:SendGroupMessage(currentGroup, this:GetText()); this:SetText(""); this:ClearFocus() end); local footer = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall"); footer:SetPoint("BOTTOM", 0, 10); footer:SetText("The Cult Scams v4.7 [KHAKI] TS: 11:31:02"); footer:SetTextColor(0.5, 0.5, 0.5); local cardClose = CreateFrame("Button", nil, card, "UIPanelCloseButton"); cardClose:SetPoint("TOPRIGHT", -2, -2)