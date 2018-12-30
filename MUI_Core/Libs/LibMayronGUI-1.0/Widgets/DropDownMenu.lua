-- luacheck: ignore MayronUI self 143 631
local Lib = _G.LibStub:GetLibrary("LibMayronGUI");
if (not Lib) then return; end

local WidgetsPackage = Lib.WidgetsPackage;
local Private = Lib.Private;
local obj = Lib.Objects;

local SlideController = WidgetsPackage:Get("SlideController");
local DropDownMenu = WidgetsPackage:CreateClass("DropDownMenu", Private.FrameWrapper);

DropDownMenu.Static.MAX_HEIGHT = 200;

-- Local Functions -------------------------------
local dropdowns = {};

-- @param exclude - for all except the excluded dropdown menu
local function FoldAll(exclude)
    for _, dropdown in ipairs(dropdowns) do
        if ((not exclude) or (exclude and exclude ~= dropdown)) then
            dropdown:Hide();
        end
    end

    if (not exclude and DropDownMenu.Static.Menu) then
        DropDownMenu.Static.Menu:Hide();
    end
end

local function DropDownToggleButton_OnClick(self)
    DropDownMenu.Static.Menu:SetFrameStrata("TOOLTIP");
    self.dropdown:Toggle(not self.dropdown:IsExpanded());
    FoldAll(self.dropdown);
end

local function OnSizeChanged(self, _, height)
    self:SetWidth(height);
end

-- Lib Functions ------------------------

function Lib:FoldAllDropDownMenus(exclude)
    FoldAll(exclude);
end

-- @constructor
function Lib:CreateDropDown(style, parent, direction)

    if (not DropDownMenu.Static.Menu) then
        DropDownMenu.Static.Menu = Lib:CreateScrollFrame(style, _G.UIParent, "MUI_DropDownMenu");
        DropDownMenu.Static.Menu:Hide();
        DropDownMenu.Static.Menu:SetBackdrop(style:GetBackdrop("DropDownMenu"));
        DropDownMenu.Static.Menu:SetBackdropBorderColor(style:GetColor("Widget"));
        DropDownMenu.Static.Menu:SetScript("OnHide", FoldAll);

        Private:SetBackground(DropDownMenu.Static.Menu, 0, 0, 0, 0.9);
        table.insert(_G.UISpecialFrames, "MUI_DropDownMenu");
    end

    local dropDownContainer = Private:PopFrame("Frame", parent);
    dropDownContainer:SetSize(178, 28);

    local header = Private:PopFrame("Frame", dropDownContainer);
    header:SetAllPoints(true);
    header:SetBackdrop(style:GetBackdrop("DropDownMenu"));
    header.bg = Private:SetBackground(header, style:GetTexture("ButtonTexture"));

    dropDownContainer.toggleButton = self:CreateButton(style, dropDownContainer);
    dropDownContainer.toggleButton:SetSize(28, 28);
    dropDownContainer.toggleButton:SetPoint("TOPRIGHT", dropDownContainer, "TOPRIGHT");
    dropDownContainer.toggleButton:SetPoint("BOTTOMRIGHT", dropDownContainer, "BOTTOMRIGHT");
    dropDownContainer.toggleButton:SetScript("OnSizeChanged", OnSizeChanged);

    dropDownContainer.toggleButton.arrow = dropDownContainer.toggleButton:CreateTexture(nil, "OVERLAY");
    dropDownContainer.toggleButton.arrow:SetTexture(style:GetTexture("SmallArrow"));
    dropDownContainer.toggleButton.arrow:SetPoint("CENTER");
    dropDownContainer.toggleButton.arrow:SetSize(16, 16);

    dropDownContainer.child = Private:PopFrame("Frame", DropDownMenu.Static.Menu);
    Private:SetFullWidth(dropDownContainer.child);

    dropDownContainer.toggleButton.child = dropDownContainer.child; -- needed for OnClick
    dropDownContainer.toggleButton:SetScript("OnClick", DropDownToggleButton_OnClick);

    header:SetPoint("BOTTOMRIGHT", dropDownContainer.toggleButton, "BOTTOMLEFT", -2, 0);

    direction = (direction or "DOWN"):upper();

    if (direction == "DOWN") then
        dropDownContainer.toggleButton.arrow:SetTexCoord(1, 0, 1, 0);
    elseif (direction == "UP") then
        dropDownContainer.toggleButton.arrow:SetTexCoord(0, 1, 0, 1);
    end

    local slideController = SlideController(DropDownMenu.Static.Menu);
    slideController:SetMinHeight(1);

    slideController:OnEndRetract(function(self, frame)
        frame:Hide();
    end);

    dropDownContainer.toggleButton.dropdown = DropDownMenu(header, direction, slideController, dropDownContainer, style);
    table.insert(dropdowns, dropDownContainer.toggleButton.dropdown);

    return dropDownContainer.toggleButton.dropdown;
end

-----------------------------------
-- DropDownMenu Object
-----------------------------------
local function ToolTip_OnEnter(frame)
    _G.GameTooltip:SetOwner(frame, "ANCHOR_RIGHT", 0, 2);

    if (frame.isEnabled) then
        _G.GameTooltip:AddLine(frame.tooltip);
    else
        _G.GameTooltip:AddLine(frame.disabledTooltip);
    end

    _G.GameTooltip:Show();
end

 local function ToolTip_OnLeave()
    _G.GameTooltip:Hide();
end


function DropDownMenu:__Construct(data, header, direction, slideController, frame, style)
    data.header = header;
    data.direction = direction;
    data.slideController = slideController;
    data.scrollHeight = 0;
    data.frame = frame; -- must be called frame for GetFrame() to work!
    data.menu = DropDownMenu.Static.Menu;
    data.style = style;
    data.options = obj:PopWrapper();

    data.label = data.header:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    data.label:SetPoint("LEFT", 10, 0);
    data.label:SetPoint("RIGHT", -10, 0);
    data.label:SetWordWrap(false);
    data.label:SetJustifyH("LEFT");

    -- disabled by default (until an option is added)
    self:SetEnabled(false);
end

function DropDownMenu:GetMenu(data)
    return data.menu;
end

do
    local function ApplyTooltipScripts(header)
        if (not (header.tooltip or header.disabledTooltip)) then
            header:SetScript("OnEnter", ToolTip_OnEnter);
            header:SetScript("OnLeave", ToolTip_OnLeave);
        end
    end

    function DropDownMenu:SetTooltip(data, tooltip)
        ApplyTooltipScripts(data.header);
        data.header.tooltip = tooltip;
    end

    function DropDownMenu:SetDisabledTooltip(data, disabledTooltip)
        ApplyTooltipScripts(data.header);
        data.header.disabledTooltip = disabledTooltip;
    end
end

-- tooltip means that the tooltip should be the same as the label
function DropDownMenu:SetLabel(data, text)
    data.label:SetText(text);
end

function DropDownMenu:GetLabel(data)
    return data.label and data.label:GetText();
end

WidgetsPackage:DefineReturns("number");
function DropDownMenu:GetNumOptions(data)
    return #data.options;
end

WidgetsPackage:DefineParams("number");
WidgetsPackage:DefineReturns("Button");
function DropDownMenu:GetOptionByID(data, optionID)
    local foundOption = data.options[optionID];
    obj:Assert(foundOption, "DropDownMenu.GetOption failed to find option with id '%s'.", optionID);
    return foundOption;
end

WidgetsPackage:DefineParams("string");
WidgetsPackage:DefineReturns("Button");
function DropDownMenu:GetOptionByLabel(data, label)
    for _, optionButton in ipairs(data.options) do
        if (optionButton:GetText() == label) then
            return optionButton;
        end
    end
end

WidgetsPackage:DefineParams("string");
function DropDownMenu:RemoveOptionByLabel(data, label)
    for optionID, optionButton in ipairs(data.options) do
        if (optionButton:GetText() == label) then
            self:RemoveOptionByID(optionID);
        end
    end
end

WidgetsPackage:DefineParams("number");
function DropDownMenu:RemoveOptionByID(data, optionID)
    local optionToRemove = self:GetOption(optionID);

    table.remove(data.options, optionID);
    Private:PushFrame(optionToRemove);

    local height = 30;
    local child = data.frame.child;

    -- reposition all options
    for id, option in ipairs(data.options) do
        option:ClearAllPoints();

        if (id == 1) then
            if (data.direction == "DOWN") then
                option:SetPoint("TOPLEFT", 2, -2);
                option:SetPoint("TOPRIGHT", -2, -2);
            elseif (data.direction == "UP") then
                option:SetPoint("BOTTOMLEFT", 2, 2);
                option:SetPoint("BOTTOMRIGHT", -2, 2);
            end

        else
            if (data.direction == "DOWN") then
                option:SetPoint("TOPLEFT", data.options[id - 1], "BOTTOMLEFT", 0, -1);
                option:SetPoint("TOPRIGHT", data.options[id - 1], "BOTTOMRIGHT", 0, -1);
            elseif (data.direction == "UP") then
                option:SetPoint("BOTTOMLEFT", data.options[id - 1], "TOPLEFT", 0, 1);
                option:SetPoint("BOTTOMRIGHT", data.options[id - 1], "TOPRIGHT", 0, 1);
            end

            height = height + 27;
        end
    end

    data.scrollHeight = height;
    child:SetHeight(height);

    if (DropDownMenu.Static.Menu:IsShown()) then
        DropDownMenu.Static.Menu:SetHeight(height);
    end

    if (#data.options == 0) then
        self:SetEnabled(false);
    end
end

function DropDownMenu:AddOptions(_, func, optionsTable)
    for _, optionValues in ipairs(optionsTable) do
        local label = optionValues[1];
        self:AddOption(label, func, select(2, _G.unpack(optionValues)));
    end
end

function DropDownMenu:AddOption(data, label, func, ...)
    local r, g, b = data.style:GetColor();
    local child = data.frame.child;
    local height = 30;

    local option = Private:PopFrame("Button", child);

    if (#data.options == 0) then
        if (data.direction == "DOWN") then
            option:SetPoint("TOPLEFT", 2, -2);
            option:SetPoint("TOPRIGHT", -2, -2);
        elseif (data.direction == "UP") then
            option:SetPoint("BOTTOMLEFT", 2, 2);
            option:SetPoint("BOTTOMRIGHT", -2, 2);
        end

    else
        local previousOption = data.options[#data.options];

        if (data.direction == "DOWN") then
            option:SetPoint("TOPLEFT", previousOption, "BOTTOMLEFT", 0, -1);
            option:SetPoint("TOPRIGHT", previousOption, "BOTTOMRIGHT", 0, -1);
        elseif (data.direction == "UP") then
            option:SetPoint("BOTTOMLEFT", previousOption, "TOPLEFT", 0, 1);
            option:SetPoint("BOTTOMRIGHT", previousOption, "TOPRIGHT", 0, 1);
        end

        height = child:GetHeight() + 27;
    end

    -- insert option only after it has been positioned
    table.insert(data.options, option);

    data.scrollHeight = height;
    child:SetHeight(height);

    option:SetHeight(26);
    option:SetNormalFontObject("GameFontHighlight");
    option:SetText(label or " ");

    local optionFontString = option:GetFontString();
    optionFontString:ClearAllPoints();
    optionFontString:SetPoint("LEFT", 10, 0);
    optionFontString:SetPoint("RIGHT", -10, 0);
    optionFontString:SetWordWrap(false);
    optionFontString:SetJustifyH("LEFT");

    option:SetNormalTexture(1);
    option:GetNormalTexture():SetColorTexture(r * 0.7, g * 0.7, b * 0.7, 0.4);
    option:SetHighlightTexture(1);
    option:GetHighlightTexture():SetColorTexture(r * 0.7, g * 0.7, b * 0.7, 0.4);

    local args = obj:PopWrapper(...);
    option:SetScript("OnClick", function()
        self:SetLabel(label, true);
        self:Toggle(false);

        if (not func) then return end

        if (type(func) == "table") then
            local tbl = func[1];
            local methodName = func[2];

            tbl[methodName](tbl, self, _G.unpack(args));
        else
            func(self, _G.unpack(args));
        end
    end);

    self:SetEnabled(true);

    return option;
end

function DropDownMenu:SetEnabled(data, enabled)
    data.frame.toggleButton:SetEnabled(enabled);
    data.header.isEnabled = enabled; -- required for using the correct tooltip

    if (enabled) then
        local r, g, b = data.style:GetColor("Widget");

        data.header:SetBackdropBorderColor(r, g, b);
        data.header.bg:SetVertexColor(r, g, b, 0.6);

        data.frame.toggleButton:GetNormalTexture():SetVertexColor(r, g, b, 0.6);
        data.frame.toggleButton:GetHighlightTexture():SetVertexColor(r, g, b, 0.3);
        data.frame.toggleButton:SetBackdropBorderColor(r, g, b);

        data.frame.toggleButton.arrow:SetAlpha(1);
        data.label:SetTextColor(1, 1, 1);
    else
        local r, g, b = _G.DISABLED_FONT_COLOR:GetRGB();

        data.header:SetBackdropBorderColor(r, g, b);
        data.header.bg:SetVertexColor(r, g, b, 0.6);

        data.frame.toggleButton:SetBackdropBorderColor(r, g, b);

        data.frame.toggleButton.arrow:SetAlpha(0.5);
        data.label:SetTextColor(r, g, b);
    end
end

-- Unlike Toggle(), this function hides the menu instantly (does not fold)
function DropDownMenu:Hide(data)
    data.expanded = false;
    data.frame.child:Hide();

    if (data.direction == "DOWN") then
        data.frame.toggleButton.arrow:SetTexCoord(1, 0, 1, 0);
    elseif (data.direction == "UP") then
        data.frame.toggleButton.arrow:SetTexCoord(0, 1, 0, 1);
    end
end

function DropDownMenu:IsExpanded(data)
    return data.expanded;
end

function DropDownMenu:Toggle(data, show, clickSoundFilePath)
    if (not data.options) then
        -- no list of options so nothing to toggle...
        return
    end

    local step = #data.options * 4;
    step = (step > 20) and step or 20;
    step = (step < 30) and step or 30;

    DropDownMenu.Static.Menu:ClearAllPoints();

    if (data.direction == "DOWN") then
        DropDownMenu.Static.Menu:SetPoint("TOPLEFT", data.frame, "BOTTOMLEFT", 0, -2);
        DropDownMenu.Static.Menu:SetPoint("TOPRIGHT", data.frame, "BOTTOMRIGHT", 0, -2);
    elseif (data.direction == "UP") then
        DropDownMenu.Static.Menu:SetPoint("BOTTOMLEFT", data.frame, "TOPLEFT", 0, 2);
        DropDownMenu.Static.Menu:SetPoint("BOTTOMRIGHT", data.frame, "TOPRIGHT", 0, 2);
    end

    if (show) then
        local maxHeight = (data.scrollHeight < DropDownMenu.Static.MAX_HEIGHT)
            and data.scrollHeight or DropDownMenu.Static.MAX_HEIGHT;

        DropDownMenu.Static.Menu.ScrollFrame:SetScrollChild(data.frame.child);
        DropDownMenu.Static.Menu:SetHeight(1);

        data.frame.child:Show();
        data.slideController:SetMaxHeight(maxHeight);

        if (data.direction == "DOWN") then
            data.frame.toggleButton.arrow:SetTexCoord(0, 1, 0, 1);
        elseif (data.direction == "UP") then
            data.frame.toggleButton.arrow:SetTexCoord(1, 0, 1, 0);
        end
    else
        if (data.direction == "DOWN") then
            data.frame.toggleButton.arrow:SetTexCoord(1, 0, 1, 0);
        elseif (data.direction == "UP") then
            data.frame.toggleButton.arrow:SetTexCoord(0, 1, 0, 1);
        end
    end

    data.slideController:SetStepValue(step);
    data.slideController:Start();

    if (clickSoundFilePath) then
        _G.PlaySound(clickSoundFilePath);
    end

    data.expanded = show;
end