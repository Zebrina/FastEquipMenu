--  922035 TOPLEFT -8 8
TEXTURE_FAVORITE = 922035;

function GetItemLink(item)
    local _, itemLink = GetItemInfo(item);
    return itemLink;
end
function GetItemTexture(item)
    local _, _, _, _, icon = GetItemInfoInstant(item);
    return icon;
end

local function GetItemEnchant(itemLink)
    if (not itemLink) then
        return nil;
    end
    local _, _, enchant = string.find(itemLink, "|?c?f?f?%x*|?H?[^:]*:?%d+:?(%d*):");
    return tonumber(enchant);
end
function GetInventoryItemEnchant(unit, slot)
    return GetItemEnchant(GetInventoryItemLink(unit, slot));
end
function GetContainerItemEnchant(bagID, slot)
    return GetItemEnchant(GetContainerItemLink(bagID, slot));
end

function IsContainerItemBound(bagID, slot)
    local itemLoc = ItemLocation.CreateFromBagAndSlot(bagID, slot);
    return itemLoc:IsBagAndSlot() and C_Item.IsBound(itemLoc);
end

function GetInventorySlotID(slotName)
    local slotID = GetInventorySlotInfo(slotName);
    return slotID;
end

function ForEachContainerSlot(callback)
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 0, GetContainerNumSlots(bagID) do
            if (callback(bagID, slot)) then
                return;
            end
        end
    end
end

INVSLOT_HEAD = GetInventorySlotID("HEADSLOT");
INVSLOT_NECK = GetInventorySlotID("NECKSLOT");
INVSLOT_SHOULDER = GetInventorySlotID("SHOULDERSLOT");
INVSLOT_CHEST = GetInventorySlotID("CHESTSLOT");
INVSLOT_ROBE = GetInventorySlotID("CHESTSLOT");
INVSLOT_WAIST = GetInventorySlotID("WAISTSLOT");
INVSLOT_LEGS = GetInventorySlotID("LEGSSLOT");
INVSLOT_FEET = GetInventorySlotID("FEETSLOT");
INVSLOT_WRIST = GetInventorySlotID("WRISTSLOT");
INVSLOT_HAND = GetInventorySlotID("HANDSSLOT");
INVSLOT_FINGER1 = GetInventorySlotID("FINGER0SLOT");
INVSLOT_FINGER2 = GetInventorySlotID("FINGER1SLOT");
INVSLOT_TRINKET1 = GetInventorySlotID("TRINKET0SLOT");
INVSLOT_TRINKET2 = GetInventorySlotID("TRINKET1SLOT");
INVSLOT_CLOAK = GetInventorySlotID("BACKSLOT");
INVSLOT_MAINHAND = GetInventorySlotID("MAINHANDSLOT");
INVSLOT_OFFHAND = GetInventorySlotID("SECONDARYHANDSLOT");
INVSLOT_RANGED = GetInventorySlotID("RANGEDSLOT");

EQUIP_LOC_TO_INV_SLOT_ID = {
    INVTYPE_HEAD = GetInventorySlotID("HEADSLOT"),
    INVTYPE_NECK = GetInventorySlotID("NECKSLOT"),
    INVTYPE_SHOULDER = GetInventorySlotID("SHOULDERSLOT"),
    INVTYPE_CHEST = GetInventorySlotID("CHESTSLOT"),
    INVTYPE_ROBE = GetInventorySlotID("CHESTSLOT"),
    INVTYPE_WAIST = GetInventorySlotID("WAISTSLOT"),
    INVTYPE_LEGS = GetInventorySlotID("LEGSSLOT"),
    INVTYPE_FEET = GetInventorySlotID("FEETSLOT"),
    INVTYPE_WRIST = GetInventorySlotID("WRISTSLOT"),
    INVTYPE_HAND = GetInventorySlotID("HANDSSLOT"),
    INVTYPE_FINGER = GetInventorySlotID("FINGER0SLOT"),
    INVTYPE_TRINKET = GetInventorySlotID("TRINKET0SLOT"),
    INVTYPE_CLOAK = GetInventorySlotID("BACKSLOT"),
    INVTYPE_WEAPON = GetInventorySlotID("MAINHANDSLOT"),
    INVTYPE_SHIELD = GetInventorySlotID("SECONDARYHANDSLOT"),
    INVTYPE_2HWEAPON = GetInventorySlotID("MAINHANDSLOT"),
    INVTYPE_WEAPONMAINHAND = GetInventorySlotID("MAINHANDSLOT"),
    INVTYPE_WEAPONOFFHAND = GetInventorySlotID("SECONDARYHANDSLOT"),
    INVTYPE_HOLDABLE = GetInventorySlotID("SECONDARYHANDSLOT"),
    INVTYPE_RANGED = GetInventorySlotID("RANGEDSLOT"),
    INVTYPE_THROWN = GetInventorySlotID("RANGEDSLOT"),
    INVTYPE_RANGEDRIGHT = GetInventorySlotID("RANGEDSLOT"),
    INVTYPE_RELIC = GetInventorySlotID("RANGEDSLOT"),
};
function GetInventorySlotIDByEquipLocation(itemEquipLoc)
    return EQUIP_LOC_TO_INV_SLOT_ID[itemEquipLoc];
end

EQUIP_LOC_COMBAT_EQUIP = {
    INVTYPE_WEAPON = true,
    INVTYPE_SHIELD = true,
    INVTYPE_2HWEAPON = true,
    INVTYPE_WEAPONMAINHAND = true,
    INVTYPE_WEAPONOFFHAND = true,
    INVTYPE_HOLDABLE = true,
    INVTYPE_RANGED = true,
    INVTYPE_THROWN = true,
    INVTYPE_RANGEDRIGHT = true,
    INVTYPE_RELIC = true,
};

EQUIP_LOC_MULTI_SLOT = {
    INVTYPE_FINGER = true,
    INVTYPE_TRINKET = true,
    INVTYPE_WEAPON = true,
};

EQUIP_SLOT_COMBAT_EQUIP = {
    INVSLOT_MAINHAND = true,
    INVSLOT_OFFHAND = true,
    INVSLOT_RANGED = true,
}

UNEQUIP_INVENTORY_ITEM_BACKPACK_LAST = true;

local function PutItemInBagByID(bagID)
    if (bagID >= 0 and bagID <= NUM_BAG_SLOTS and CursorHasItem()) then
        local numFreeSlots, bagType = GetContainerNumFreeSlots(bagID);
        if (bagType == 0 and numFreeSlots > 0) then
            if (bagID == 0) then
                PutItemInBackpack();
            else
                PutItemInBag(19 + bagID);
            end
        end
    end
end

function FindItemInBagsByLink(itemLink)
    local bagID, bagSlot;
    for bagID = 0, NUM_BAG_SLOTS do
        for slot = 0, GetContainerNumSlots(bagID) do
            if (GetContainerItemLink(bagID, slot) == itemLink) then
                return bagID, slot;
            end
        end
    end
    return nil, nil
end

-- TODO: Remove if not needed. Depends on how EquipItemByName distinguishes items with different enchants.
function EquipItemByLink(itemLink, invSlot)
    if (InCombatLockdown() or GetCursorInfo()) then
        return;
    end

    ForEachContainerSlot(function(bagID, bagSlot)
        if (GetContainerItemLink(bagID, bagSlot) == itemLink) then
            PickupContainerItem(bagID, bagSlot);
            EquipCursorItem(invSlot);
            return true;
        end
    end);
end

function UnequipInventoryItem(invSlot)
    if (InCombatLockdown() or GetCursorInfo()) then
        return;
    end

    PickupInventoryItem(invSlot);
    if (not CursorHasItem()) then
        return;
    end

    for bagID = 0, NUM_BAG_SLOTS do
        if (CursorHasItem()) then
            PutItemInBagByID(UNEQUIP_INVENTORY_ITEM_BACKPACK_LAST and (NUM_BAG_SLOTS - bagID) or bagID);
        end
    end

    -- Clear cursor in case all bags are full.
    ClearCursor();
end

function IsItemEquippedInSlot(item, invSlot)
    if (type(item) == "number") then
        return GetInventoryItemID("player", invSlot) == item;
    end
    local invItemLink = GetInventoryItemLink("player", invSlot);
    if (invItemLink and (invItemLink == item or GetItemInfo(invItemLink) == item)) then
        return true;
    end
    return false;
end

function IsItemEquippedAnySlot(item)
    if (not item) then
        return false;
    end
    local itemEquipLoc = select(4, GetItemInfoInstant(item));
    local itemSlot = EQUIP_LOC_TO_INV_SLOT_ID[itemEquipLoc];
    if (IsItemEquippedInSlot(item, itemSlot) or (EQUIP_LOC_MULTI_SLOT[itemEquipLoc] and IsItemEquippedInSlot(item, itemSlot + 1))) then
        return true;
    end
    return false;
end
