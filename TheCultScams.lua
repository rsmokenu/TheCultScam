-- <The Cult Scams> Core Logic - v4.5 [LAVENDER] TS: 11:10:40
local ADDON_MSG_PREFIX = "CultScams"
TheCultScamsCore = CreateFrame("Frame", "TheCultScamsCore")
local SCAM = TheCultScamsCore
SCAM:RegisterEvent("ADDON_LOADED"); SCAM:RegisterEvent("CHAT_MSG_ADDON"); SCAM:RegisterEvent("TRADE_SKILL_SHOW"); SCAM:RegisterEvent("CRAFT_SHOW"); SCAM:RegisterEvent("CHAT_MSG_WHISPER")
SCAM:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "TheCultScams" then  
        TheCultScamsDB = TheCultScamsDB or {}; TheCultScamsDB.Players = TheCultScamsDB.Players or {}; TheCultScamsDB.Messages = TheCultScamsDB.Messages or {}
        TheCultScamsDB.CustomGroups = TheCultScamsDB.CustomGroups or { ["General"] = {} }
        DEFAULT_CHAT_FRAME:AddMessage("|cffe6e6fa<The Cult Scams>|r v4.5 [LAVENDER] Loaded.")
    elseif event == "CHAT_MSG_ADDON" and arg1 == ADDON_MSG_PREFIX then SCAM:ProcessIncomingScam(arg4, arg2)
    elseif event == "CHAT_MSG_WHISPER" then
        local g, t = string.match(arg1, "^SCAM_GRP:(.-):(.*)")
        if g and t then TheCultScamsDB.Messages[g] = TheCultScamsDB.Messages[g] or {}; table.insert(TheCultScamsDB.Messages[g], { sender = arg2, text = t, time = time() }); if TheCultScams_UpdateGUI then TheCultScams_UpdateGUI() end end
    elseif event == "TRADE_SKILL_SHOW" then SCAM:ScanTradeSkills()
    elseif event == "CRAFT_SHOW" then SCAM:ScanCrafts() end
end)
function SCAM:ScanTradeSkills()
    local prof = GetTradeSkillLine(); if not prof or prof == "UNKNOWN" then return end
    local pName = UnitName("player"); TheCultScamsDB.Players[pName] = TheCultScamsDB.Players[pName] or {}; TheCultScamsDB.Players[pName][prof] = {}
    for i=1, GetNumTradeSkills() do
        local n, t = GetTradeSkillInfo(i); if n and t ~= "header" then
            local l = GetTradeSkillItemLink(i); local rStr = ""
            for rIdx=1, GetTradeSkillNumReagents(i) do local rn, _, rc = GetTradeSkillReagentInfo(i, rIdx); rStr = rStr .. rn .. " x" .. rc .. ", " end
            rStr = (rStr == "") and "None" or string.sub(rStr, 1, -3)
            if l then TheCultScamsDB.Players[pName][prof][n] = { link = l, mats = rStr }; local msg = "CRAFT\t" .. prof .. "\t" .. n .. "\t" .. l .. "\t" .. rStr; SendAddonMessage(ADDON_MSG_PREFIX, (string.len(msg) > 250 and string.sub(msg, 1, 247).."..." or msg), "GUILD") end
        end
    end
    if TheCultScams_UpdateGUI then TheCultScams_UpdateGUI() end
end
function SCAM:ScanCrafts()
    local prof = GetCraftDisplaySkillLine(); if not prof then return end
    local pName = UnitName("player"); TheCultScamsDB.Players[pName] = TheCultScamsDB.Players[pName] or {}; TheCultScamsDB.Players[pName][prof] = {}
    for i=1, GetNumCrafts() do
        local n, _, t = GetCraftInfo(i); if n and t ~= "header" then
            local l = GetCraftItemLink(i) or n; local rStr = ""
            for rIdx=1, GetCraftNumReagents(i) do local rn, _, rc = GetTradeSkillReagentInfo(i, rIdx); rStr = rStr .. rn .. " x" .. rc .. ", " end
            rStr = (rStr == "") and "None" or string.sub(rStr, 1, -3)
            TheCultScamsDB.Players[pName][prof][n] = { link = l, mats = rStr }; local msg = "CRAFT\t" .. prof .. "\t" .. n .. "\t" .. l .. "\t" .. rStr; SendAddonMessage(ADDON_MSG_PREFIX, (string.len(msg) > 250 and string.sub(msg, 1, 247).."..." or msg), "GUILD")
        end
    end
    if TheCultScams_UpdateGUI then TheCultScams_UpdateGUI() end
end
function SCAM:ProcessIncomingScam(sender, msg)
    local d = {}; for p in string.gfind(msg, "([^\t]+)") do table.insert(d, p) end
    if d[1] == "CRAFT" and d[5] then TheCultScamsDB.Players[sender] = TheCultScamsDB.Players[sender] or {}; TheCultScamsDB.Players[sender][d[2]] = TheCultScamsDB.Players[sender][d[2]] or {}; TheCultScamsDB.Players[sender][d[2]][d[3]] = { link = d[4], mats = d[5] }
    elseif d[1] == "MSG" and d[3] then TheCultScamsDB.Messages[d[2]] = TheCultScamsDB.Messages[d[2]] or {}; table.insert(TheCultScamsDB.Messages[d[2]], { sender = sender, text = d[3], time = time() }) end
    if TheCultScams_UpdateGUI then TheCultScams_UpdateGUI() end
end
function SCAM:SendGroupMessage(group, text)
    local players = TheCultScamsDB.CustomGroups[group]; if players then for p in pairs(players) do SendChatMessage("SCAM_GRP:"..group..":"..text, "WHISPER", nil, p) end end
    TheCultScamsDB.Messages[group] = TheCultScamsDB.Messages[group] or {}; table.insert(TheCultScamsDB.Messages[group], { sender = UnitName("player"), text = text, time = time() }); if TheCultScams_UpdateGUI then TheCultScams_UpdateGUI() end
end
SLASH_SCAM1, SLASH_SCAM2 = "/scam", "/scamsync"
SlashCmdList["SCAM"] = function(msg) if msg == "sync" then SCAM:ScanTradeSkills(); SCAM:ScanCrafts(); return end; if TheCultScams_MobileFrame:IsVisible() then TheCultScams_MobileFrame:Hide() else TheCultScams_MobileFrame:Show() end end