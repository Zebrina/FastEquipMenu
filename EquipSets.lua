-- Classic only.
if (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE) then
    return;
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
        if (equipSet.inherits) then
            Mixin(items, FastEquipMenu.GetEquipSetItems(equipSet.inherits));
        end
        if (equipSet.items) then
            Mixin(items, equipSet.items);
        end
    end
    return items;
end

-- RETURNS: itemLink, isInherited
function FastEquipMenu.GetEquipSetItemBySlot(name, invSlot)
    local equipSet = FastEquipMenu.GetEquipSet(name);
    local itemLink;
    local isInherited = false;
    if (equipSet) then
        itemLink = equipSet.items[invSlot]
        isInherited = false;
        if (not itemLink and equipSet.inherits) then
            itemLink = FastEquipMenu.GetEquipSetItemBySlot(equipSet.inherits, invSlot);
            isInherited = itemLink and true or false;
        end
    end
    return itemLink, isInherited;
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

function FastEquipMenu.AddEquipSet(name, inherits)
    local key = EquipSetKey(name);
    if (FEM_EquipSets[key] == nil) then
        local newEquipSet = {
            name = name,
            inherits = inherits,
            items = {},
        };

        FEM_EquipSets[key] = newEquipSet;

        --ContainerEquipmentFrameContextMenu_Show(ContainerEquipmentFrameContextMenu_Button);
        --UIDropDownMenu_SetSelectedValue(ContainerEquipmentFrameContextMenu, "ITEMSETS");
    --else
        -- TODO: Add already exists error message.
    end
end

function FastEquipMenu.CopyEquipSet(name, equipSetOrNameToCopy)
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
            newEquipSet.inherits = equipSetOrNameToCopy.inherits;
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
        if (name.inherits) then
            local subset = FastEquipMenu.GetEquipSet(name.inherits);
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
