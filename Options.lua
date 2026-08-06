--[[
Options.lua - AceConfig option tables for the GUI panel and slash commands.
]] --
local _, ns = ...

local L = LibStub("AceLocale-3.0"):GetLocale("IncognitoResurrected", true)
local addon = ns.addon

local format = string.format

local function Get(item) return addon.db.profile[item[#item]] end
local function Set(item, value) addon.db.profile[item[#item]] = value end

ns.options = {
    name = "Incognito Resurrected",
    type = "group",
    args = {
        version = {
            order = -1,
            type = "description",
            name = "|cFF808080" .. format(L["version"], ns.version) .. "|r",
            fontSize = "medium"
        },
        generalSettings = {
            name = L["generalSettings"],
            type = "group",
            inline = true,
            order = 0,
            get = Get,
            set = Set,
            args = {
                name = {
                    order = 1,
                    type = "input",
                    width = "normal",
                    name = L["name"],
                    desc = L["name_desc"]
                },
                spacer1 = {
                    order = 1.5,
                    type = "description",
                    width = "double",
                    name = ""
                },
                enable = {
                    order = 2,
                    type = "toggle",
                    name = L["enable"],
                    desc = L["enable_desc"],
                    width = "normal"
                },
                spacer2 = {
                    order = 2.5,
                    type = "description",
                    width = "half",
                    name = ""
                },
                hideOnMatchingCharName = {
                    order = 3,
                    type = "toggle",
                    name = L["hideOnMatchingCharName"],
                    desc = L["hideOnMatchingCharName_desc"],
                    width = "double"
                },
                partialMatchMode = {
                    order = 4,
                    type = "select",
                    name = L["partialMatchMode"],
                    desc = L["partialMatchMode_desc"],
                    values = {
                        disabled = L["partialMatchMode_disabled"],
                        start = L["partialMatchMode_start"],
                        anywhere = L["partialMatchMode_anywhere"],
                        ["end"] = L["partialMatchMode_end"]
                    },
                    sorting = {"disabled", "start", "anywhere", "end"},
                    width = "normal",
                    disabled = function()
                        return not addon.db.profile.hideOnMatchingCharName
                    end
                },
                spacer3 = {
                    order = 4.5,
                    type = "description",
                    width = "half",
                    name = ""
                },
                colorizePrefix = {
                    order = 5,
                    type = "toggle",
                    name = L["colorizePrefix"],
                    desc = L["colorizePrefix_desc"],
                    width = "double"
                },
                ignoreLeadingSymbols = {
                    order = 6,
                    type = "input",
                    name = L["ignoreLeadingSymbols"],
                    desc = L["ignoreLeadingSymbols_desc"],
                    width = "normal"
                },
                spacer4 = {
                    order = 7,
                    type = "description",
                    width = "half",
                    name = ""
                },
                bracketStyle = {
                    order = 8,
                    type = "select",
                    name = L["bracketStyle"],
                    desc = L["bracketStyle_desc"],
                    values = {
                        paren = L["bracketStyle_paren"],
                        square = L["bracketStyle_square"],
                        curly = L["bracketStyle_curly"],
                        angle = L["bracketStyle_angle"]
                    },
                    sorting = {"paren", "square", "curly", "angle"}
                }
            }
        },
        generalOptions = {
            name = L["options"],
            type = "group",
            inline = true,
            order = 1,
            get = Get,
            set = Set,
            args = {
                guild = {
                    order = 1,
                    type = "toggle",
                    width = "full",
                    name = L["guild"],
                    desc = L["guild_desc"]
                },
                guildinfo = {
                    order = 1.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["guildinfo"]
                },
                party = {
                    order = 2,
                    type = "toggle",
                    width = 0.6,
                    name = L["party"],
                    desc = L["party_desc"]
                },
                raid = {
                    order = 3,
                    type = "toggle",
                    width = 0.6,
                    name = L["raid"],
                    desc = L["raid_desc"]
                },
                lfr = {
                    order = 4,
                    type = "toggle",
                    width = 0.6,
                    name = L["lfr"],
                    desc = L["lfr_desc"]
                },
                instance_chat = {
                    order = 5,
                    type = "toggle",
                    width = 0.6,
                    name = L["instance_chat"],
                    desc = L["instance_chat_desc"]
                },
                world_chat = {
                    order = 6,
                    type = "toggle",
                    width = "full",
                    name = L["world_chat"],
                    desc = L["world_chat_desc"]
                },
                world_chat_info = {
                    order = 6.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["world_chat_info_text"]
                },
                channel = {
                    order = 7,
                    type = "input",
                    name = L["channel"],
                    desc = L["channel_desc"]
                },
                channelinfo = {
                    order = 7.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["channel_info_text"]
                },
                community = {
                    order = 8,
                    type = "toggle",
                    width = "full",
                    name = L["community"],
                    desc = L["community_desc"]
                },
                communityinfo = {
                    order = 8.5,
                    type = "description",
                    name = "|cFFFFA500" .. L["community_info_text"]
                },
                debug = {
                    order = 9,
                    type = "toggle",
                    width = "full",
                    name = L["debug"],
                    desc = L["debug_desc"]
                }
            }
        }
    }
}

ns.slashOptions = {
    type = "group",
    handler = addon,
    get = Get,
    set = Set,
    args = {
        enable = {name = L["enable"], desc = L["enable_desc"], type = "toggle"},
        name = {name = L["name"], desc = L["name_desc"], type = "input"},
        config = {
            name = L["config"],
            desc = L["config_desc"],
            type = "execute",
            func = function() addon:OpenConfig() end
        },
        debug = {
            name = L["debug"],
            desc = L["debug_desc"],
            type = "toggle",
            set = function(_item, value)
                addon.db.profile.debug = value
                addon:Print(L["debug"] .. ": " .. (value and "ON" or "OFF"))
            end
        },
        help = {
            name = L["help"],
            desc = L["help_desc"],
            type = "execute",
            func = function()
                addon:Print(L["help_header"])
                addon:Print(L["help_config"])
                addon:Print(L["help_enable"])
                addon:Print(L["help_name"])
                addon:Print(L["help_debug"])
                addon:Print(L["help_help"])
            end
        }
    }
}
