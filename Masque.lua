local MasqueLib = LibStub("Masque", true) or (LibMasque and LibMasque("Button"));
if (MasqueLib == nil) then
    return;
end

local MasqueGroupEquipment = MasqueLib:Group(FEM_FAST_EQUIP_MENU, FEM_EQUIPMENT_BUTTONS, true);
if (MasqueGroupEquipment) then
    for _, button in ipairs(InventoryEquipmentBar.Buttons) do
        MasqueGroupEquipment:AddButton(button);
    end
end