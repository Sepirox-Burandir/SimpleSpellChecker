-- SimpleSpellChecker for WoW Patch 1.12.1 (Vanilla Client)
-- Part 1: Database and Main Frame Setup

local SpellData = {
    ["MAGE"] = {
        {name="Frostbolt", rank="Rank 11", source="Book"},
        {name="Fireball", rank="Rank 12", source="Book"},
        {name="Arcane Missiles", rank="Rank 8", source="Book"},
        {name="Scorch", rank="Rank 7", source="Trainer"},
        {name="Cone of Cold", rank="Rank 5", source="Trainer"},
        {name="Blizzard", rank="Rank 6", source="Trainer"},
        {name="Arcane Explosion", rank="Rank 6", source="Trainer"},
        {name="Conjure Water", rank="Rank 7", source="Book"},
        {name="Conjure Food", rank="Rank 7", source="Trainer"},
    },
    ["WARRIOR"] = {
        {name="Heroic Strike", rank="Rank 9", source="Book"},
        {name="Revenge", rank="Rank 6", source="Book"},
        {name="Battle Shout", rank="Rank 7", source="Book"},
        {name="Mortal Strike", rank="Rank 4", source="Trainer"},
        {name="Bloodthirst", rank="Rank 4", source="Trainer"},
        {name="Sunder Armor", rank="Rank 5", source="Trainer"},
        {name="Execute", rank="Rank 5", source="Trainer"},
        {name="Overpower", rank="Rank 4", source="Trainer"},
    },
    ["ROGUE"] = {
        {name="Eviscerate", rank="Rank 9", source="Book"},
        {name="Feint", rank="Rank 5", source="Book"},
        {name="Backstab", rank="Rank 9", source="Book"},
        {name="Sinister Strike", rank="Rank 8", source="Trainer"},
        {name="Ambush", rank="Rank 6", source="Trainer"},
        {name="Garrote", rank="Rank 6", source="Trainer"},
        {name="Rupture", rank="Rank 6", source="Trainer"},
    },
    ["PRIEST"] = {
        {name="Greater Heal", rank="Rank 5", source="Book"},
        {name="Renew", rank="Rank 10", source="Book"},
        {name="Shadow Word: Pain", rank="Rank 8", source="Book"},
        {name="Prayer of Healing", rank="Rank 4", source="Trainer"},
        {name="Flash Heal", rank="Rank 7", source="Trainer"},
        {name="Heal", rank="Rank 4", source="Trainer"},
        {name="Mind Blast", rank="Rank 9", source="Trainer"},
        {name="Smite", rank="Rank 8", source="Trainer"},
    },
    ["HUNTER"] = {
        {name="Multi-Shot", rank="Rank 4", source="Book"},
        {name="Serpent Sting", rank="Rank 8", source="Book"},
        {name="Aspect of the Hawk", rank="Rank 6", source="Book"},
        {name="Arcane Shot", rank="Rank 8", source="Trainer"},
        {name="Aimed Shot", rank="Rank 6", source="Trainer"},
        {name="Concussive Shot", rank="Rank 1", source="Trainer"},
        {name="Raptor Strike", rank="Rank 8", source="Trainer"},
    },
    ["WARLOCK"] = {
        {name="Shadow Bolt", rank="Rank 10", source="Book"},
        {name="Corruption", rank="Rank 7", source="Book"},
        {name="Immolate", rank="Rank 8", source="Book"},
        {name="Curse of Agony", rank="Rank 6", source="Trainer"},
        {name="Siphon Life", rank="Rank 4", source="Trainer"},
        {name="Hellfire", rank="Rank 3", source="Trainer"},
    },
    ["DRUID"] = {
        {name="Healing Touch", rank="Rank 11", source="Book"},
        {name="Rejuvenation", rank="Rank 11", source="Book"},
        {name="Starfire", rank="Rank 7", source="Book"},
        {name="Regrowth", rank="Rank 9", source="Trainer"},
        {name="Moonfire", rank="Rank 10", source="Trainer"},
        {name="Wrath", rank="Rank 8", source="Trainer"},
    },
    ["SHAMAN"] = {
        {name="Healing Wave", rank="Rank 10", source="Book"},
        {name="Lesser Healing Wave", rank="Rank 6", source="Book"},
        {name="Lightning Bolt", rank="Rank 10", source="Book"},
        {name="Chain Lightning", rank="Rank 4", source="Trainer"},
        {name="Earth Shock", rank="Rank 7", source="Trainer"},
        {name="Flame Shock", rank="Rank 6", source="Trainer"},
    },
    ["PALADIN"] = {
        {name="Holy Light", rank="Rank 8", source="Book"},
        {name="Flash of Light", rank="Rank 6", source="Book"},
        {name="Blessing of Wisdom", rank="Rank 6", source="Book"},
        {name="Blessing of Might", rank="Rank 6", source="Book"},
        {name="Consecration", rank="Rank 3", source="Trainer"},
        {name="Judgement", rank="Rank 1", source="Trainer"},
    }
}

-- Create Main UI Frame
local frame = CreateFrame("Frame", "SimpleSpellCheckerFrame", UIParent)
frame:SetWidth(350)
frame:SetHeight(400)
frame:SetPoint("CENTER", UIParent, "CENTER")
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 }
})
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", function() this:StartMoving() end)
frame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
frame:Hide()

-- Close Button
local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)

-- Title
local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
title:SetPoint("TOP", frame, "TOP", 0, -15)
title:SetText("Missing Max-Rank Spells")

-- Scroll Frame for long lists
local scrollFrame = CreateFrame("ScrollFrame", "SimpleSpellCheckerScrollFrame", frame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 15, -45)
scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -35, 15)

local scrollContent = CreateFrame("Frame", nil, scrollFrame)
scrollContent:SetWidth(300)
scrollContent:SetHeight(1)
scrollFrame:SetScrollChild(scrollContent)

-- Track dynamically built strings
local textLines = {}

local function AddTextLine(text, r, g, b)
    local line = scrollContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    line:SetWidth(290)
    line:SetJustifyH("LEFT")
    line:SetText(text)
    if r then line:SetTextColor(r, g, b) end
    
    if table.getn(textLines) == 0 then
        line:SetPoint("TOPLEFT", scrollContent, "TOPLEFT", 5, -5)
    else
        line:SetPoint("TOPLEFT", textLines[table.getn(textLines)], "BOTTOMLEFT", 0, -4)
    end
    table.insert(textLines, line)
end
-- Part 2: Spell Checking Engine & Minimap Button Framework

-- Clear past entries
local function ClearLines()
    for _, line in ipairs(textLines) do
        line:Hide()
    end
    textLines = {}
end

-- Function to check local Spellbook for matching name + rank string
local function IsSpellRankLearned(spellName, rankName)
    local i = 1
    while true do
        local name, rank = GetSpellName(i, "spell")
        if not name then break end
        if name == spellName and rank == rankName then
            return true
        end
        i = i + 1
    end
    return false
end

-- Main check execution
local function RunCheck()
    ClearLines()
    local _, class = UnitClass("player")
    local database = SpellData[class]
    
    if not database then
        AddTextLine("Error: Class database not found.", 1, 0, 0)
        return
    end

    local missingCount = 0
    for _, item in ipairs(database) do
        if not IsSpellRankLearned(item.name, item.rank) then
            local tag = item.source == "Book" and "[Book] " or "[Trainer] "
            local r, g, b = 0.4, 1, 0.4 -- Green for books
            if item.source == "Trainer" then
                r, g, b = 0.4, 0.6, 1 -- Blue for trainer
            end
            
            AddTextLine(tag .. item.name .. " (" .. item.rank .. ")", r, g, b)
            missingCount = missingCount + 1
        end
    end

    if missingCount == 0 then
        AddTextLine("Congratulations! You know all tracked maximum rank spells for your class.", 1, 1, 1)
    end
    
    frame:Show()
end

-- Minimap Button Dragging Logic
local function UpdateMinimapButtonPosition()
    local angle = SimpleSpellCheckerDB.minimapPos or 45
    local x = 54 * math.cos(math.rad(angle))
    local y = 54 * math.sin(math.rad(angle))
    SimpleSpellCheckerButton:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

local function OnMinimapButtonDrag()
    local xpos, ypos = GetCursorPosition()
    local xmin, ymin = Minimap:GetLeft(), Minimap:GetBottom()
    xpos = xmin - xpos / Minimap:GetEffectiveScale() + 70
    ypos = ypos / Minimap:GetEffectiveScale() - ymin - 70
    local angle = math.atan2(ypos, xpos)
    SimpleSpellCheckerDB.minimapPos = math.deg(angle)
    UpdateMinimapButtonPosition()
end

-- Event handling framework
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

eventFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "SimpleSpellChecker" then
        -- Handle Database Initialization
        if not SimpleSpellCheckerDB then
            SimpleSpellCheckerDB = { minimapPos = 45 }
        end
        
        -- Create Minimap Button
        local miniBtn = CreateFrame("Button", "SimpleSpellCheckerButton", Minimap)
        miniBtn:SetWidth(31)
        miniBtn:SetHeight(31)
        miniBtn:SetFrameLevel(Minimap:GetFrameLevel() + 1)
        miniBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        
        local icon = miniBtn:CreateTexture(nil, "BACKGROUND")
        icon:SetTexture("Interface\\Icons\\Spell_Nature_Web")
        icon:SetWidth(20)
        icon:SetHeight(20)
        icon:SetPoint("CENTER", miniBtn, "CENTER", -1, 1)
        
        local border = miniBtn:CreateTexture(nil, "OVERLAY")
        border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        border:SetWidth(53)
        border:SetHeight(53)
        border:SetPoint("TOPLEFT", miniBtn, "TOPLEFT")
        
        miniBtn:RegisterForDrag("LeftButton")
        miniBtn:SetScript("OnDragStart", function() this:StartMoving() this:SetScript("OnUpdate", OnMinimapButtonDrag) end)
        miniBtn:SetScript("OnDragStop", function() this:StopMovingOrSizing() this:SetScript("OnUpdate", nil) end)
        
        miniBtn:SetScript("OnClick", function()
            if frame:IsShown() then frame:Hide() else RunCheck() end
        end)
        
        miniBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(this, "ANCHOR_LEFT")
            GameTooltip:SetText("SimpleSpellChecker")
            GameTooltip:AddLine("Click to view missing spells.", 1, 1, 1)
            GameTooltip:Show()
        end)
        miniBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        
        UpdateMinimapButtonPosition()
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00SimpleSpellChecker Loaded! Type |cffffffff/spellcheck|cff00ff00 or click the minimap icon to scan missing spells.|r")
    end
end)

-- Slash Commands
SLASH_SIMPLESPELLCHECKER1 = "/spellcheck"
SlashCmdList["SIMPLESPELLCHECKER"] = function()
    if frame:IsShown() then frame:Hide() else RunCheck() end
end
