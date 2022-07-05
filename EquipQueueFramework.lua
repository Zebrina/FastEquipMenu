--[[
    ** FEATURES **
    * Equip items when leaving combat, resurrecting or finish casting a spell.
    * Favorite items
    * Set primary/secondary passive trinket (and rings maybe?) to auto-equip after use.
    * Shift click to queue equip after current item used.
]]

EQUIPQUEUE = {};
EQUIPQUEUESMART = {};

local Events = {};

local function PlayerCanEquipItems()
    return not InCombatLockdown() and
           not UnitIsDeadOrGhost("player") and
           CastingInfo() == nil;
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

function Events.UNIT_AURA(unitTarget)
    if (unitTarget == "player") then
        -- TODO: Stuff
    end
end

function Events.PLAYER_EQUIPMENT_CHANGED(equipmentSlot, hasCurrent)
    EQUIPQUEUE[equipmentSlot] = nil;
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

    if ((InCombatLockdown() and not EQUIP_SLOT_COMBAT_EQUIP[invSlot]) or UnitIsDeadOrGhost("player") or CastingInfo() ~= nil) then
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
