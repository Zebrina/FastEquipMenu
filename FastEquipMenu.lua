-- API table
FastEquipMenu = {};
FEM = FastEquipMenu;

-- TODO: Don't reset existing data.
-- PLACEHOLDER CONFIG TABLE
FEM_GlobalOptions = {
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

-- TODO: Don't reset existing data.
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
