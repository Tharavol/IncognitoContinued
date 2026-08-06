local Logic = require("Logic")

describe("BuildPrefix", function()
    it("wraps the name in the configured brackets", function()
        assert.equal("(Bob): ", Logic.BuildPrefix("Bob", "paren"))
        assert.equal("[Bob]: ", Logic.BuildPrefix("Bob", "square"))
        assert.equal("{Bob}: ", Logic.BuildPrefix("Bob", "curly"))
        assert.equal("<Bob>: ", Logic.BuildPrefix("Bob", "angle"))
    end)

    it("falls back to round brackets for unknown styles", function()
        assert.equal("(Bob): ", Logic.BuildPrefix("Bob", "nonsense"))
        assert.equal("(Bob): ", Logic.BuildPrefix("Bob", nil))
    end)

    it("tolerates a missing name", function()
        assert.equal("(): ", Logic.BuildPrefix(nil, "paren"))
    end)
end)

describe("HasIgnoredLeadingSymbol", function()
    it("matches the first non-space character", function()
        assert.is_true(Logic.HasIgnoredLeadingSymbol("/say hi", "/!#"))
        assert.is_true(Logic.HasIgnoredLeadingSymbol("   !alert", "/!#"))
        assert.is_false(Logic.HasIgnoredLeadingSymbol("hello", "/!#"))
    end)

    it("does not match symbols that appear later in the message", function()
        assert.is_false(Logic.HasIgnoredLeadingSymbol("what a / mess", "/!#"))
    end)

    it("handles empty input", function()
        assert.is_false(Logic.HasIgnoredLeadingSymbol("", "/!#"))
        assert.is_false(Logic.HasIgnoredLeadingSymbol("/x", ""))
        assert.is_false(Logic.HasIgnoredLeadingSymbol(nil, "/!#"))
    end)
end)

describe("NameMatchesCharacter", function()
    it("matches exactly, case-insensitively, in any mode", function()
        assert.is_true(Logic.NameMatchesCharacter("bob", "Bob", "disabled"))
        assert.is_true(Logic.NameMatchesCharacter("BOB", "bob", nil))
    end)

    it("honours the start mode", function()
        assert.is_true(Logic.NameMatchesCharacter("Bob", "Bobbington", "start"))
        assert.is_false(Logic.NameMatchesCharacter("Bob", "Rebob", "start"))
    end)

    it("honours the anywhere mode", function()
        assert.is_true(Logic.NameMatchesCharacter("bob", "Rebobbed", "anywhere"))
        assert.is_false(Logic.NameMatchesCharacter("bob", "Alice", "anywhere"))
    end)

    it("honours the end mode", function()
        assert.is_true(Logic.NameMatchesCharacter("bob", "Rebob", "end"))
        assert.is_false(Logic.NameMatchesCharacter("bob", "Bobbington", "end"))
    end)

    it("never matches on empty input", function()
        assert.is_false(Logic.NameMatchesCharacter("", "Bob", "anywhere"))
        assert.is_false(Logic.NameMatchesCharacter("Bob", "", "anywhere"))
        assert.is_false(Logic.NameMatchesCharacter(nil, "Bob", "anywhere"))
    end)
end)

describe("ChannelListMatches", function()
    it("matches a single entry regardless of case or padding", function()
        assert.is_true(Logic.ChannelListMatches("trade", "Trade"))
        assert.is_true(Logic.ChannelListMatches("  Trade  ", "trade"))
    end)

    it("matches any entry in a comma separated list", function()
        assert.is_true(Logic.ChannelListMatches("General, Trade, Services",
                                                "Trade"))
        assert.is_false(Logic.ChannelListMatches("General, Trade", "LookingFor"))
    end)

    -- Regression: the old loop kept going after a hit and prefixed once per
    -- duplicate entry.
    it("returns a single boolean for duplicate entries", function()
        assert.is_true(Logic.ChannelListMatches("Trade,Trade,Trade", "Trade"))
    end)

    it("handles empty input", function()
        assert.is_false(Logic.ChannelListMatches("", "Trade"))
        assert.is_false(Logic.ChannelListMatches("Trade", ""))
        assert.is_false(Logic.ChannelListMatches(nil, "Trade"))
    end)
end)

describe("FitsInChatMessage", function()
    it("allows a message that exactly fills the limit", function()
        local prefix = Logic.BuildPrefix("Bob", "paren") -- 7 chars
        local msg = string.rep("a", Logic.MAX_CHAT_MESSAGE_LENGTH - #prefix)
        assert.is_true(Logic.FitsInChatMessage(prefix, msg))
    end)

    it("rejects a message one character over the limit", function()
        local prefix = Logic.BuildPrefix("Bob", "paren")
        local msg = string.rep("a", Logic.MAX_CHAT_MESSAGE_LENGTH - #prefix + 1)
        assert.is_false(Logic.FitsInChatMessage(prefix, msg))
    end)
end)

describe("ParseCommunityChannel", function()
    it("splits a community channel name", function()
        local clubId, streamId = Logic.ParseCommunityChannel("Community:123:4")
        assert.equal("123", clubId)
        assert.equal("4", streamId)
    end)

    it("ignores ordinary channel names", function()
        assert.is_nil(Logic.ParseCommunityChannel("Trade"))
        assert.is_nil(Logic.ParseCommunityChannel("Community:123"))
        assert.is_nil(Logic.ParseCommunityChannel(nil))
    end)
end)

describe("ParseBracketedPrefix", function()
    it("accepts the spacing variants around the colon", function()
        for _, msg in ipairs({
            "(Bob):hi", "(Bob): hi", "(Bob) :hi", "(Bob) : hi"
        }) do
            local parts = Logic.ParseBracketedPrefix(msg)
            assert.is_table(parts, msg)
            assert.equal("Bob", parts.name)
            assert.equal("hi", parts.rest)
        end
    end)

    it("accepts every bracket style", function()
        for _, msg in ipairs({"(Bob): hi", "[Bob]: hi", "{Bob}: hi", "<Bob>: hi"}) do
            assert.is_table(Logic.ParseBracketedPrefix(msg), msg)
        end
    end)

    it("rejects mismatched brackets", function()
        assert.is_nil(Logic.ParseBracketedPrefix("(Bob]: hi"))
        assert.is_nil(Logic.ParseBracketedPrefix("<Bob): hi"))
    end)

    it("rejects messages without a bracketed prefix", function()
        assert.is_nil(Logic.ParseBracketedPrefix("hello there"))
        assert.is_nil(Logic.ParseBracketedPrefix("(Bob) hi"))
        assert.is_nil(Logic.ParseBracketedPrefix("()"))
        assert.is_nil(Logic.ParseBracketedPrefix(nil))
    end)

    it("preserves leading whitespace", function()
        local parts = Logic.ParseBracketedPrefix("  (Bob): hi")
        assert.equal("  ", parts.pre)
    end)
end)

describe("ColorizeParsedPrefix", function()
    it("colors only the name and restores the original spacing", function()
        local parts = Logic.ParseBracketedPrefix("(Bob) : hello world")
        local colored = Logic.ColorizeParsedPrefix(parts, "|cffff0000")
        assert.equal("(|cffff0000Bob|r) : hello world", colored)
    end)

    it("round-trips to the original message with an empty color", function()
        local msg = "  [Bob]:hi there"
        local parts = Logic.ParseBracketedPrefix(msg)
        assert.equal(msg, (Logic.ColorizeParsedPrefix(parts, ""):gsub("|r", "")))
    end)
end)

describe("ShouldAddPrefix", function()
    it("is false with no configured name", function()
        assert.is_false(Logic.ShouldAddPrefix({name = nil}, "Bob"))
        assert.is_false(Logic.ShouldAddPrefix({name = ""}, "Bob"))
    end)

    it("is true once a name is set and matching is not in the way", function()
        assert.is_true(Logic.ShouldAddPrefix({
            name = "Shadow",
            hideOnMatchingCharName = false
        }, "Bob"))
    end)

    it("hides when the name matches the character under the configured mode",
       function()
        assert.is_false(Logic.ShouldAddPrefix({
            name = "Bob",
            hideOnMatchingCharName = true,
            partialMatchMode = "disabled"
        }, "Bob"))
        assert.is_true(Logic.ShouldAddPrefix({
            name = "Bob",
            hideOnMatchingCharName = true,
            partialMatchMode = "disabled"
        }, "Bobbington"))
        assert.is_false(Logic.ShouldAddPrefix({
            name = "Bob",
            hideOnMatchingCharName = true,
            partialMatchMode = "start"
        }, "Bobbington"))
    end)
end)

describe("WantsPrefixFor", function()
    local function profile(overrides)
        local p = {
            guild = false,
            raid = false,
            party = false,
            instance_chat = false,
            lfr = false,
            world_chat = false,
            channel = nil
        }
        for k, v in pairs(overrides or {}) do p[k] = v end
        return p
    end

    it("gates GUILD and OFFICER on the guild option", function()
        assert.is_true(Logic.WantsPrefixFor(profile({guild = true}), "GUILD"))
        assert.is_true(
            Logic.WantsPrefixFor(profile({guild = true}), "OFFICER"))
        assert.is_false(Logic.WantsPrefixFor(profile(), "GUILD"))
    end)

    it("gates RAID on the raid option", function()
        assert.is_true(Logic.WantsPrefixFor(profile({raid = true}), "RAID"))
        assert.is_false(Logic.WantsPrefixFor(profile(), "RAID"))
    end)

    it("gates PARTY on the party option", function()
        assert.is_true(Logic.WantsPrefixFor(profile({party = true}), "PARTY"))
        assert.is_false(Logic.WantsPrefixFor(profile(), "PARTY"))
    end)

    describe("INSTANCE_CHAT", function()
        it("is on whenever the instance option is enabled", function()
            assert.is_true(Logic.WantsPrefixFor(
                               profile({instance_chat = true}), "INSTANCE_CHAT",
                               {isInLFR = false}))
        end)

        it("falls back to lfr + isInLFR when instance is off", function()
            assert.is_true(Logic.WantsPrefixFor(profile({lfr = true}),
                                                "INSTANCE_CHAT",
                                                {isInLFR = true}))
            assert.is_false(Logic.WantsPrefixFor(profile({lfr = true}),
                                                 "INSTANCE_CHAT",
                                                 {isInLFR = false}))
            assert.is_false(
                Logic.WantsPrefixFor(profile(), "INSTANCE_CHAT",
                                     {isInLFR = true}))
        end)
    end)

    describe("CHANNEL", function()
        it("is on for every channel when world_chat is enabled", function()
            assert.is_true(Logic.WantsPrefixFor(profile({world_chat = true}),
                                                 "CHANNEL",
                                                 {channelName = "Trade"}))
        end)

        it("matches against the configured channel list otherwise", function()
            assert.is_true(Logic.WantsPrefixFor(
                               profile({channel = "Trade,General"}), "CHANNEL",
                               {channelName = "Trade"}))
            assert.is_false(Logic.WantsPrefixFor(
                                profile({channel = "Trade,General"}),
                                "CHANNEL", {channelName = "LookingFor"}))
        end)

        it("is off with no channel list and world_chat disabled", function()
            assert.is_false(
                Logic.WantsPrefixFor(profile(), "CHANNEL",
                                     {channelName = "Trade"}))
        end)
    end)

    it("never touches chat types the addon does not support", function()
        for _, chatType in ipairs({"WHISPER", "SAY", "YELL", "EMOTE"}) do
            assert.is_false(Logic.WantsPrefixFor(profile({
                guild = true,
                raid = true,
                party = true,
                instance_chat = true,
                world_chat = true
            }), chatType, {isInLFR = true, channelName = "Trade"}), chatType)
        end
    end)

    -- Regression (v1.7.0): the lfr branch had no chat-type guard, so an
    -- enabled LFR option prefixed whispers, /say, /yell and emotes while
    -- standing in an LFR raid.
    it("does not let lfr leak into unrelated chat types while in LFR",
       function()
        local p = profile({lfr = true})
        for _, chatType in ipairs({"WHISPER", "SAY", "YELL", "EMOTE"}) do
            assert.is_false(
                Logic.WantsPrefixFor(p, chatType, {isInLFR = true}), chatType)
        end
    end)

    -- Regression (v1.7.0): the channel list was iterated without stopping
    -- on the first match, so "Trade,Trade" produced a double prefix.
    it("matches a duplicated channel list entry only once", function()
        assert.is_true(Logic.WantsPrefixFor(profile({channel = "Trade,Trade"}),
                                            "CHANNEL", {channelName = "Trade"}))
    end)
end)

describe("ColorCode", function()
    it("formats 0-1 floats as a WoW color escape", function()
        assert.equal("|cff000000", Logic.ColorCode(0, 0, 0))
        assert.equal("|cffffffff", Logic.ColorCode(1, 1, 1))
        -- Rounds to nearest rather than truncating: 0.5 * 255 = 127.5 -> 0x80
        assert.equal("|cffff8000", Logic.ColorCode(1, 0.5, 0))
    end)
end)
