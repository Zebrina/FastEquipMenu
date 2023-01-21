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

function EquippableItemButton_OnLoad(self)
    self.HotKey:ClearAllPoints();
	self.HotKey:SetPoint("TOPLEFT", -2, -3);

	self.cooldown:SetWidth(33);
	self.cooldown:SetHeight(33);
    self.cooldown:SetSwipeColor(0, 0, 0);

    self.favorite:SetTexture(922035);

    self._onclick = EquippableItemButton_OnClick;

	self:RegisterForClicks("AnyUp");

    EquippableItemButton_UpdateIcon(self);
    EquippableItemButton_UpdateHotkey(self);
end

function EquippableItemButton_OnClick(self, unit, button, actionType)
    if (IsShiftKeyDown() and self.invSlot) then
        UnequipInventoryItem(self.invSlot);
        GameTooltip:Hide();
    elseif (IsAltKeyDown()) then
        if (EquipSetFrame:IsShown()) then
            local itemLink = self:GetItemLink();
            if (itemLink) then
                local invSlot = self.invSlot;
                if (not invSlot) then
                    local itemEquipLoc = select(4, GetItemInfoInstant(itemLink));
                    invSlot = GetInventorySlotIDByEquipLocation(itemEquipLoc);
                    if (EQUIP_LOC_MULTI_SLOT[itemEquipLoc] and button == "RightButton") then
                        invSlot = invSlot + 1;
                    end
                end

                EquipSetFrame_AddItemToSelectedEquipSet(self:GetItemLink(), invSlot, true);
            end
        else
            EquippableItemButtonContextMenu_Show(self);
        end
    end
end

function EquippableItemButton_OnEnter(self, motion)
	GameTooltip_SetDefaultAnchor(GameTooltip, self);

	if ((self.invSlot and GameTooltip:SetInventoryItem("player", self.invSlot)) or
        (self.bagID and self.bagSlot and GameTooltip:SetBagItem(self.bagID, self.bagSlot))) then
		self.UpdateTooltip = EquippableItemButton_OnEnter;
	else
		self.UpdateTooltip = nil;
	end
end

function EquippableItemButton_OnLeave(self, motion)
	GameTooltip:Hide();
end

function EquippableItemButton_OnShow(self)
end

function EquippableItemButton_OnHide(self)
end

function EquippableItemButton_OnUpdate(self, elapsed)
    -- TODO: Remove?
    EquippableItemButton_UpdateCount(self);

    if (self.glowTimeout and self.glowTimeout > 0) then
        local time = GetTime();
        if (time < self.glowTimeout) then
            ActionButton_ShowOverlayGlow(self);
        else
            ActionButton_HideOverlayGlow(self);
            self.glowTimeout = 0;
        end
    end
end
--[[
hooksecurefunc("ActionButton_OnUpdate", function(self, elapsed)
    if (self.glowTimeout and self.glowTimeout > 0) then
        local time = GetTime();
        if (time < self.glowTimeout) then
            ActionButton_ShowOverlayGlow(self);
        else
            ActionButton_HideOverlayGlow(self);
            self.glowTimeout = 0;
        end
    end
end
);]]

function EquippableItemButton_UpdateIcon(self)
    local texture, itemID, enchant;
    if (self.invSlot) then
        texture = GetInventoryItemTexture("player", self.invSlot) or self.emptyTextureName;
        itemID = GetInventoryItemID("player", self.invSlot);
        enchant = GetInventoryItemEnchant("player", self.invSlot);
    elseif (self.itemID) then
        texture = GetItemIcon(self.itemID);
        itemID = self.itemID;
        enchant = GetContainerItemEnchant(self.bagID, self.bagSlot or 1);
    end
    self.icon:SetTexture(texture);

    if (self.itemID and IsEquippedItem(self.itemID)) then
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

function EquippableItemButton_UpdateHotkey(self)
	local binding = GetBindingText(GetBindingKey("CLICK "..self:GetName()..":LeftButton"), true);
	local hotkey = self.HotKey;
	if (binding == "") then
		hotkey:SetText(RANGE_INDICATOR);
		hotkey:Hide();
	else
		hotkey:SetText(binding);
		hotkey:Show();
	end
end

function EquippableItemButton_UpdateCount(self)
    local count;
    if (self.invSlot == INVSLOT_MAINHAND or self.invSlot == INVSLOT_OFFHAND) then
        local hasMainHandEnchant, _, mainHandCharges, mainHandEnchantID, hasOffHandEnchant, _, offHandCharges, offHandEnchantId = GetWeaponEnchantInfo();
        if (self.invSlot == INVSLOT_MAINHAND and hasMainHandEnchant and mainHandCharges > 0) then
            count = mainHandCharges;
        elseif (self.invSlot == INVSLOT_OFFHAND and hasOffHandEnchant and offHandCharges > 0) then
            count = offHandCharges;
        end
    end
    if (count) then
        self.Count:SetText(count);
        self.Count:Show();
    else
        self.Count:Hide();
    end
end

-- TODO: Remove?
function EquippableItemButton_UpdateRangeIndicator(self)
    local checksRange, inRange = false, false;
    local itemID = GetInventoryItemID("player", self.invSlot);
    if (itemID) then
        local _, spellID = GetItemSpell(itemID);
        if (spellID) then
            inRange = IsItemInRange(itemID);
            checksRange = inRange ~= nil;
        end
    end
    ActionButton_UpdateRangeIndicator(self, checksRange, inRange);
end



local DEFAULT_BUTTON_SPACING = 4;

function EquippableItemButtonFrame_UpdateGridLayout(self, point, maxButtons, widthOrHeight, horizontalGrowth, reverseGrowth)
    -- TODO: Change all button arrays to 'Buttons' (capitalized).
    local buttons = self.Buttons or self.buttons;
    if (buttons == nil or buttons[1] == nil) then
        return;
    end

    local borderSizeTop = self.borderSizeTop or self.borderHeight or 0;
    local borderSizeBottom = self.borderSizeBottom or self.borderHeight or 0;
    local borderSizeLeft = self.borderSizeLeft or self.borderWidth or 0;
    local borderSizeRight = self.borderSizeRight or self.borderWidth or 0;
    local buttonSpacing = self.buttonSpacing or DEFAULT_BUTTON_SPACING;

    local buttonWidth, buttonHeight = buttons[1]:GetSize();
    local buttonScale = buttons[1]:GetScale();
    buttonWidth = buttonWidth * buttonScale;
    buttonHeight = buttonHeight * buttonScale;

    local xDir, yDir, xOfs, yOfs;
    if (point == "BOTTOMLEFT") then
        xDir, yDir, xOfs, yOfs = 1, 1, borderSizeLeft, borderSizeBottom;
    elseif (point == "BOTTOMRIGHT") then
        xDir, yDir, xOfs, yOfs = -1, 1, borderSizeRight, borderSizeBottom;
    elseif (point == "TOPLEFT") then
        xDir, yDir, xOfs, yOfs = 1, -1, borderSizeLeft, borderSizeTop;
    else
        point = "TOPRIGHT";
        xDir, yDir, xOfs, yOfs = -1, -1, borderSizeRight, borderSizeTop;
    end

    local numButtons = getn(buttons);
    local numVisibleButtons = 0;
    local x, y = 0, 0;
    for i = 1, numButtons do
        local button = reverseGrowth and buttons[numButtons - (i - 1)] or buttons[i];
        if (i <= maxButtons and (not button.ShouldShow or button:ShouldShow())) then
            button:ClearAllPoints();

            local xPos = xDir * (xOfs + x * (buttonWidth + buttonSpacing));
            local yPos = yDir * (yOfs + y * (buttonHeight + buttonSpacing));
            button:SetPoint(point, xPos, yPos);

            if (horizontalGrowth) then
                x = x + 1;
                if (x >= widthOrHeight) then
                    x = 0;
                    y = y + 1;
                end
            else
                y = y + 1;
                if (y >= widthOrHeight) then
                    y = 0;
                    x = x + 1;
                end
            end

            button:Show();

            numVisibleButtons = numVisibleButtons + 1;
        else
            button:Hide();
        end
    end

    local width, height;
    if (horizontalGrowth) then
        width = min(numVisibleButtons, widthOrHeight);
        height = ceil(numVisibleButtons / widthOrHeight);
    else
        width = ceil(numVisibleButtons / widthOrHeight);
        height = min(numVisibleButtons, widthOrHeight);
    end

    return width, height;
end

function EquippableItemButtonFrame_UpdateGridSize(self, width, height)
    -- TODO: Change all button arrays to 'Buttons' (capitalized).
    local buttons = self.Buttons or self.buttons;
    if (buttons == nil or buttons[1] == nil) then
        return;
    end

    local borderSizeTop = self.borderSizeTop or self.borderHeight or 0;
    local borderSizeBottom = self.borderSizeBottom or self.borderHeight or 0;
    local borderSizeLeft = self.borderSizeLeft or self.borderWidth or 0;
    local borderSizeRight = self.borderSizeRight or self.borderWidth or 0;
    local buttonSpacing = self.buttonSpacing or DEFAULT_BUTTON_SPACING;

    local buttonWidth, buttonHeight = buttons[1]:GetSize();
    local buttonScale = buttons[1]:GetScale();
    buttonWidth = buttonWidth * buttonScale;
    buttonHeight = buttonHeight * buttonScale;

    self:SetSize(borderSizeLeft + borderSizeRight + width * (buttonWidth + buttonSpacing) - buttonSpacing,
                 borderSizeTop + borderSizeBottom + height * (buttonHeight + buttonSpacing) - buttonSpacing);
end



local EquippableItemButtonContextMenu_Button;
local EquippableItemButtonContextMenu_MenuList = {};

local function EquippableItemButtonContextMenu_MenuListAdd(entry)
    tinsert(EquippableItemButtonContextMenu_MenuList, entry);
    return getn(EquippableItemButtonContextMenu_MenuList);
end

local CONTEXTMENU_TITLE = EquippableItemButtonContextMenu_MenuListAdd({
    notCheckable = true,
    isTitle = true,
    justifyH = "CENTER",
});
if (isClassic) then
    local CONTEXTMENU_ITEMSET = EquippableItemButtonContextMenu_MenuListAdd({
        text = FEM_CONTEXTMENU_EQUIPSETS,
        value = "ITEMSETS",
        notCheckable = true,
        isNotRadio = true,
        hasArrow = true,
    });
end

local function EquippableItemButtonContextMenu_UpdateItemSet(button, itemSlot, setName)
    local equipSet = FastEquipMenu.GetEquipSet(setName);
    if (equipSet) then
        local itemLink = button:GetItemLink();
        if (not itemLink) then
            return;
        end

        local items = equipSet.items;
        if (items[itemSlot] == itemLink) then
            items[itemSlot] = nil;
        else
            items[itemSlot] = itemLink;
        end
    end
end

function EquippableItemButtonContextMenu_OnLoad(self)
    self.xOffset = 0;
    self.yOffset = 0;
    self.point = "TOPRIGHT";
    self.relativePoint = "TOPLEFT";
end

function EquippableItemButtonContextMenu_OnLeave(self, motion)
end

function EquippableItemButtonContextMenu_Show(button)
    local itemLink = button:GetItemLink();
    if (not itemLink) then
        return;
    end

    local itemSlot = button.invSlot or button.itemSlot;
    local itemName, _, _, _, _, _, _, _, _, itemIcon = GetItemInfo(itemLink);
    EquippableItemButtonContextMenu_MenuList[CONTEXTMENU_TITLE].text = itemName;
    EquippableItemButtonContextMenu_MenuList[CONTEXTMENU_TITLE].icon = itemIcon;
    EquippableItemButtonContextMenu.relativeTo = button;
    EquippableItemButtonContextMenu_Button = button;

    if (isClassic) then
        local itemSets = EquippableItemButtonContextMenu_MenuList[CONTEXTMENU_ITEMSET];
        itemSets.menuList = {};
        for _, equipSet in pairs(FEM_EquipSets) do
            tinsert(itemSets.menuList, {
                text = equipSet.name..(button.multiSlot and FEM_CONTEXTMENU_SLOT_1 or ""),
                checked = function()
                    return equipSet.items[itemSlot] == itemLink;
                end,
                isNotRadio = true,
                keepShownOnClick = true,
                func = function(self)
                    EquippableItemButtonContextMenu_UpdateItemSet(button, itemSlot, equipSet.name);
                end,
            });
            if (button.multiSlot) then
                tinsert(itemSets.menuList, {
                    text = equipSet.name..FEM_CONTEXTMENU_SLOT_2,
                    checked = function()
                        return equipSet.items[itemSlot + 1] == itemLink;
                    end,
                    isNotRadio = true,
                    keepShownOnClick = true,
                    func = function(self)
                        EquippableItemButtonContextMenu_UpdateItemSet(button, itemSlot + 1, equipSet.name);
                    end,
                });
            end
        end
        tinsert(itemSets.menuList, {
            text = FEM_CONTEXTMENU_EQUIPSETS_NEW,
            notCheckable = true,
            isNotRadio = true,
            func = function(self)
                StaticPopup_Show("FEM_ADD_ITEM_SET");
            end
        });
    end

    EasyMenu(EquippableItemButtonContextMenu_MenuList, EquippableItemButtonContextMenu, nil, 0, 0, "MENU", 1);
end
