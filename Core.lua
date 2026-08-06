--[[
Core.lua - Addon object, saved variables, chat hooks and combat handling.
]] --
local addonName, ns = ...

-- The packaged folder is "Incognito" (see .pkgmeta), same as Nyyr's original
-- Incognito addon. AceAddon/AceLocale/AceConfig/AceDBOptions are all shared
-- global registries, so this addon registers under the distinct name
-- IncognitoContinued instead of addonName to avoid contesting them with the
-- original.
local ADDON_ID = "IncognitoContinued"
ns.ADDON_ID = ADDON_ID

local L = LibStub("AceLocale-3.0"):GetLocale(ADDON_ID, true)
local Logic = ns.Logic

local format = string.format

--- Global addon object. Kept as a global for backwards compatibility with
--- macros and other addons that look it up by name.
local AceAddon = LibStub("AceAddon-3.0")
local ok, addonOrErr = pcall(AceAddon.NewAddon, AceAddon, ADDON_ID,
                             "AceConsole-3.0", "AceEvent-3.0", "AceHook-3.0")
if not ok then
    print(format("|cffff0000%s|r failed to load: %s", ADDON_ID,
                 tostring(addonOrErr)))
    return
end
IncognitoContinued = addonOrErr

local addon = IncognitoContinued
ns.addon = addon
ns.version = C_AddOns.GetAddOnMetadata(addonName, "Version")

ns.defaults = {
    global = {firstRunHintShown = false},
    profile = {
        enable = true,
        guild = true,
        party = false,
        raid = false,
        lfr = false,
        instance_chat = false,
        world_chat = false,
        debug = false,
        channel = nil,
        community = false,
        hideOnMatchingCharName = true,
        partialMatchMode = "disabled",
        -- Leading characters that suppress the prefix entirely
        ignoreLeadingSymbols = "/!#@?",
        bracketStyle = "paren",
        -- Class-color the bracketed prefix in chat frames (display only)
        colorizePrefix = true
    }
}

local SLASH_COMMANDS = {"inc", "incognito", "incognitoresurrected"}

-- LFR raids report the "raid" instance type with difficulty 17.
local function IsInLFR()
    local _, instanceType, difficultyID = GetInstanceInfo()
    return instanceType == "raid" and difficultyID == 17
end

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

--- Print only when debug output is enabled. Takes a format string so callers
--- do not pay for string concatenation when debugging is off.
function addon:Debug(fmt, ...)
    if not (self.db and self.db.profile and self.db.profile.debug) then
        return
    end
    if select("#", ...) > 0 then
        self:Print(format(fmt, ...))
    else
        self:Print(fmt)
    end
end

function addon:GetNamePrefix()
    local profile = self.db.profile
    return Logic.BuildPrefix(profile.name, profile.bracketStyle)
end

--- Prepend the name prefix unless doing so would overflow the chat limit.
function addon:ApplyPrefix(msg)
    local prefix = self:GetNamePrefix()
    if not Logic.FitsInChatMessage(prefix, msg) then
        self:Print(L["msg_too_long"])
        return msg
    end
    return prefix .. msg
end

--- Whether the configured name should be shown at all, independent of channel.
function addon:ShouldAddPrefix()
    return Logic.ShouldAddPrefix(self.db.profile, self.character_name)
end

--- Whether this particular chat type is one the user opted into. Resolves
--- the WoW API lookups the decision needs and hands off to Logic.lua, which
--- holds the actual chat-type matrix and is covered by the busted suite.
function addon:WantsPrefixFor(chatType, target)
    local context = {}
    if chatType == "INSTANCE_CHAT" then
        context.isInLFR = IsInLFR()
    elseif chatType == "CHANNEL" then
        local _, channelName = GetChannelName(target)
        context.channelName = channelName
    end
    return Logic.WantsPrefixFor(self.db.profile, chatType, context)
end

--------------------------------------------------------------------------------
-- Hooks
--------------------------------------------------------------------------------

--- Install the chat hooks. Safe to call repeatedly; no-ops in combat.
function addon:SetupHooks()
    if InCombatLockdown() then return end

    if not self:IsHooked(C_ChatInfo, "SendChatMessage") then
        self:RawHook(C_ChatInfo, "SendChatMessage", "OnSendChatMessage", true)
    end

    if type(C_Club) == "table" and type(C_Club.SendMessage) == "function" and
        not self:IsHooked(C_Club, "SendMessage") then
        self:RawHook(C_Club, "SendMessage", "OnClubSendMessage", true)
    end
end

function addon:RemoveHooks()
    if self:IsHooked(C_ChatInfo, "SendChatMessage") then
        self:Unhook(C_ChatInfo, "SendChatMessage")
    end
    if type(C_Club) == "table" and self:IsHooked(C_Club, "SendMessage") then
        self:Unhook(C_Club, "SendMessage")
    end
end

-- The client blocks any call that passes through an addon-replaced protected
-- function while in combat, even when the replacement just calls straight
-- through to the original. So rather than trying to be clever inside the hook,
-- remove the hooks entirely for the duration of combat.
function addon:OnCombatStart() self:RemoveHooks() end

function addon:OnCombatEnd() self:SetupHooks() end

function addon:OnSendChatMessage(msg, chatType, language, target)
    local original = self.hooks[C_ChatInfo].SendChatMessage
    local profile = self.db and self.db.profile

    -- Bail out early for anything we must not touch: combat (see above),
    -- the addon being disabled, slash commands with no chat type, and
    -- messages the user marked as off-limits with a leading symbol.
    if not profile or not profile.enable or InCombatLockdown() then
        return original(msg, chatType, language, target)
    end
    if not chatType or chatType == "" or type(msg) ~= "string" then
        return original(msg, chatType, language, target)
    end
    if Logic.HasIgnoredLeadingSymbol(msg, profile.ignoreLeadingSymbols) then
        return original(msg, chatType, language, target)
    end

    -- Community channels reach us as CHANNEL sends with a synthetic name;
    -- re-route them through the club API so they take the community path.
    if profile.community and chatType == "CHANNEL" then
        local _, channelName = GetChannelName(target)
        self:Debug("Channel name: %s", tostring(channelName))
        local clubId, streamId = Logic.ParseCommunityChannel(channelName)
        if clubId then
            self:Debug("Community channel clubId=%s streamId=%s", clubId,
                       streamId)
            self:SendToClub(clubId, streamId, msg)
            return
        end
    end

    if self:ShouldAddPrefix() and self:WantsPrefixFor(chatType, target) then
        msg = self:ApplyPrefix(msg)
    end

    return original(msg, chatType, language, target)
end

--- Route a message to the club API, going through our hook when it is
--- installed so the prefix logic still runs.
function addon:SendToClub(clubId, streamId, msg)
    if self:IsHooked(C_Club, "SendMessage") then
        self:OnClubSendMessage(clubId, streamId, msg)
    else
        C_Club.SendMessage(clubId, streamId, msg)
    end
end

function addon:OnClubSendMessage(clubId, streamId, msg)
    local original = self.hooks[C_Club].SendMessage
    local profile = self.db and self.db.profile

    self:Debug("Club send clubId=%s streamId=%s", tostring(clubId),
               tostring(streamId))

    if not profile or not profile.enable or not profile.community or
        InCombatLockdown() then
        return original(clubId, streamId, msg)
    end
    if type(msg) ~= "string" then
        return original(clubId, streamId, msg)
    end
    if Logic.HasIgnoredLeadingSymbol(msg, profile.ignoreLeadingSymbols) then
        self:Debug("Ignoring due to leading symbol")
        return original(clubId, streamId, msg)
    end

    local clubInfo = C_Club.GetClubInfo(clubId)
    if not clubInfo then
        self:Debug("No clubInfo for %s", tostring(clubId))
        return original(clubId, streamId, msg)
    end

    self:Debug("Club type: %s", tostring(clubInfo.clubType))
    local isCommunity = clubInfo.clubType == Enum.ClubType.BattleNet or
                            clubInfo.clubType == Enum.ClubType.Character
    if isCommunity and self:ShouldAddPrefix() then
        msg = self:ApplyPrefix(msg)
    end

    return original(clubId, streamId, msg)
end

--------------------------------------------------------------------------------
-- Configuration UI entry points
--------------------------------------------------------------------------------

function addon:OpenConfig()
    local dialog = LibStub("AceConfigDialog-3.0")
    dialog:Open(ADDON_ID .. " Options")

    local frame = dialog.OpenFrames[ADDON_ID .. " Options"]
    if frame and frame.frame then
        frame.frame:SetHeight(580)
        if frame.statustext then
            frame.statustext:SetText(L["status_text"])
        end
    end
end

function addon:HandleSlashCommand(input)
    if not input or input:trim() == "" then
        self:OpenConfig()
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("inc", ADDON_ID, input)
    end
end

-- Entry point for the minimap addon compartment (see the .toc).
function IncognitoContinued_OnAddonCompartmentClick()
    addon:OpenConfig()
end

--------------------------------------------------------------------------------
-- Lifecycle
--------------------------------------------------------------------------------

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New(ADDON_ID .. "DB", ns.defaults, true)
    self.character_name = UnitName("player")

    local config = LibStub("AceConfig-3.0")
    local registry = LibStub("AceConfigRegistry-3.0")
    local dialog = LibStub("AceConfigDialog-3.0")

    config:RegisterOptionsTable(ADDON_ID, ns.slashOptions)
    registry:RegisterOptionsTable(ADDON_ID .. " Options", ns.options)
    registry:RegisterOptionsTable(ADDON_ID .. " Profiles",
                                  LibStub("AceDBOptions-3.0"):GetOptionsTable(
                                      self.db))

    self.optionFrames = {
        main = dialog:AddToBlizOptions(ADDON_ID .. " Options", ADDON_ID),
        profiles = dialog:AddToBlizOptions(ADDON_ID .. " Profiles",
                                           L["profiles"], ADDON_ID)
    }

    for _, command in ipairs(SLASH_COMMANDS) do
        self:RegisterChatCommand(command, "HandleSlashCommand")
    end

    self:Print(format(L["loaded"], ns.version))

    -- Nothing happens until a name is configured, so point first-time users at
    -- the config rather than leaving them to wonder why the addon is silent.
    if not self.db.global.firstRunHintShown then
        if not self.db.profile.name or self.db.profile.name == "" then
            self:Print(L["first_run_hint"])
            self.db.global.firstRunHintShown = true
        end
    end
end

-- Remove this guard two or three releases after v1.8.0, once few enough
-- users still have the old folder installed for it to matter (see #12).
local OLD_FOLDER_NAME = "IncognitoResurrected"

--- If the pre-rename folder is still installed and loaded alongside this
--- one, both install chat hooks and both would prefix every message. Warn
--- and drop our own hooks in favor of the copy that's already running,
--- rather than silently doubling the prefix.
function addon:CheckOldFolder()
    if not C_AddOns.IsAddOnLoaded(OLD_FOLDER_NAME) then return end
    self:Print(L["old_folder_warning"])
    self:RemoveHooks()
end

function addon:OnEnable()
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnCombatStart")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnCombatEnd")
    self:RegisterChatFilters()
    self:SetupHooks()

    -- Folder load order is alphabetical, so the old IncognitoResurrected
    -- folder loads after this one and is not yet reflected in
    -- IsAddOnLoaded() during our own OnEnable. Check now if login has
    -- already completed (e.g. a manual /reload of just this addon),
    -- otherwise wait for it.
    if IsLoggedIn() then
        self:CheckOldFolder()
    else
        self:RegisterEvent("PLAYER_LOGIN", "CheckOldFolder")
    end
end

function addon:OnDisable()
    self:UnregisterChatFilters()
    self:RemoveHooks()
end
