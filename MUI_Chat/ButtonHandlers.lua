-- luacheck: ignore MayronUI self 143

local _, namespace = ...;
local C_ChatModule = namespace.C_ChatModule;
local tk, _, em, _, _, L = MayronUI:GetCoreComponents();

namespace.ButtonNames = {
    L["Character"],
    L["Bags"],
    L["Friends"],
    L["Guild"],
    L["Help Menu"],
    L["PVP"],
    L["Spell Book"],
    L["Talents"],
    L["Achievements"],
    L["Glyphs"],
    L["Calendar"],
    L["LFD"],
    L["Raid"],
    L["Encounter Journal"],
    L["Collections Journal"],
    L["Macros"],
    L["World Map"],
    L["Quest Log"],
    L["Reputation"],
    L["PVP Score"],
    L["Currency"]
}

local clickHandlers = {};

-- Character
clickHandlers[namespace.ButtonNames[1]] = function()
    _G.ToggleCharacter("PaperDollFrame");
end

-- Bags
clickHandlers[namespace.ButtonNames[2]] = function()
    if (_G.ContainerFrame1:IsVisible()) then
        _G.ToggleBackpack();
    else
        _G.OpenAllBags();
    end
end

-- Friends
clickHandlers[namespace.ButtonNames[3]] = _G.ToggleFriendsFrame;

-- Guild
clickHandlers[namespace.ButtonNames[4]] = function()
    if (_G.IsTrialAccount()) then
        tk:Print(L["Starter Edition accounts cannot perform this action."]);

    elseif (_G.IsInGuild()) then
        _G.ToggleGuildFrame();
    end
end

-- Help Menu
clickHandlers[namespace.ButtonNames[5]] = _G.ToggleHelpFrame;

-- PVP
clickHandlers[namespace.ButtonNames[6]] = function()
    if (_G.UnitLevel("player") < 10) then
        tk:Print(L["Requires level 10+ to view the PVP window."]);
    else
        _G.TogglePVPUI();
    end
end

-- Spell Book
clickHandlers[namespace.ButtonNames[7]] = function()
    _G.ToggleFrame(_G.SpellBookFrame);
end

-- Talents
clickHandlers[namespace.ButtonNames[8]] = function()
    if (_G.UnitLevel("player") < 10) then
        tk:Print(L["Must be level 10 or higher to use Talents."]);
    else
        if (not tk._G["PlayerTalentFrame"]) then
            tk.LoadAddOn("Blizzard_TalentUI");
        end
        _G.ToggleFrame(_G.PlayerTalentFrame);
    end
end

-- Achievements
clickHandlers[namespace.ButtonNames[9]] = _G.ToggleAchievementFrame;

-- Glyphs
clickHandlers[namespace.ButtonNames[10]] = function()
    if (_G.UnitLevel("player") < 10) then
        tk:Print(L["Requires level 10+ to view the Glyphs window."]);
    else
		_G.ToggleFrame(_G.SpellBookFrame);
    end
end

-- Calendar
clickHandlers[namespace.ButtonNames[11]] = _G.ToggleCalendar;

-- LFD
clickHandlers[namespace.ButtonNames[12]] = _G.ToggleLFDParentFrame;

-- Raid
clickHandlers[namespace.ButtonNames[13]] = _G.ToggleRaidFrame;

-- Encounter Journal
clickHandlers[namespace.ButtonNames[14]] = _G.ToggleEncounterJournal;

-- Collections Journal
clickHandlers[namespace.ButtonNames[15]] = function()
    if (not _G["CollectionsJournal"]) then
        _G.LoadAddOn("Blizzard_Collections");
    end
    _G.ToggleFrame(_G.CollectionsJournal);
end

-- Macros
clickHandlers[namespace.ButtonNames[16]] = function()
    if (not _G.MacroFrame) then
        _G.LoadAddOn("Blizzard_MacroUI");
    end
    _G.ToggleFrame(_G.MacroFrame);
end

-- World Map
clickHandlers[namespace.ButtonNames[17]] = function()
    _G.ToggleWorldMap();
end

-- Quest Log
clickHandlers[namespace.ButtonNames[18]] = function()
    _G.ToggleQuestLog();
end

-- Repuation
clickHandlers[namespace.ButtonNames[19]] = function()
    _G.ToggleCharacter("ReputationFrame");
end

-- PVP Score
clickHandlers[namespace.ButtonNames[20]] = function()
    if (not _G.UnitInBattleground("player")) then
        tk:Print(L["Requires being inside a Battle Ground."]);
    else
        _G.ToggleWorldStateScoreFrame();
    end
end

-- Currency
clickHandlers[namespace.ButtonNames[21]] = function()
    _G.ToggleCharacter("TokenFrame");
end

local function ChatButton_OnClick(self)
    local text = self:GetText();
    clickHandlers[text]();
end

function C_ChatModule:SetUpButtonHandler(data, muiChatFrame, buttonSettings)
    em:CreateEventHandler("MODIFIER_STATE_CHANGED", function()
        if (data.settings.swapInCombat or not _G.InCombatLockdown()) then
            local updated = false;

            for _, info in pairs(buttonSettings) do
                if (info.key and tk:IsModComboActive(info.key)) then
                    muiChatFrame.buttons[1]:SetText(info[1]);
                    muiChatFrame.buttons[2]:SetText(info[2]);
                    muiChatFrame.buttons[3]:SetText(info[3]);
                    updated = true;
                    break;
                end
            end

            if (not updated) then
                local info = buttonSettings[1];
                muiChatFrame.buttons[1]:SetText(info[1]);
                muiChatFrame.buttons[2]:SetText(info[2]);
                muiChatFrame.buttons[3]:SetText(info[3]);
            end
        end
    end):Run();

    muiChatFrame.buttons[1]:SetScript("OnClick", ChatButton_OnClick);
    muiChatFrame.buttons[2]:SetScript("OnClick", ChatButton_OnClick);
    muiChatFrame.buttons[3]:SetScript("OnClick", ChatButton_OnClick);
end