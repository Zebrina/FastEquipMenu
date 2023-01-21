-- PLACEHOLDER
local _INSPECTFRAMEUNIT = "player"
local _PORTRAITTEXTURE = "Interface\\AddOns\\FastEquipMenu\\Art\\CustomIconDeepdiveHelmet"





local isClassic = (WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE);

local EquipSetFrame_Events = {};
local EquipSetPaperDollFrame_Events = {};
local EquipSetPaperDollItemSlotButton_Events = {};

local function EquipSetPaperDollItemsFrame_ForEachButton(self, callback)
    for i, button in ipairs(self.Buttons) do
        if (button:IsShown()) then
            callback(button, i);
        end
    end
end

function EquipSetFrame_OnLoad(self)
    if (not isClassic) then
        self:Hide();
        return;
    end

    self:RegisterForDrag("LeftButton");

    for event in pairs(EquipSetFrame_Events) do
        self:RegisterEvent(event);
    end
end

function EquipSetFrame_OnEvent(self, event, ...)
    EquipSetFrame_Events[event](self, ...);
end

function EquipSetFrame_Events:ADDON_LOADED(addOnName)
    if (addOnName == "FastEquipMenu") then
        FEM_GlobalOptions.EquipSetPaperDollFrame = FEM_GlobalOptions.EquipSetPaperDollFrame or {};
        FEM_CharacterOptions.EquipSetPaperDollFrame = FEM_CharacterOptions.EquipSetPaperDollFrame or {};

        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint();
        self:SetPoint(point, relativeTo, relativePoint,
                      FEM_GlobalOptions.EquipSetPaperDollFrame.X or xOfs,
                      FEM_GlobalOptions.EquipSetPaperDollFrame.Y or yOfs);
    end
end

function EquipSetFrame_OnShow(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	SetPortraitToTexture(EquipSetFramePortrait, _PORTRAITTEXTURE);
	--EquipSetNameText:SetText(GetUnitName("player", true));
end

function EquipSetFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
end

function EquipSetFrame_OnDragStart(self)
    if (not FEM_GlobalOptions.EquipSetPaperDollFrame.Locked and not GetCursorInfo()) then
        self:StartMoving();
	end
end

function EquipSetFrame_OnDragStop(self)
    self:StopMovingOrSizing();
    if (not FEM_GlobalOptions.EquipSetPaperDollFrame.Locked) then
        local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint();
        FEM_GlobalOptions.EquipSetPaperDollFrame.X = xOfs;
        FEM_GlobalOptions.EquipSetPaperDollFrame.Y = yOfs;
	end
end

function EquipSetFrame_SetViewedEquipSet(equipSetName)
    EquipSetFrame.viewedEquipSet = equipSetName;
    if (EquipSetFrame:IsShown()) then
        EquipsetPaperDollFrame_UpdateModel();
    	EquipSetPaperDollFrame_UpdateButtons();
    end
end

function EquipSetFrame_AddItemToSelectedEquipSet(itemLink, invSlot, toggle)
    local equipSet = FastEquipMenu.GetEquipSet(EquipSetFrame.viewedEquipSet);
    if (equipSet) then
        if (toggle and equipSet.items[invSlot] == itemLink) then
            equipSet.items[invSlot] = nil;
        else
            equipSet.items[invSlot] = itemLink;
        end

        if (EquipSetFrame:IsShown()) then
            local itemSlotButton = EquipSetPaperDollItemsFrame.ButtonsByInvSlot[invSlot];
            --if (itemSlotButton) then
                EquipSetPaperDollItemSlotButton_Update(itemSlotButton);
            --end
            EquipsetPaperDollFrame_UpdateModel();
        end
    end
end

function EquipSetPaperDollFrame_OnLoad(self)
    if (not isClassic) then
        return;
    end

    EquipSetPaperDollItemsFrame.ButtonsByInvSlot = {};
    EquipSetPaperDollItemsFrame_ForEachButton(EquipSetPaperDollItemsFrame, function(button, i)
        EquipSetPaperDollItemsFrame.ButtonsByInvSlot[button.invSlot] = button;
    end);

    EquipSetEditDropDown:SetScale(0.87);
    EquipSetInheritDropDown:SetScale(0.87);

    for event in pairs(EquipSetPaperDollFrame_Events) do
        self:RegisterEvent(event);
    end
end

function EquipSetPaperDollFrame_OnEvent(self, event, ...)
    EquipSetPaperDollFrame_Events[event](self, ...);
end

function EquipSetPaperDollFrame_UpdateButtons()
	EquipSetPaperDollItemSlotButton_Update(EquipSetHeadSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetNeckSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetShoulderSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetBackSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetChestSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetShirtSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetTabardSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetWristSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetHandsSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetWaistSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetLegsSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetFeetSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetFinger0Slot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetFinger1Slot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetTrinket0Slot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetTrinket1Slot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetMainHandSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetSecondaryHandSlot);
	EquipSetPaperDollItemSlotButton_Update(EquipSetRangedSlot);
end

function EquipSetPaperDollFrame_OnShow()
	EquipSetModelFrame:SetUnit("player");
    EquipsetPaperDollFrame_UpdateModel();
	EquipSetModelFrame:Show();
	EquipSetPaperDollFrame_UpdateButtons();
end

function EquipsetPaperDollFrame_UpdateModel()
    EquipSetModelFrame:Undress();

    local equipSet = FastEquipMenu.GetEquipSet(EquipSetFrame.viewedEquipSet);
    if (equipSet) then
        for invSlot, itemLink in pairs(equipSet.items) do
            if (itemLink ~= "EMPTY" and (invSlot ~= INVSLOT_RANGED or select(2, UnitClass("player")) == "HUNTER")) then
                EquipSetModelFrame:TryOn(itemLink, invSlot);
            end
        end
    end
end

function EquipSetModelFrame_OnLoad(self)
    if (not isClassic) then
        return;
    end

    self:SetScript("OnUpdate", Model_OnUpdate);
	Model_OnLoad(self, MODELFRAME_MAX_PLAYER_ZOOM);
end

function EquipSetEditDropDown_OnLoad(self)
    if (not isClassic) then
        return;
    end
end

function EquipSetEditDropDown_OnShow(self)
    UIDropDownMenu_Initialize(self, EquipSetEditDropDown_Initialize);
    UIDropDownMenu_SetSelectedValue(self, EquipSetFrame.viewedEquipSet or "");
end

function EquipSetEditDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

    local equipSetList = {};
    for key in pairs(FEM_EquipSets) do
        tinsert(equipSetList, key);
    end
    sort(equipSetList);

    for i = 1, getn(equipSetList) do
        local equipSetKey = equipSetList[i];
        local equipSet = FEM_EquipSets[equipSetKey];

        info.text = equipSet.name;
        --info.isNotRadio = true;
        info.func = function(self)
            UIDropDownMenu_SetSelectedValue(EquipSetEditDropDown, self.value);
            EquipSetFrame_SetViewedEquipSet(self.value);
        end;
        info.value = equipSetKey;
        info.checked = equipSetKey == EquipSetFrame.viewedEquipSet;
        UIDropDownMenu_AddButton(info);
    end

	-- Add 'New Set' button.
	info.text = FEM_CONTEXTMENU_EQUIPSETS_NEW;
    info.notCheckable = true;
    --info.isNotRadio = true;
	info.func = function(self)
        StaticPopup_Show("FEM_ADD_ITEM_SET");
    end;
	--info.value = -1;
	info.checked = checked;
	UIDropDownMenu_AddButton(info);
end

function EquipSetInheritDropDown_OnLoad(self)
    if (not isClassic) then
        return;
    end
end

function EquipSetInheritDropDown_OnShow(self)
    --UIDropDownMenu_Initialize(self, EquipSetEditDropDown_Initialize);
    --UIDropDownMenu_SetSelectedValue(self, EquipSetFrame.viewedEquipSet or "");
end

function EquipSetPaperDollItemSlotButton_OnLoad(self)
    if (not isClassic) then
        return;
    end

    local slotID, textureName = GetInventorySlotInfo(self.invSlotName);
    self.invSlot = slotID;
    self.emptyTextureName = textureName;
    --self:SetAttribute("item", slotID);

    --local fontName, fontHeight, fontFlags = self.Count:GetFont();
    --self.Count:SetFont(fontName, fontHeight - 3, fontFlags);

    --self.enchant:SetSize(11, 11);

    --InventoryEquipmentButton_UpdateHotkey(self);

    self:RegisterForDrag("LeftButton");

    for event in pairs(EquipSetPaperDollItemSlotButton_Events) do
        self:RegisterEvent(event);
    end
end

function EquipSetPaperDollItemSlotButton_OnEvent(self, event, ...)
    EquipSetPaperDollItemSlotButton_Events[event](self, ...);
end

function EquipSetPaperDollItemSlotButton_Events.PLAYER_ENTERING_WORLD(self)
    if (self.checkRelic and UnitHasRelicSlot("player")) then
        self.emptyTextureName = "Interface\\Paperdoll\\UI-PaperDoll-Slot-Relic.blp";
    end
    EquipSetPaperDollItemSlotButton_UpdateIcon(self);
end

function EquipSetPaperDollItemSlotButton_OnUpdate(self, elapsed)
    CursorOnUpdate(self);
    if (GameTooltip:IsOwned(self)) then
        EquipSetPaperDollItemSlotButton_OnEnter(self);
    end
end

function EquipSetPaperDollItemSlotButton_OnClick(self, button)
    if (IsShiftKeyDown()) then
        EquipSetFrame_AddItemToSelectedEquipSet("EMPTY", self.invSlot);
    elseif (IsAltKeyDown()) then
        EquipSetFrame_AddItemToSelectedEquipSet(nil, self.invSlot);
    else
        local infoType, _, itemLink = GetCursorInfo();
        if (infoType == "item") then
            EquipSetFrame_AddItemToSelectedEquipSet(itemLink, self.invSlot);
        end
    end
end

function EquipSetPaperDollItemSlotButton_OnDragStart(self)
	if (not InCombatLockdown() and LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION")) then
        -- TODO: save link
        local itemLink = FastEquipMenu.GetEquipSetItemBySlot(EquipSetFrame.viewedEquipSet, self.invSlot);
        if (itemLink) then
            if (GetInventoryItemLink("player", self.invSlot) == itemLink) then
                PickupInventoryItem(self.invSlot);
            else
                local bagID, bagSlot = FindItemInBagsByLink(itemLink);
                if (bagID and bagSlot) then
                    PickupContainerItem(bagID, bagSlot);
                end
            end
        end
	end
end

function EquipSetPaperDollItemSlotButton_OnReceiveDrag(self)
    local infoType, _, itemLink = GetCursorInfo();
	if (not InCombatLockdown() and infoType == "item") then
        EquipSetFrame_AddItemToSelectedEquipSet(itemLink, self.invSlot);
	end
end

function EquipSetPaperDollItemSlotButton_OnEnter(self, motion)
    -- TODO: save link
    local itemLink = FastEquipMenu.GetEquipSetItemBySlot(EquipSetFrame.viewedEquipSet, self.invSlot);

    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    if (itemLink and itemLink ~= "EMPTY") then
        if (GetInventoryItemLink("player", self.invSlot) == itemLink) then
            GameTooltip:SetInventoryItem("player", self.invSlot);
        else
            local bagID, bagSlot = FindItemInBagsByLink(itemLink);
            if (bagID and bagSlot) then
                GameTooltip:SetBagItem(bagID, bagSlot);
            else
                GameTooltip:SetHyperlink(itemLink);
            end
        end
    else
		local text = _G[strupper(strsub(self:GetName(), 9))];
		if (self.checkRelic) then
			text = RELICSLOT;
		end
		GameTooltip:SetText(text);
	end
	CursorUpdate(self);
end

function EquipSetPaperDollItemSlotButton_OnLeave(self, motion)
    GameTooltip:Hide();
    ResetCursor();
end

function EquipSetPaperDollItemSlotButton_Update(self)
	EquipSetPaperDollItemSlotButton_UpdateIcon(self)

	if (GameTooltip:IsOwned(self)) then
		GameTooltip:Hide();
	end
end

function EquipSetPaperDollItemSlotButton_UpdateIcon(self)
    -- TODO: save link
    local itemLink, isInherited = FastEquipMenu.GetEquipSetItemBySlot(EquipSetFrame.viewedEquipSet, self.invSlot);

    self.icon:SetTexture(itemLink and GetItemTexture(itemLink) or self.emptyTextureName);

    -- TODO: SET TRANSPARENT IF INHERITED
end
