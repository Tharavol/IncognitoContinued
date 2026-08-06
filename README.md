
# Incognito Continued
#### Incognito adds your specified name in front of your chat messages. Incognito Continued can be enabled for guild (and officer), party and raid chat messages.

Supports modern (Retail) World of Warcraft only. Classic and other legacy versions are not supported.
The addon ships in US English only.

> **Upgrading from IncognitoResurrected?** As of v1.8.0 the packaged folder is
> `Incognito` instead of `IncognitoResurrected`. WoW keys saved settings to the
> folder name, so your configuration does not carry over automatically. Note
> your name, enabled channels, custom channel list, bracket style,
> partial-match mode and ignored leading symbols before updating, then
> re-enter them once with `/inc`. Delete the old `IncognitoResurrected` folder
> once you've moved over. (This note goes away a few releases after v1.8.0.)

## Example
<pre><code>[Guild] [Yourchar]: Some chat message </code></pre>
becomes  
<pre><code>[Guild] [Yourchar]: (Yourname): Some chat message</code></pre>

## Usage

**Open the config with the addon compartment button next to the minimap, or with
the slash commands `/inc`, `/incognito` or `/incognitoresurrected`.**

- `/inc` - Open the configuration dialog
- `/inc config` - Open the configuration dialog
- `/inc enable` - Enable or disable adding your name to chat messages
- `/inc name <name>` - The name that should be displayed in your chat messages
- `/inc debug` - Toggle debug output
- `/inc help` - List the available commands

## AddOn Options

### General Settings
- **Name** - The name that should be displayed in your chat messages
- **Enable** - Enable adding your name to chat messages
- **Hide name if it matches your character's name** - Skip the prefix when it would just repeat your character name
- **Partial match** - Extend the above to match at the start of, anywhere in, or at the end of your character name
- **Color name by class** - Draw the bracketed name in the sender's class color. This is display-only and does not change what you send
- **Ignore leading symbols** - Skip the prefix for messages starting with any of these characters (after any spaces)
- **Bracket style** - Wrap your name in `(round)`, `[square]`, `{curly}` or `<angle>` brackets

### Options
- **Guild** - Add name to guild and officer chat messages
- **Party** - Add name to party chat messages
- **Raid** - Add name to raid chat messages
- **LFR** - Add name to LFR instance chat messages
- **Instance** - Add name to instance chat messages, e.g. LFR and battlegrounds
- **World** - Add name to world chat messages, e.g., General, Trade, LocalDefense and Services  
    (This is an all or none option, you cannot select which World Channel to enable/disable)
- **Channel** - Add name to chat messages in a custom channel  
    (Use comma-separation to add multiple channels)
- **Community** - Add name to chat messages in the Community channels
- **Debug** - Enable debugging messages output. You probably don't want to enable this

## Known Issues

- Chat messages are capped at 255 characters. If your name prefix would push a
  message past that limit, the message is sent without the prefix rather than
  being silently truncated, and the addon tells you so.
- The name prefix is not added while you are in combat. The client blocks any
  call routed through an addon-replaced protected function during combat, so the
  chat hooks are removed for the duration of each fight and reinstalled
  afterwards.

## Development

The addon is split into:

| File | Contents |
| --- | --- |
| [Logic.lua](Logic.lua) | Pure helpers with no WoW API dependency |
| [Core.lua](Core.lua) | Addon object, saved variables, chat hooks, combat handling |
| [Options.lua](Options.lua) | AceConfig option tables |
| [ChatFilter.lua](ChatFilter.lua) | Class-color rendering of the prefix in chat frames |
| [Locale_enUS.lua](Locale_enUS.lua) | All user-facing strings |

Everything in `Logic.lua` is covered by the [busted](https://lunarmodules.github.io/busted/)
suite in [Tests/](Tests/) and runs outside the game:

```sh
luarocks install luacheck
luarocks install busted
luacheck .
busted
```

Both run on every push and pull request via
[.github/workflows/ci.yml](.github/workflows/ci.yml). Pushing a `v*` tag builds
the release zip with the [BigWigs packager](https://github.com/BigWigsMods/packager).

## Features and Bugs
If you have a feature request or find a bug please report them through the Github repository:  
https://github.com/Tharavol/IncognitoResurrected/issues

## Credits
Original Author: Nyyr  
Resurrected Author: Starlynk  
Contributors: TheIceBadger, Hubbotu  

This repository is a fork of [Starlynk1/IncognitoResurrected](https://github.com/Starlynk1/IncognitoResurrected),
diverged at v1.4.6 to drop Classic/legacy WoW support and target Retail only. See
[Credits.md](Credits.md) and [CHANGELOG.md](CHANGELOG.md) for details on what has changed
since the fork point.
