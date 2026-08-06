--[[
Logic.lua - Pure helper functions with no dependency on the WoW API.

Everything in here is deliberately free of globals so it can be exercised
outside the game by the busted suite in Tests/. Anything that needs to talk to
the client belongs in Core.lua or ChatFilter.lua instead.
]] --
local ns = select(2, ...)
if type(ns) ~= "table" then ns = {} end

local Logic = {}
ns.Logic = Logic

-- The server silently truncates outgoing chat past this length, so a prefix
-- that pushes a message over the limit would eat the tail of what was typed.
Logic.MAX_CHAT_MESSAGE_LENGTH = 255

local BRACKETS = {
    paren = {"(", ")"},
    square = {"[", "]"},
    curly = {"{", "}"},
    angle = {"<", ">"}
}
Logic.BRACKETS = BRACKETS

local CLOSING_FOR = {}
for _, pair in pairs(BRACKETS) do CLOSING_FOR[pair[1]] = pair[2] end
Logic.CLOSING_FOR = CLOSING_FOR

local function trim(s) return (s:match("^%s*(.-)%s*$")) end
Logic.Trim = trim

--- Build the bracketed name prefix, e.g. "(Name): ".
function Logic.BuildPrefix(name, style)
    local pair = BRACKETS[style] or BRACKETS.paren
    return pair[1] .. (name or "") .. pair[2] .. ": "
end

--- True when the message opens with one of the configured "leave me alone"
--- characters, ignoring any leading whitespace.
function Logic.HasIgnoredLeadingSymbol(msg, symbols)
    if type(msg) ~= "string" or type(symbols) ~= "string" or symbols == "" then
        return false
    end
    local firstChar = msg:match("^%s*(.)")
    if not firstChar then return false end
    return symbols:find(firstChar, 1, true) ~= nil
end

--- True when the configured name matches the character name under `mode`.
--- Comparison is case-insensitive; `mode` is one of
--- "disabled" | "start" | "anywhere" | "end".
function Logic.NameMatchesCharacter(configuredName, characterName, mode)
    if type(configuredName) ~= "string" or configuredName == "" then
        return false
    end
    if type(characterName) ~= "string" or characterName == "" then
        return false
    end

    local n = configuredName:lower()
    local c = characterName:lower()
    if n == c then return true end

    if mode == "start" then
        return c:sub(1, #n) == n
    elseif mode == "anywhere" then
        return c:find(n, 1, true) ~= nil
    elseif mode == "end" then
        return c:sub(-#n) == n
    end
    return false
end

--- Whether the configured name should be shown at all, independent of channel.
function Logic.ShouldAddPrefix(profile, characterName)
    if not profile.name or profile.name == "" then return false end
    if profile.hideOnMatchingCharName and
        Logic.NameMatchesCharacter(profile.name, characterName,
                                   profile.partialMatchMode) then
        return false
    end
    return true
end

--- Whether this particular chat type is one the user opted into. `context`
--- carries the results of the WoW API lookups Core.lua resolves for the
--- chat type at hand: `isInLFR` for INSTANCE_CHAT, `channelName` for
--- CHANNEL. Neither is required for chat types that don't need it.
function Logic.WantsPrefixFor(profile, chatType, context)
    context = context or {}

    if chatType == "GUILD" or chatType == "OFFICER" then
        return profile.guild == true
    elseif chatType == "RAID" then
        return profile.raid == true
    elseif chatType == "PARTY" then
        return profile.party == true
    elseif chatType == "INSTANCE_CHAT" then
        if profile.instance_chat then return true end
        return profile.lfr == true and context.isInLFR == true
    elseif chatType == "CHANNEL" then
        if profile.world_chat then return true end
        if profile.channel and profile.channel ~= "" then
            return Logic.ChannelListMatches(profile.channel,
                                            context.channelName)
        end
        return false
    end

    return false
end

--- True when `channelName` appears in the comma-separated `list`.
--- Returns on the first hit, so duplicate entries cannot double-prefix.
function Logic.ChannelListMatches(list, channelName)
    if type(list) ~= "string" or list == "" then return false end
    if type(channelName) ~= "string" or channelName == "" then return false end

    local target = channelName:upper()
    for entry in list:gmatch("([^,]+)") do
        local name = trim(entry)
        if name ~= "" and name:upper() == target then return true end
    end
    return false
end

--- True when prefix .. msg still fits inside a single chat message.
function Logic.FitsInChatMessage(prefix, msg)
    return (#(prefix or "") + #(msg or "")) <= Logic.MAX_CHAT_MESSAGE_LENGTH
end

--- Split a WoW community channel name ("Community:<clubId>:<streamId>").
--- Returns clubId, streamId, or nil when the name is not a community channel.
function Logic.ParseCommunityChannel(channelName)
    if type(channelName) ~= "string" then return nil end
    local clubId, streamId = channelName:match("^Community:(.-):(.-)$")
    if clubId and clubId ~= "" and streamId and streamId ~= "" then
        return clubId, streamId
    end
    return nil
end

--- Pull apart a leading bracketed prefix from an incoming chat message.
--- Accepts "(Name):msg", "(Name): msg", "(Name) :msg" and "(Name) : msg".
--- Returns a table of parts, or nil when the message has no matching prefix.
function Logic.ParseBracketedPrefix(msg)
    if type(msg) ~= "string" then return nil end

    local pre, open, name, close, gap, colonGap, rest = msg:match(
                                                            "^(%s*)([%(%[%{%<])([^%(%[%{%<%)%]%}%>]+)([%)%]%}%>])(%s*):(%s*)(.*)$")
    if not open then return nil end
    if CLOSING_FOR[open] ~= close then return nil end

    return {
        pre = pre,
        open = open,
        name = name,
        close = close,
        gap = gap,
        colonGap = colonGap,
        rest = rest
    }
end

--- Reassemble a parsed prefix with `colorCode` applied to the name only.
function Logic.ColorizeParsedPrefix(parts, colorCode)
    return string.format("%s%s%s%s|r%s%s:%s%s", parts.pre, parts.open,
                         colorCode, parts.name, parts.close, parts.gap,
                         parts.colonGap, parts.rest)
end

--- Format a WoW colour escape from 0-1 float components.
function Logic.ColorCode(r, g, b)
    return string.format("|cff%02x%02x%02x", math.floor((r or 1) * 255 + 0.5),
                         math.floor((g or 1) * 255 + 0.5),
                         math.floor((b or 1) * 255 + 0.5))
end

return ns.Logic
