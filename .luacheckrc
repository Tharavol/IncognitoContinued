std = "lua51"
exclude_files = {"Libs/**"}
max_line_length = false
ignore = {"212/self"} -- implicit self args are idiomatic for Ace3 ":" methods

-- Globals this addon itself defines
globals = {
    "IncognitoResurrected",
    "IsInLFR",
    "InterfaceOptionsFrame_OpenToCategory",
    "SlashCmdList" -- we register entries into this table
}

-- Ace3 loader + WoW API surface used by this addon
read_globals = {
    "LibStub",
    "UnitName",
    "UnitClass",
    "Ambiguate",
    "GetChannelName",
    "GetDifficultyInfo",
    "GetInstanceInfo",
    "GetPlayerInfoByGUID",
    "InCombatLockdown",
    "ChatFrame_AddMessageEventFilter",
    "ChatFrame_RemoveMessageEventFilter",
    "Settings",
    "strtrim",
    "strupper",
    "C_ChatInfo",
    "C_Club",
    "Enum",
    "CUSTOM_CLASS_COLORS",
    "RAID_CLASS_COLORS"
}
