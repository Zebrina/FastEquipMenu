-- API table
FastEquipMenu = {};
FEM = FastEquipMenu;

-- TODO: Don't reset existing data.
-- PLACEHOLDER CONFIG TABLE
FEM_GlobalOptions = FEM_GlobalOptions or {
    InventorySlots = {
        ButtonOrder = {

        },
        BarRows = 2,
        BarGrowth = "TOP",
        HEADSLOT = {
            hide = false,
            hideEmpty = true,
            hideUnusable = true,
        },
        NECKSLOT = {
            hide = false,
        },
        SHOULDERSLOT = {
            hide = false,
        },
        BACKSLOT = {
            hide = false,
        },
        CHESTSLOT = {
            hide = false,
        },
        WRISTSLOT = {
            hide = false,
        },
        HANDSSLOT = {
            hide = false,
        },
        WAISTSLOT = {
            hide = false,
        },
        LEGSSLOT = {
            hide = false,
        },
        FEETSLOT = {
            hide = false,
        },
        FINGER0SLOT = {
            hide = false,
        },
        FINGER1SLOT = {
            hide = false,
        },
        TRINKET0SLOT = {
            hide = false,
            hideEmpty = true,
        },
        TRINKET1SLOT = {
            hide = false,
            hideEmpty = true,
        },
        MAINHANDSLOT = {
            hide = false,
        },
        SECONDARYHANDSLOT = {
            hide = false,
        },
        RANGEDSLOT = {
            hide = false,
            hideEmpty = true,
        },
    },
    ItemSets = {

    },
};

-- TODO: Don't reset existing data.
FEM_CharacterOptions = {

};

FEM_EquipSets = FEM_EquipSets or {};

-- StaticPopup_Show("FEM_ADD_ITEM_SET");
StaticPopupDialogs["FEM_ADD_ITEM_SET"] = {
    text = FEM_ADD_ITEM_SET_LABEL,
    button1 = ACCEPT,
    button2 = CANCEL,
    hasEditBox = 1,
    OnAccept = function(self)
        FastEquipMenu.AddEquipSet(self.editBox:GetText());
    end,
    OnShow = function(self)
        self.editBox:SetFocus();
    end,
    OnHide = function(self)
        ChatEdit_FocusActiveWindow();
        self.editBox:SetText("");
    end,
    EditBoxOnTextChanged = function (self, data)
        -- Disables (greys out) accept button when text input is empty.
        local parent = self:GetParent();
        parent.button1:SetEnabled(strlen(parent.editBox:GetText()) > 0);
    end,
    EditBoxOnEnterPressed = function(self)
        local parent = self:GetParent();
        FastEquipMenu.AddEquipSet(parent.editBox:GetText());
        parent:Hide();
    end,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide();
    end,
    timeout = 0,
    exclusive = 1,
    whileDead = 1,
    hideOnEscape = 1,
};

-- Slash Commands

SLASH_EQUIPSET1 = "/equipset";
function SlashCmdList.EQUIPSET(equipSetName)
    FastEquipMenu.EquipSet(equipSetName);
end

SLASH_REMOVESET1 = "/removeset";
function SlashCmdList.REMOVESET(equipSetName)
    FastEquipMenu.RemoveEquipSet(equipSetName);
end

-- TODO: REMOVE
SLASH_VIEWSET1 = "/viewset";
function SlashCmdList.VIEWSET(equipSetName)
    if (equipSetName) then
        if (EquipSetFrame:IsShown()) then
            EquipSetFrame:Hide();
        end
        EquipSetFrame.viewedEquipSet = equipSetName;
        EquipSetFrame:Show();
    end
end

SLASH_ADDSET1 = "/addset";
function SlashCmdList.ADDSET(equipSetName)
    FastEquipMenu.AddEquipSet(equipSetName);
end

SLASH_REMOVESET1 = "/removeset";
function SlashCmdList.REMOVESET(equipSetName)
    FastEquipMenu.RemoveEquipSet(equipSetName);
end

SLASH_SAVEREPAIR1 = "/saverepair";
function SlashCmdList.SAVEREPAIR()
    FastEquipMenu.EquipItem("EMPTY", 1);
    FastEquipMenu.EquipItem("EMPTY", 3);
    FastEquipMenu.EquipItem("EMPTY", 5);
    FastEquipMenu.EquipItem("EMPTY", 6);
    FastEquipMenu.EquipItem("EMPTY", 7);
    FastEquipMenu.EquipItem("EMPTY", 8);
    FastEquipMenu.EquipItem("EMPTY", 9);
    FastEquipMenu.EquipItem("EMPTY", 10);
    FastEquipMenu.EquipItem("EMPTY", 16);
    FastEquipMenu.EquipItem("EMPTY", 17);
    FastEquipMenu.EquipItem("EMPTY", 18);
end
