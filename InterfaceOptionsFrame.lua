-- https://wowwiki.fandom.com/wiki/Using_the_Interface_Options_Addons_panel

local AddOn = ...

local Title = GetAddOnMetadata(AddOn, "Title");

EQUIPMENTBARS_LABEL = "Hiya";
EQUIPMENTBARS_SUBTEXT = "Some info here!";

function InterfaceOptionsFrame_OnLoad(self)
    self.name = Title;
    self.okay = InterfaceOptionsFrame_Okay;
    self.cancel = InterfaceOptionsFrame_Cancel;
    self.default = InterfaceOptionsFrame_Default;
end

function InterfaceOptionsFrame_Okay(self)
end

function InterfaceOptionsFrame_Cancel(self)
end

function InterfaceOptionsFrame_Default(self)
end

SLASH_FASTEQUIPMENU1 = '/fem';
function SlashCmdList.FASTEQUIPMENU(arg1, arg2, arg3, arg4)
    print(arg1);
end
