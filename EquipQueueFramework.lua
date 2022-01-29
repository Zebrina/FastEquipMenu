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
        EquipItemByName(itemLinkOrID, invSlot);
        return true;
    end
end

function FlushEquipItemQueue(self, force)
    if (not force and (InCombatLockdown() or UnitIsDeadOrGhost("player"))) then
        return;
    end

    for invSlot, itemID in pairs(EQUIPQUEUE) do
        EquipItemByName(itemID, invSlot);
    end
end

local function EquipSetKey(name)
    if (name == nil or name == "") then
        return "";
    end
    return strlower(name);
end

-- Equip Set API

function FastEquipMenu.GetEquipSet(name)
    return FEM_EquipSets[EquipSetKey(name)];
end

function FastEquipMenu.GetEquipSetItems(name, items)
    items = items or {};
    local equipSet = FastEquipMenu.GetEquipSet(name);
    if (equipSet) then
        if (equipSet.subset) then
            Mixin(items, FastEquipMenu.GetEquipSetItems(equipSet.subset));
        end
        if (equipSet.items) then
            Mixin(items, equipSet.items);
        end
    end
    return items;
end

function FastEquipMenu.RenameEquipSet(name, newName)
    local key = EquipSetKey(name);
    if (FEM_EquipSets[key]) then
        local equipSet = FEM_EquipSets[key];
        FEM_EquipSets[key] = nil;
        equipSet.name = newName;
        FEM_EquipSets[EquipSetKey(newName)] = equipSet;
    end
end

function FastEquipMenu.AddEquipSet(name, equipSetOrNameToCopy)
    local key = EquipSetKey(name);
    if (FEM_EquipSets[key] == nil) then
        local newEquipSet = {
            name = name,
            items = {},
        };

        if (type(equipSetOrNameToCopy) == "string") then
            equipSetOrNameToCopy = FEM_EquipSets[EquipSetKey(equipSetOrNameToCopy)];
            if (equipSetOrNameToCopy.aliasOf) then
                equipSetOrNameToCopy = FEM_EquipSets[equipSetOrNameToCopy.aliasOf];
            end
        end

        if (type(equipSetOrNameToCopy) == "table" and equipSetOrNameToCopy.items) then
            for itemSlot, itemID in pairs(equipSetOrNameToCopy.items) do
                if (type(itemSlot) == "number" and type(itemID) == "number") then
                    newEquipSet.items[itemSlot] = itemID;
                end
            end
        end

        FEM_EquipSets[key] = newEquipSet;

        --ContainerEquipmentFrameContextMenu_Show(ContainerEquipmentFrameContextMenu_Button);
        --UIDropDownMenu_SetSelectedValue(ContainerEquipmentFrameContextMenu, "ITEMSETS");
    --else
        -- TODO: Add already exists error message.
    end
end

function FastEquipMenu.AliasEquipSet(name, alias)
    local key = EquipSetKey(name);
    if (key ~= "") then
        local aliasKey = EquipSetKey(alias);
        if (aliasKey ~= "") then
            FEM_EquipSets[aliasKey] = {
                aliasOf = key,
            };
        end
    end
end

function FastEquipMenu.RemoveEquipSet(name)
    FEM_EquipSets[EquipSetKey(name)] = nil;
end

function FastEquipMenu.EquipSet(name)
    --[[
    if (type(name) == "string") then
        name = FastEquipMenu.GetEquipSet(name);
    end
    if (name and name.items) then
        local items = name.items;
        if (name.subset) then
            local subset = FastEquipMenu.GetEquipSet(name.subset);
            items = CreateFromMixins(subset, items);
        end
        for invSlot, itemLink in pairs(FastEquipMenu.GetEquipSetItems()) do
            if (FastEquipMenu.EquipItem(itemLink, invSlot)) then
                --print("Equipped "..itemLink);
            end
        end
    end
    ]]
    for invSlot, itemLink in pairs(FastEquipMenu.GetEquipSetItems(name)) do
        if (FastEquipMenu.EquipItem(itemLink, invSlot)) then
            --print("Equipped "..itemLink);
        end
    end
end

SLASH_EQUIPSET1 = "/equipset";
function SlashCmdList.EQUIPSET(equipSetName)
    FastEquipMenu.EquipSet(equipSetName);
end
