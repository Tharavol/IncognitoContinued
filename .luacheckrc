std = "lua51"
-- .luarocks/.luarocks are left behind by CI's local luarocks install; Libs/
-- is vendored Ace3.
exclude_files = {"Libs/**", ".luarocks/**", ".luarocks", "lua_modules/**"}
max_line_length = false
ignore = {"212/self"} -- implicit self args are idiomatic for Ace3 ":" methods

-- Globals this addon itself defines
globals = {
    "IncognitoResurrected",
    "IncognitoResurrected_OnAddonCompartmentClick" -- ## AddonCompartmentFunc
}

-- Ace3 loader + WoW API surface used by this addon
read_globals = {
    "LibStub",
    "UnitName",
    "UnitClass",
    "Ambiguate",
    "GetChannelName",
    "GetInstanceInfo",
    "GetPlayerInfoByGUID",
    "InCombatLockdown",
    "ChatFrame_AddMessageEventFilter",
    "ChatFrame_RemoveMessageEventFilter",
    "C_ChatInfo",
    "C_Club",
    "C_AddOns",
    "Enum",
    "CUSTOM_CLASS_COLORS",
    "RAID_CLASS_COLORS"
}

-- Logic.lua is deliberately free of the WoW API so it can run under busted.
files["Logic.lua"] = {globals = {}, read_globals = {}}

files["Tests/"] = {std = "lua51+busted", read_globals = {}}
