--[[
    ** FEATURES **
    * Equip items when leaving combat, resurrecting or finish casting a spell.
    * Favorite items
    * Set primary/secondary passive trinket (and rings maybe?) to auto-equip after use.
    * Shift click to queue equip after current item used.
]]

local UTILITY_ITEMS = {
    -- Signet of the Kirin Tor
    [40585] = {
        UnequipOnSpellCast = true,
    },
    -- Band of the Kirin Tor
    [40586] = {
        UnequipOnSpellCast = true,
    },
    -- Loop of the Kirin Tor
    [44934] = {
        UnequipOnSpellCast = true,
    },
    -- Ring of the Kirin Tor
    [44935] = {
        UnequipOnSpellCast = true,
    },
    -- Etched Band of the Kirin Tor
    [48954] = {
        UnequipOnSpellCast = true,
    },
    -- Etched Loop of the Kirin Tor
    [48955] = {
        UnequipOnSpellCast = true,
    },
    -- Etched Ring of the Kirin Tor
    [48956] = {
        UnequipOnSpellCast = true,
    },
    -- Etched Signet of the Kirin Tor
    [48957] = {
        UnequipOnSpellCast = true,
    },
    -- Inscribed Band of the Kirin Tor
    [45688] = {
        UnequipOnSpellCast = true,
    },
    -- Inscribed Loop of the Kirin Tor
    [45689] = {
        UnequipOnSpellCast = true,
    },
    -- Inscribed Ring of the Kirin Tor
    [45690] = {
        UnequipOnSpellCast = true,
    },
    -- Inscribed Signet of the Kirin Tor
    [45691] = {
        UnequipOnSpellCast = true,
    },
    -- Runed Signet of the Kirin Tor
    [51557] = {
        UnequipOnSpellCast = true,
    },
    -- Runed Loop of the Kirin Tor
    [51558] = {
        UnequipOnSpellCast = true,
    },
    -- Runed Ring of the Kirin Tor
    [51559] = {
        UnequipOnSpellCast = true,
    },
    -- Runed Band of the Kirin Tor
    [51560] = {
        UnequipOnSpellCast = true,
    },
    -- Wrap of Unity (Alliance)
    [63206] = {
        UnequipOnSpellCast = true,
    },
    -- Wrap of Unity (Horde)
    [63207] = {
        UnequipOnSpellCast = true,
    },
    -- Shroud of Cooperation (Alliance)
    [63352] = {
        UnequipOnSpellCast = true,
    },
    -- Shroud of Cooperation (Horde)
    [63353] = {
        UnequipOnSpellCast = true,
    },
    -- Cloak of Coordination (Horde)
    [65274] = {
        UnequipOnSpellCast = true,
    },
    -- Cloak of Coordination (Alliance)
    [65360] = {
        UnequipOnSpellCast = true,
    },
    -- Time-Lost Artifact
    [103678] = {
        UnequipOnSpellCast = true,
    },
    -- Violet Seal of the Grand Magus
    [142469] = {
        UnequipOnSpellCast = true,
    },
    -- Pugilist's Powerful Punching Ring (Alliance)
    [144391] = {
        UnequipOnSpellCast = true,
    },
    -- Pugilist's Powerful Punching Ring (Horde)
    [144392] = {
        UnequipOnSpellCast = true,
    },
    -- Commander's Signet of Battle
    [166559] = {
        UnequipOnSpellCast = true,
    },
    -- Captain's Signet of Command
    [166560] = {
        UnequipOnSpellCast = true,
    },
    -- Slumberwood Band
    [175711] = {
        UnequipOnDebuffApplied = 329492,
    },
    -- Dreamer's Mending
    [182455] = {
        UnequipOnDebuffApplied = 339736,
    },
}
local UTILITY_ITEMS_SPELLS = {
    -- Teleport: Dalaran
    [54406] = true,
    -- Teleport: Stormwind
    [89157] = true,
    -- Teleport: Orgrimmar
    [89158] = true,
    -- Teleport: Brawl'gar Arena
    [139432] = true,
    -- Teleport: Bizmo's Brewpub
    [139437] = true,
    -- Call of the Mists (Timeless Isle)
    [145430] = true,
    -- Teleport (Karazhan)
    [231054] = true,
    -- Teleport: Boralus
    [289284] = true,
};

EQUIPQUEUE = {};

local Events = {};

local function PlayerCanEquipItems()
    return not InCombatLockdown() and
           not UnitIsDeadOrGhost("player") and
           PlayerCastingInfo() == nil;
end

local function IsUtilityItem(item)
    return UTILITY_ITEMS_SPELLS[select(2, GetItemSpell(itemID))];
end

local function UpdateLastEquippedItem(equipmentSlot)
    if (not IsUtilityItem(GetInventoryItemID("player", equipmentSlot))) then
        FEM_LastEquipped[equipmentSlot] = GetInventoryItemLink("player", equipmentSlot);
    end
end

function Events:ADDON_LOADED(addOnName)
    if (addOnName == "FastEquipMenu") then
        FEM_LastEquipped = FEM_LastEquipped or {};
        ForEachInventorySlot(UpdateLastEquippedItem);
    end
end

function Events.PLAYER_REGEN_ENABLED()
    FlushEquipItemQueue();
end
function Events.PLAYER_ALIVE()
    FlushEquipItemQueue();
end
function Events.PLAYER_UNGHOST()
    FlushEquipItemQueue();
end
function Events.UNIT_SPELLCAST_STOP()
    FlushEquipItemQueue();
end
function Events.UNIT_SPELLCAST_CHANNEL_STOP()
    FlushEquipItemQueue();
end
function Events.UNIT_SPELLCAST_SUCCEEDED(unitTarget, castGUID, spellID)
    if (UTILITY_ITEMS_SPELLS[spellID]) then
        ForEachInventorySlot(function(equipmentSlot)
            local itemID = GetInventoryItemID("player", equipmentSlot);
            if (itemID) then
                local _, itemSpellID = GetItemSpell(itemID);
                if (spellID == itemSpellID) then
                    FastEquipMenu.EquipItem(FEM_LastEquipped[equipmentSlot], equipmentSlot);
                end
            end
        end);
    end
end

function Events.UNIT_AURA(unitTarget, isFullUpdate, updatedAuras)
    if (unitTarget == "player") then
        -- TODO
    end
end

function Events.PLAYER_EQUIPMENT_CHANGED(equipmentSlot, hasCurrent)
    EQUIPQUEUE[equipmentSlot] = nil;
    if (FEM_LastEquipped) then
        UpdateLastEquippedItem(equipmentSlot);
    end
end

-- Event handler setup.
local eventFrame = CreateFrame("Frame");
eventFrame:SetScript("OnEvent", function(_, event, ...)
    Events[event](...);
end);
for event in pairs(Events) do
    eventFrame:RegisterEvent(event);
end

local function EquipOrUnequipItem(itemLinkOrID, invSlot)
    if (itemLinkOrID == "EMPTY") then
        UnequipInventoryItem(invSlot);
    else
        EquipItemByName(itemLinkOrID, invSlot);
    end
end

function FastEquipMenu.EquipItem(itemLinkOrID, invSlot, smart)
    -- Check if already equipped.
    if (IsItemEquippedInSlot(itemLinkOrID, invSlot)) then
        return true;
    end

    if ((InCombatLockdown() and not EQUIP_SLOT_COMBAT_EQUIP[invSlot]) or UnitIsDeadOrGhost("player") or PlayerCastingInfo() ~= nil) then
        if (itemLinkOrID ~= EQUIPQUEUE[invSlot]) then
            EQUIPQUEUE[invSlot] = itemLinkOrID;
        else
            EQUIPQUEUE[invSlot] = nil;
        end
        InventoryEquipmentButton_UpdateIcon(InventoryEquipmentBar.ButtonsByInvSlot[invSlot]);
    elseif (not InCombatLockdown()) then
        EquipOrUnequipItem(itemLinkOrID, invSlot);
        return true;
    end
end

function FlushEquipItemQueue(self, force)
    if (not force and (InCombatLockdown() or UnitIsDeadOrGhost("player"))) then
        return;
    end

    for invSlot, itemLink in pairs(EQUIPQUEUE) do
        EquipOrUnequipItem(itemLink, invSlot);
    end
end
