-- US English is the only locale this addon ships.
local L = LibStub("AceLocale-3.0"):NewLocale("IncognitoContinued", "enUS",
                                             true)

if not L then return end

L["loaded"] = "Loaded (%s)."
L["version"] = "Version: %s"

L["generalSettings"] = "General Settings"
L["options"] = "Options"
L["profiles"] = "Profiles"

L["name"] = "Name"
L["name_desc"] = "The name that should be displayed in your chat messages."

L["enable"] = "Enable"
L["enable_desc"] = "Enable adding your name to chat messages."

L["guild"] = "Guild"
L["guild_desc"] = "Add name to guild chat messages (/g and /o)."
L["guildinfo"] =
    "Guild chat messages are generated from the Chat frame, not the Guild frame."

L["party"] = "Party"
L["party_desc"] = "Add name to party chat messages (/p)."

L["raid"] = "Raid"
L["raid_desc"] = "Add name to raid chat messages (/raid)."

L["lfr"] = "LFR"
L["lfr_desc"] = "Add name to LFR chat messages (/raid or /i)."

L["instance_chat"] = "Instance"
L["instance_chat_desc"] =
    "Add name to instance chat messages, e.g., LFR and battlegrounds (/i)."

L["world_chat"] = "World Chat"
L["world_chat_desc"] =
    "Add name to world chat messages, e.g., General, Trade, LocalDefense and Services."
L["world_chat_info_text"] =
    "This is an all or none option, you cannot select which World Channel to enable/disable"

L["config"] = "Configuration"
L["config_desc"] = "Open configuration window."

L["debug"] = "Debug"
L["debug_desc"] =
    "Enable debugging messages output. You probably don't want to enable this."

L["channel"] = "Channel"
L["channel_desc"] =
    "Add name to chat messages in this custom channel. Use comma to separate channel names."

L["community"] = "Community"
L["community_desc"] = "Add name to chat messages in the Community channels."

L["hideOnMatchingCharName"] = "Hide name if it matches your character's name"
L["hideOnMatchingCharName_desc"] =
    "If the name specified above matches your current character's name, Incognito Continued will not add it again if this option is checked."

L["channel_info_text"] =
    "Say channel is not an option. This is a limitation within the Blizzard API."
L["community_info_text"] =
    "Currently this is an all or nothing option for community channels."

L["ignoreLeadingSymbols"] = "Ignore leading symbols"
L["ignoreLeadingSymbols_desc"] =
    "If a message starts with any of these characters (after any spaces), do not add the name prefix."

L["bracketStyle"] = "Bracket style"
L["bracketStyle_desc"] =
    "Choose which brackets to surround your name with in chat messages."
L["bracketStyle_paren"] = "(round)"
L["bracketStyle_square"] = "[square]"
L["bracketStyle_curly"] = "{curly}"
L["bracketStyle_angle"] = "<angle>"

L["colorizePrefix"] = "Color name by class"
L["colorizePrefix_desc"] =
    "Color the Incognito name with the sender's class color. This only changes how messages look to you; it does not alter what you send."

L["partialMatchMode"] = "Partial match"
L["partialMatchMode_desc"] =
    "Hide the prefix when your character name matches the configured name by the selected rule (case-insensitive). Requires 'Hide name if it matches your character's name' to be enabled."
L["partialMatchMode_disabled"] = "Disabled"
L["partialMatchMode_start"] = "Start of name"
L["partialMatchMode_anywhere"] = "Anywhere"
L["partialMatchMode_end"] = "End of name"

L["help_header"] = "Available commands:"
L["help_config"] = "/inc - Open configuration"
L["help_enable"] = "/inc enable - Toggle addon on/off"
L["help_name"] = "/inc name <name> - Set display name"
L["help_debug"] = "/inc debug - Toggle debug mode"
L["help_help"] = "/inc help - Show this help"
L["help"] = "Help"
L["help_desc"] = "Show available commands"

L["msg_too_long"] =
    "Message too long to fit your name prefix; sent without it."

L["first_run_hint"] =
    "No name configured yet, so nothing will be added to your chat. Type /inc to set one."

L["old_folder_warning"] =
    "Both Incognito and IncognitoResurrected are loaded, so this copy is disabling its own chat hooks to avoid a doubled name prefix. Delete the IncognitoResurrected folder, then re-enter your settings with /inc -- they do not carry over automatically."

L["status_text"] =
    "Incognito Continued | https://www.curseforge.com/wow/addons/incognito-resurrected"
