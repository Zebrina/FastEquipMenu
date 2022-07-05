INVENTORYBAR_BORDER_WIDTH = 6;
INVENTORYBAR_BORDER_HEIGHT = 7;
INVENTORYBAR_BUTTONS_PER_ROW = 3;
INVENTORYBAR_BUTTONS_PER_COLUMN = 14;
INVENTORYBAR_BUTTON_SPACING = 6;

local WEAPON_CHAIN_ENCHANTID = 37;
local MITHRIL_SPURS_ENCHANTID = 464;
local WEAPON_CHAIN_TEXTUREID = 135834;
local MITHRIL_SPURS_TEXTUREID = 132307;

local IMMUNE_TO_DISARM_ITEMS = {
    [12639] = true, -- Stronghold Gauntlets
    [16907] = true, -- Bloodfang Gloves
    [18722] = true, -- Death Grips
    [23072] = true, -- Fists of the Unrelenting
    [23533] = true, -- Steelgrip Gauntlets
    [29357] = true, -- Master Thief's Gloves
};

CONTAINEREQUIPMENTFRAME_ITEMCACHE = {};

local ContainerEquipmentFrame_Events = {};
local ContainerEquipmentBar_Events = {};
local ContainerEquipmentButton_Events = {};

local function ContainerEquipmentFrame_Update(self)
    if (not self.updateBags) then
        return;
    end

    CONTAINEREQUIPMENTFRAME_ITEMCACHE = {};

    for bagID = 0, NUM_BAG_SLOTS do
        local _, bagType = GetContainerNumFreeSlots(bagID);
        -- Skip non-regular bags
        if (bagType == 0) then
            for slot = 1, GetContainerNumSlots(bagID) do
                local itemID = GetContainerItemID(bagID, slot);
                if (itemID) then
                    local _, _, _, itemEquipLoc, _, itemClassID, itemSubClassID = GetItemInfoInstant(itemID);
                    --[[ Ignore items that match one of the following:
                    - Not a weapon or armor
                    - A weapon in the "Miscellaneous" sub-category (profession tools and some quest items)
                    - Items that are not soulbound
                    ]]
                    if (EQUIP_LOC_TO_INV_SLOT_ID[itemEquipLoc] and
                        not (itemClassID == LE_ITEM_CLASS_WEAPON and itemSubClassID == LE_ITEM_WEAPON_GENERIC) and
                        not IsContainerItemBound(bagID, slot)) then
                        --------------------------------------------------------------------------------------
                        tinsert(CONTAINEREQUIPMENTFRAME_ITEMCACHE, {
                            itemSlot = EQUIP_LOC_TO_INV_SLOT_ID[itemEquipLoc],
                            itemID = itemID,
                            itemLink = GetContainerItemLink(bagID, slot),
                            bagID = bagID,
                            bagSlot = slot,
                            bagOrder = bagID * 36 + slot,
                        });
                    end
                end
            end
        end
    end

    for invSlot = 16, 18 do
        local itemID = GetInventoryItemID("player", invSlot);
        if (itemID) then
            tinsert(CONTAINEREQUIPMENTFRAME_ITEMCACHE, {
                itemSlot = invSlot,
                itemID = itemID,
                itemLink = GetInventoryItemLink("player", invSlot),
                invSlot = invSlot,
                bagOrder = invSlot - 36,
            });
        end
    end

    sort(CONTAINEREQUIPMENTFRAME_ITEMCACHE, function(x, y)
        if (x.itemSlot ~= y.itemSlot) then
            return x.itemSlot < y.itemSlot;
        elseif (x.itemSlot == INVSLOT_MAINHAND or x.itemSlot == INVSLOT_OFFHAND or x.itemSlot == INVSLOT_RANGED) then
            return x.itemLink < y.itemLink;
        end
        return x.bagOrder > y.bagOrder;
    end);

    ContainerEquipmentFrame_UpdateBars(self);

    self.updateBags = nil;
end

function ContainerEquipmentFrame_UpdatePosition(self)
    if (InCombatLockdown()) then
        self.updatePosition = true;
        return;
    end

    if (SHOW_MULTI_ACTIONBAR_3) then
        self:SetPoint("TOPRIGHT", SHOW_MULTI_ACTIONBAR_4 and MultiBarLeft or MultiBarRight, "TOPLEFT", -2, 0);
    else
        self:SetPoint("TOPRIGHT", UIParent, "RIGHT", 0, select(5, VerticalMultiBarsContainer:GetPoint()) + (VERTICAL_MULTI_BAR_HEIGHT / 2));
    end
end

function ContainerEquipmentFrame_OnLoad(self)
    self.Bars = {};
    self.updateBags = true;

    self:SetScale(0.667);

    hooksecurefunc("MultiActionBar_Update", function()
        ContainerEquipmentFrame_UpdatePosition(self);
    end);

    for event in pairs(ContainerEquipmentFrame_Events) do
        self:RegisterEvent(event);
    end
end

function ContainerEquipmentFrame_OnEvent(self, event, ...)
    ContainerEquipmentFrame_Events[event](self, ...);
end

function ContainerEquipmentFrame_Events.PLAYER_ENTERING_WORLD(self, isInitialLogin, isReloadingUi)
    if (isInitialLogin or isReloadingUi) then
        ContainerEquipmentFrame_Update(self);
    end
end

function ContainerEquipmentFrame_Events.BAG_UPDATE(self, slot)
    -- Skip non-regular bags
    if (select(2, GetContainerNumFreeSlots(slot)) == 0) then
        self.updateBags = true;
    end
end

function ContainerEquipmentFrame_Events.BAG_UPDATE_DELAYED(self)
    ContainerEquipmentFrame_Update(self);
end

function ContainerEquipmentFrame_Events.PLAYER_REGEN_ENABLED(self)
    if (self.updatePosition) then
        ContainerEquipmentFrame_UpdatePosition(self);
    end
end

function ContainerEquipmentFrame_OnUpdate(elapsed)
    --[[
    ContainerEquipmentFrame_ForEachButton(self, function(button)
        local start, duration, enable = GetItemCooldown(button.itemID);
		CooldownFrame_Set(button.cooldown, start, duration, enable);
		if (GameTooltip:GetOwner() == button) then
			EquippableItemButton_OnEnter(button);
		end
    end);
    ]]
end

function ContainerEquipmentFrame_UpdateBars(self)
    local frameWidth = 0;
    local frameHeight = 0;
    local previousBar = nil;
    for _, bar in ipairs(self.Bars) do
        ContainerEquipmentBar_UpdateButtons(bar);
        frameWidth = max(frameWidth, bar:GetWidth());
        frameHeight = frameHeight + bar:GetHeight();
        if (bar:IsShown() and not bar.freePlacement) then
            bar:ClearAllPoints();
            bar:SetPoint("TOP", previousBar or self, previousBar and "BOTTOM", 0, 0);
            previousBar = bar;
        end
    end
    self:SetSize(frameWidth, frameHeight);
end



function ContainerEquipmentBarSets_UpdateSize(self)
    self:SetSize(((ContainerEquipmentFrame:GetWidth() * ContainerEquipmentFrame:GetEffectiveScale()) +
                  (VerticalMultiBarsContainer:GetWidth() * VerticalMultiBarsContainer:GetEffectiveScale())) / self:GetEffectiveScale(), 40);
end

function ContainerEquipmentBarSets_OnLoad(self)
    -- TODO: Use global!
    --self.Label:SetText("Sets");
    self.Label:Hide();

    self:SetScale(0.667);

    UIDropDownMenu_Initialize(self, EquipmentSetDropDown_InitializeMenu,
                              nil, -- "MENU" or nil
                              level,
                              menuList);

    -- TODO: Remove
    ContainerEquipmentBarSets_UpdateSize(self);
    hooksecurefunc("ContainerEquipmentFrame_UpdateBars", function()
        ContainerEquipmentBarSets_UpdateSize(self);
    end);

    self:Show();

    --[[
    for event in pairs(ContainerEquipmentFrame_Events) do
        self:RegisterEvent(event);
    end
    ]]
end

function ContainerEquipmentBarSets_OnEvent(self, event, ...)
    --ContainerEquipmentFrame_Events[event](self, ...);
end

function ContainerEquipmentBarSets_OnUpdate(elapsed)
    --[[
    ContainerEquipmentFrame_ForEachButton(self, function(button)
        local start, duration, enable = GetItemCooldown(button.itemID);
		CooldownFrame_Set(button.cooldown, start, duration, enable);
		if (GameTooltip:GetOwner() == button) then
			EquippableItemButton_OnEnter(button);
		end
    end);
    ]]
end



local function ContainerEquipmentBar_ForEachButton(self, callback)
    for i = 1, self.numVisibleButtons do
        callback(self.Buttons[i], i);
    end
end

function ContainerEquipmentBar_SetInfo(self, name, slots)
    self.Label:SetText(name);
    self.itemSlots = slots;
end

function ContainerEquipmentBar_UpdateButtons(self)
    local numItems = 0;
    -- Populate buttons with data
    for _, itemData in ipairs(CONTAINEREQUIPMENTFRAME_ITEMCACHE) do
        if (self.itemSlots[itemData.itemSlot]) then
            numItems = numItems + 1;
            local button = ContainerEquipmentBar_GetButton(self, numItems);
            button.itemSlot = itemData.itemSlot;
            button.itemID = itemData.itemID;
            button.itemLink = itemData.itemLink;
            button.bagID = itemData.bagID;
            button.bagSlot = itemData.bagSlot;
            button.invSlot = itemData.invSlot;
            button.multiSlot = EQUIP_LOC_MULTI_SLOT[select(4, GetItemInfoInstant(itemData.itemID))];
            ContainerEquipmentButton_Update(button);
            button:Show();
        end
    end

    if (numItems >= 1) then
        self.numVisibleButtons = numItems;

        -- Hide all unused buttons
        for i = self.numVisibleButtons + 1, #self.Buttons do
            self.Buttons[i]:Hide();
        end

        EquippableItemButtonFrame_UpdateGridLayout(self, "TOPLEFT", numItems, INVENTORYBAR_BUTTONS_PER_ROW, true);
        self:Show();
    else
        self:Hide();
    end
end

function ContainerEquipmentBar_GetButton(self, index)
    local button = self.Buttons[index];
    if (not button) then
        button = CreateFrame("CheckButton", "ContainerEquipmentButton"..index, self, "ContainerEquipmentButtonTemplate");
        button:SetID(index);
        self.Buttons[index] = button;
        if (getn(self.Buttons) < index) then
            setn(self.Buttons, index);
        end
    end
    return button;
end

function ContainerEquipmentBar_OnShow(self)
end

function ContainerEquipmentBar_OnHide(self)
end

function ContainerEquipmentBar_OnLoad(self)
    self.Buttons = {};
    self.numButtons = 0;
    self.numVisibleButtons = 0;

    self.borderSizeTop = 26;
    self.borderSizeRight = 5;
    self.buttonSpacing = 5;

    -- TODO: Enable this when bars are made dynamic.
    --tinsert(self:GetParent().Bars, self);

    for event in pairs(ContainerEquipmentBar_Events) do
        self:RegisterEvent(event);
    end
end

function ContainerEquipmentBar_OnEvent(self, event, ...)
    ContainerEquipmentBar_Events[event](self, ...);
end

function ContainerEquipmentBar_Events.UPDATE_BINDINGS(self)
    ContainerEquipmentBar_ForEachButton(self, ContainerEquipmentButton_UpdateHotkey);
end

function ContainerEquipmentBar_OnUpdate(self, elapsed)
    ContainerEquipmentBar_ForEachButton(self, function(button)
        local start, duration, enable = GetItemCooldown(button.itemID);
		CooldownFrame_Set(button.cooldown, start, duration, enable);
		if (GameTooltip:GetOwner() == button) then
			EquippableItemButton_OnEnter(button);
		end
    end);
end



ContainerEquipmentButtonMixin = {};

function ContainerEquipmentButtonMixin.GetItemLink(self)
    return self.itemLink;
end

function ContainerEquipmentButton_OnLoad(self)
    EquippableItemButton_OnLoad(self);

    --self._onclick = ContainerEquipmentButton_OnClick;

    --self.SpellHighlightTexture:Hide();

	self:RegisterForClicks("AnyUp");
    self:RegisterForDrag("LeftButton");

    for event in pairs(ContainerEquipmentButton_Events) do
        self:RegisterEvent(event);
    end
end

function ContainerEquipmentButton_OnEvent(self, event, ...)
    ContainerEquipmentButton_Events[event](self, ...);
end

function ContainerEquipmentButton_Events.PLAYER_REGEN_ENABLED(self)
    if (self.updateAction and not self.updateBags) then
        ContainerEquipmentButton_UpdateAction(self);
    end
end

function ContainerEquipmentButton_Events.ITEM_LOCK_CHANGED(self)
    ContainerEquipmentButton_UpdateLocked(self);
end

function ContainerEquipmentButton_OnClick(self, unit, button, actionType)
    ContainerEquipmentFrameContextMenu_Show(self, button == "RightButton");
end

function ContainerEquipmentButton_OnDragStart(self)
	if (not InCombatLockdown() and LOCK_ACTIONBAR ~= "1" or IsModifiedClick("PICKUPACTION")) then
		self:SetChecked(false);
        if (self.invSlot) then
            PickupInventoryItem(self.invSlot);
        else
            PickupContainerItem(self.bagID, self.bagSlot);
        end
	end
end

function ContainerEquipmentButton_OnReceiveDrag(self)
	if (not InCombatLockdown() and GetCursorInfo() == "item") then
		self:SetChecked(false);
		--PickupContainerItem(self.bagID, self.bagSlot);
	end
end

function ContainerEquipmentButton_OnUpdate(self, elapsed)
    EquippableItemButton_OnUpdate(self, elapsed);
end

function ContainerEquipmentButton_MacroEquipItem(itemID, invSlot)
    FastEquipMenu.EquipItem(itemID, invSlot, IsControlKeyDown());
end

local function FormatMacroText(itemID, itemSlot, itemName)
    local cmd = "/script ContainerEquipmentButton_MacroEquipItem("..itemID..","..itemSlot..")";
    if (EQUIP_SLOT_COMBAT_EQUIP[itemSlot]) then
        return cmd.."\n/equipslot [combat,@player,nodead] "..itemSlot.." "..itemName;
    end
    return cmd;
end

function ContainerEquipmentButton_UpdateAction(self)
    local item = Item:CreateFromItemID(self.itemID)
    item:ContinueOnItemLoad(function()
        if (InCombatLockdown()) then
            self.updateAction = true;
            return;
        end

        local itemName = item:GetItemName();
        local itemEquipLoc = select(4, GetItemInfoInstant(self.itemID));
        if (EQUIP_LOC_MULTI_SLOT[itemEquipLoc]) then
            self:SetAttribute("macrotext", nil);
            self:SetAttribute("macrotext1", FormatMacroText(self.itemID, self.itemSlot, itemName));
            self:SetAttribute("macrotext2", FormatMacroText(self.itemID, self.itemSlot + 1, itemName));
        else
            self:SetAttribute("macrotext", FormatMacroText(self.itemID, self.itemSlot, itemName));
            self:SetAttribute("macrotext1", nil);
            self:SetAttribute("macrotext2", nil);
        end

        self.updateAction = nil;
    end);
end

function ContainerEquipmentButton_UpdateIcon(self)
    local texture, itemID, enchant;
    if (self.invSlot) then
        texture = GetInventoryItemTexture("player", self.invSlot) or self.emptyTextureName;
        itemID = GetInventoryItemID("player", self.invSlot);
        enchant = GetInventoryItemEnchant("player", self.invSlot);
    elseif (self.itemID) then
        texture = GetItemIcon(self.itemID);
        itemID = self.itemID;
        enchant = GetContainerItemEnchant(self.bagID, self.bagSlot);
    end
    self.icon:SetTexture(texture);

    if (self.invSlot and IsEquippedItem(self.itemID) and GetInventoryItemLink("player", self.invSlot) == self.itemLink) then
        self.Border:SetVertexColor(0, 1.0, 0, 0.35);
        self.Border:Show();
    else
        self.Border:Hide();
    end

    if (IMMUNE_TO_DISARM_ITEMS[itemID] or enchant == WEAPON_CHAIN_ENCHANTID) then
        -- Show weapon chain icon if immune to disarm
        self.enchant:SetTexture(WEAPON_CHAIN_TEXTUREID);
        self.enchant:Show();
    elseif (enchant == MITHRIL_SPURS_ENCHANTID) then
        self.enchant:SetTexture(MITHRIL_SPURS_TEXTUREID);
        self.enchant:Show();
    else
        self.enchant:Hide();
    end
end

function ContainerEquipmentButton_UpdateLocked(self)
    local locked = false;
    if (self.bagID and self.bagSlot) then
        locked = select(3, GetContainerItemInfo(self.bagID, self.bagSlot));
    end
    SetItemButtonDesaturated(self, locked);
end

function ContainerEquipmentButton_UpdateHotkey(self)
    local bindingKey = GetBindingKey("ITEM item:"..self.itemID);
    if (not bindingKey) then
        local itemName = GetItemInfo(self.itemID);
        if (itemName) then
            bindingKey = GetBindingKey("ITEM "..itemName);
        end
    end
    local bindingText = GetBindingText(bindingKey, true);
	if (bindingText == "") then
		self.HotKey:SetText(RANGE_INDICATOR);
		self.HotKey:Hide();
	else
		self.HotKey:SetText(bindingText);
		self.HotKey:Show();
	end
end

function ContainerEquipmentButton_Update(self)
    ContainerEquipmentButton_UpdateAction(self);
    ContainerEquipmentButton_UpdateIcon(self);
    ContainerEquipmentButton_UpdateLocked(self);
    ContainerEquipmentButton_UpdateHotkey(self);
end
