local CustomItemIcons = {
    -- Deepdive Helmet
    [10506] = "Interface\\AddOns\\FastEquipMenu\\Art\\CustomIconDeepdiveHelmet",
    -- Gnomish Mind Control Cap
    [10726] = "Interface\\AddOns\\FastEquipMenu\\Art\\CustomIconGnomishMindControlCap",
};

local function GetCustomIconByItemID(itemID)
    local customTexture = nil;
    if (itemID) then
        customTexture = CustomItemIcons[itemID];
    end
    return customTexture
end

local oldGetItemIcon = GetItemIcon;
function GetItemIcon(itemID)
    return GetCustomIconByItemID(itemID) or oldGetItemIcon(itemID);
end

local oldGetItemInfoInstant = GetItemInfoInstant;
function GetItemInfoInstant(item)
    local itemID, itemType, itemSubType, itemEquipLoc, icon, itemClassID, itemSubClassID = oldGetItemInfoInstant(item);
    return itemID, itemType, itemSubType, itemEquipLoc, GetCustomIconByItemID(itemID) or icon, itemClassID, itemSubClassID;
end

local oldGetItemInfo = GetItemInfo;
function GetItemInfo(item)
    local itemID = oldGetItemInfoInstant(item);
    local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent = oldGetItemInfo(item);
    return itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, GetCustomIconByItemID(itemID) or itemIcon, itemSellPrice, itemClassID, itemSubClassID, bindType, expacID, itemSetID, isCraftingReagent;
end

local oldGetActionTexture = GetActionTexture;
function GetActionTexture(actionSlot)
    local customTexture = nil;
    local actionType, id = GetActionInfo(actionSlot);
    if (actionType == "item") then
        customTexture = GetCustomIconByItemID(id);
    end
    return customTexture or oldGetActionTexture(actionSlot);
end

local oldGetContainerItemInfo = GetContainerItemInfo;
function GetContainerItemInfo(bagID, slot)
    local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = oldGetContainerItemInfo(bagID, slot);
    return GetCustomIconByItemID(itemID) or icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID;
end

local oldGetInventoryItemTexture = GetInventoryItemTexture;
function GetInventoryItemTexture(unit, invSlot)
    local itemID = GetInventoryItemID(unit, invSlot);
    return GetCustomIconByItemID(itemID) or oldGetInventoryItemTexture(unit, invSlot);
end
