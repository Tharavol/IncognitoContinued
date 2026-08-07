--[[
ChatFilter.lua - Client-side rendering of the bracketed prefix in class colors.

This only changes how incoming messages are drawn in your chat frames; it never
alters what is sent.
]] --
local _, ns = ...

local addon = ns.addon
local Logic = ns.Logic

local FILTER_EVENTS = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_EMOTE", "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER", "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING", "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_CHANNEL",
    "CHAT_MSG_COMMUNITIES_CHANNEL", "CHAT_MSG_WHISPER",
    "CHAT_MSG_WHISPER_INFORM"
}

--- Chat event args carry the sender GUID at a position that varies by event,
--- so pick it out by shape instead of by index.
local function ExtractPlayerGUID(...)
    for i = 1, select("#", ...) do
        local value = select(i, ...)
        if type(value) == "string" and value:match("^Player%-") then
            return value
        end
    end
end

local function ResolveClassFile(author, ...)
    local guid = ExtractPlayerGUID(...)
    if guid and GetPlayerInfoByGUID then
        local _, classFile = GetPlayerInfoByGUID(guid)
        if classFile then return classFile end
    end
    if author and UnitClass then
        local unit = Ambiguate and Ambiguate(author, "none") or author
        local _, classFile = UnitClass(unit)
        return classFile
    end
end

function addon:ChatPrefixColorFilter(_frame, _event, msg, author, ...)
    local profile = self.db and self.db.profile
    if not (profile and profile.enable and profile.colorizePrefix) then
        return false
    end

    local parts = Logic.ParseBracketedPrefix(msg)
    if not parts then return false end
    if not Logic.LooksLikeOwnPrefix(parts, profile.bracketStyle) then
        return false
    end

    local classFile = ResolveClassFile(author, ...)
    if not classFile then return false end

    local colors = (type(CUSTOM_CLASS_COLORS) == "table" and CUSTOM_CLASS_COLORS) or
                       RAID_CLASS_COLORS
    local color = colors and colors[classFile]
    if not color then return false end

    local newMsg = Logic.ColorizeParsedPrefix(parts, Logic.ColorCode(color.r,
                                                                    color.g,
                                                                    color.b))
    return false, newMsg, author, ...
end

function addon:RegisterChatFilters()
    if self._filtersRegistered then return end

    self._chatFilter = self._chatFilter or
                           function(frame, event, msg, author, ...)
            return addon:ChatPrefixColorFilter(frame, event, msg, author, ...)
        end

    for _, event in ipairs(FILTER_EVENTS) do
        ChatFrame_AddMessageEventFilter(event, self._chatFilter)
    end
    self._filtersRegistered = true
end

function addon:UnregisterChatFilters()
    if not self._filtersRegistered then return end
    for _, event in ipairs(FILTER_EVENTS) do
        ChatFrame_RemoveMessageEventFilter(event, self._chatFilter)
    end
    self._filtersRegistered = false
end
