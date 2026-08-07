# Incognito Continued

## [v1.8.0](https://github.com/Tharavol/IncognitoContinued/tree/v1.8.0) (2026-08-06)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.7.4...v1.8.0) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

### Settings reset -- read before updating
The packaged addon folder changes from `IncognitoResurrected` to `Incognito` in this release. WoW keys saved settings to the folder name, so **your configuration does not carry over** and must be re-entered once via `/inc`. Note these six values before updating, then set them again afterward:
- Name
- Enabled channels (Guild, Party, Raid, LFR, Instance, World)
- Custom channel list
- Bracket style
- Partial-match mode
- Ignored leading symbols

If the old `IncognitoResurrected` folder is still installed when you update, the addon detects it, warns you in chat, and disables its own chat hooks so you get one name prefix instead of two while you sort it out. Delete that folder once you've moved your settings over.

### Changed
- Rename the project to Incognito Continued. The packaged folder is now `Incognito` instead of `IncognitoResurrected`
- Register the addon internally as `IncognitoContinued`, a name distinct from the packaged folder, so the AceAddon, AceLocale, AceConfig and AceDBOptions registries never contest the same shared namespace as Nyyr's original `Incognito` addon, which installs to the same folder name
- Guard the AceAddon registration so a name collision prints a readable chat message instead of crashing on load

## [v1.7.4](https://github.com/Tharavol/IncognitoContinued/tree/v1.7.4) (2026-08-06)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.7.3...v1.7.4) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

### Fixed
- Stop rendering the World Chat "all or none" caveat twice in the options panel: once as the toggle's tooltip and again as the inline description beneath it
- Fix the first-run hint being permanently suppressed for every character and profile on the account the first time any character that already had a name configured logged in, since the "shown" flag was global-scoped but the name is profile-scoped

### Internal
- Extract the chat-type decision logic (`WantsPrefixFor`/`ShouldAddPrefix`) out of Core.lua into pure, tested functions in Logic.lua, and add a table-driven busted suite over the chat-type matrix with explicit regressions for both v1.7.0 bugs
- Add a packager dry-run to CI so a broken `.pkgmeta`, a TOC/folder mismatch, or a bad `ignore` entry surfaces on every push instead of only when a release tag goes out
- Exclude `Libs/LibStub/tests` from the packaged zip

## [v1.7.3](https://github.com/Tharavol/IncognitoContinued/tree/v1.7.3) (2026-08-06)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.7.2...v1.7.3) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

### Fixed
- Fix the login banner and options panel version string doubling to `vv1.7.2`. The TOC version has carried its own leading `v` since v1.7.2's release-tag-derived versioning; the `"Loaded (v%s)."` locale string was adding a second one

## [v1.7.2](https://github.com/Tharavol/IncognitoContinued/tree/v1.7.2) (2026-08-01)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.7.1...v1.7.2) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

### Internal
- The version in the TOC now comes from the release tag rather than being maintained by hand, so it can no longer disagree with the release it was published under. Versions now carry a leading `v`.
- Bumped the CI action pins to current majors: `actions/checkout` v4 to v7, `leafo/gh-actions-lua` v10 to v13, and `leafo/gh-actions-luarocks` v4 to v6.

No functional changes.

## [v1.7.1](https://github.com/Tharavol/IncognitoContinued/tree/v1.7.1) (2026-08-01)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.7.0...v1.7.1) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

### Internal
- Add the missing license files for the vendored libraries under `Libs/`. Ace3 and CallbackHandler-1.0 are redistributed under the Ace3 Development Team's Limited BSD license, and LibStub is public domain; both terms now ship with the source and the packaged zip, which is what those licenses require of a redistribution. Added `Libs/README.md` mapping each vendored directory to its license, and noting that none of them fall under the addon's own GPLv3

## [v1.7.0](https://github.com/Tharavol/IncognitoContinued/tree/v1.7.0) (2026-07-26)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.6.1...v1.7.0) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

### Fixed
- Fix the LFR option adding your name to unrelated chat. The `lfr` branch had no chat-type guard, so with LFR enabled and Instance disabled, standing in an LFR raid prefixed whispers, /say, /yell and emotes as well. LFR now only affects `INSTANCE_CHAT`, which is what LFR chat actually is
- Fix a duplicated custom channel name producing a duplicated prefix. The comma-separated channel list was iterated without stopping on the first match, so `Trade,Trade` prefixed twice. Channel lookup also no longer runs once per list entry
- Stop clobbering AceEvent-3.0's `SendMessage`. AceHook defaults its handler to the hooked method's name, so the `C_Club.SendMessage` hook was defined as `IncognitoResurrected:SendMessage`, overwriting the message-bus method AceAddon had embedded. The hooks now use explicit handler names (`OnSendChatMessage`, `OnClubSendMessage`)
- Add `CHAT_MSG_COMMUNITIES_CHANNEL` to the class-color chat filter, so community messages are colored like every other channel the addon supports
- Never let the name prefix silently truncate a message. Chat is capped at 255 characters; if the prefix would push a message past the cap it is now sent unprefixed with a notice, instead of losing the tail
- Fix the incoming-prefix pattern accepting a stray `)` inside the name

### Changed
- Remove the addon's override of the global `InterfaceOptionsFrame_OpenToCategory`. It was unused dead code, its parameter shadowed the addon's own global, and because Blizzard removed the function from modern Retail the override silently intercepted calls made by *other* addons
- Make `IsInLFR` a local instead of a global
- Register slash commands through AceConsole instead of writing `SLASH_*` and `SlashCmdList` by hand, so `/inc` no longer clobbers another addon that claims the same command
- Derive hook state from `IsHooked` rather than a private flag, so the combat unhook/rehook cycle stays correct if anything else calls `UnhookAll`
- Debug output now takes a format string and its arguments, so no message strings are built while debug mode is off
- Print a one-time hint pointing at `/inc` when no name has been configured yet, rather than starting up silently
- Ship US English only; the deDE, esES and ruRU locales have been removed. deDE was already missing the `bracketStyle` and `ignoreLeadingSymbols` strings
- Move every remaining hard-coded English string into the locale file, including the "Color name by class" option and the option group headers
- Add `IconTexture`, `Category-enUS`, `X-License`, `X-Website` and `AddonCompartmentFunc` to the .toc; the addon now has a minimap compartment button that opens the config

### Internal
- Split the 680-line `IncognitoResurrected.lua` into `Logic.lua` (pure helpers), `Core.lua` (addon object, hooks, combat), `Options.lua` (AceConfig tables) and `ChatFilter.lua` (class-color rendering)
- Deduplicate the name-matching logic that was written out twice, once in each of the two send paths
- Hoist the bracket-style table to file scope and stop shadowing the `pairs` builtin with it
- Add a busted suite under `Tests/` covering everything in `Logic.lua`, and a GitHub Actions workflow running luacheck and busted on every push and pull request
- Add `.pkgmeta` and a release workflow so tagging `v*` builds the release zip with the BigWigs packager

## [v1.6.1](https://github.com/Tharavol/IncognitoContinued/tree/v1.6.1) (2026-07-26)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.5.1...v1.6.1) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

- Explicitly document this repository as a fork of [Starlynk1/IncognitoResurrected](https://github.com/Starlynk1/IncognitoResurrected), diverged at v1.4.6, in README.md and Credits.md  
- Remove upstream's `X-Curse-Project-ID` from the .toc; this fork is not published under their CurseForge listing  
- Bump version to 1.6.x to end reuse of version numbers already used by upstream for different code. Upstream independently reused v1.4.7/v1.5.0/v1.5.1 for unrelated changes after our v1.4.6 fork point (and is at 1.5.2 on their develop branch as of this writing), so those version strings now mean different things in each repository. Future versions here will stay numerically ahead of upstream's to avoid further collisions  
- Evaluated upstream's `ChatCompat`-based EditBox-hook rewrite (their fix attempt for the same PvP `ADDON_ACTION_FORBIDDEN` bug class we fixed in v1.5.1) and declined to adopt it: their approach still has to force-disable the raid/battleground/arena/dungeon toggles on modern Retail (interface >= 11.0.0, i.e. every version we ship) because `EditBox:SetText()` still taints in those combat-instance contexts. Our existing fix (fully unhooking `C_ChatInfo.SendChatMessage` for the duration of combat via PLAYER_REGEN_DISABLED/ENABLED) already avoids the taint without disabling any feature, so it stays  

## [v1.5.1](https://github.com/Tharavol/IncognitoContinued/tree/v1.5.1) (2026-07-21)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.5.0...v1.5.1) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

- Fix "ADDON_ACTION_BLOCKED" error still occurring when sending chat in combat  
    The v1.4.7 fix skipped prefixing in combat but still called through the hook body, which was not enough: the client blocks any call routed through an addon-replaced protected function while in combat, regardless of what that function does. Now the SendChatMessage/SendMessage hooks are fully unhooked on PLAYER_REGEN_DISABLED and reinstalled on PLAYER_REGEN_ENABLED, so the protected functions are untouched by the addon for the duration of combat  
- Sync .toc Version to 1.5.1  

## [v1.5.0](https://github.com/Tharavol/IncognitoContinued/tree/v1.5.0) (2026-07-20)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.4.7...v1.5.0) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

- Drop support for Classic/Classic Era/other legacy WoW versions; addon now targets modern (Retail) WoW only  
    Removed ClassicAPI.lua and the Classic/Retail API-detection branching; RetailAPI.lua's hooks merged directly into IncognitoResurrected.lua  
    Removed the LFR/Community option visibility gating that only existed to hide those features on Classic  
- Trim .toc Interface line to Retail-only versions  
- Sync .toc Version to 1.5.0  

## [v1.4.7](https://github.com/Tharavol/IncognitoContinued/tree/v1.4.7) (2026-07-20)
[Full Changelog](https://github.com/Tharavol/IncognitoContinued/compare/v1.4.6...v1.4.7) [Previous Releases](https://github.com/Tharavol/IncognitoContinued/releases)

- Fix "ADDON_ACTION_BLOCKED" error sending chat while in combat/instanced content  
    Skip name-prefixing during InCombatLockdown() so the protected SendChatMessage/SendMessage call is never tainted  
- Sync .toc Version to 1.4.7  

## [v1.4.6](https://github.com/Starlynk1/IncognitoResurrected/tree/v1.4.6) (2026-01-25)
[Full Changelog](https://github.com/Starlynk1/IncognitoResurrected/compare/v1.4.5...v1.4.6) [Previous Releases](https://github.com/Starlynk1/IncognitoResurrected/releases)

- Merge pull request #50 from Starlynk1/bugfix/slash-command-errors  
    Fix for slash commands, return before SendChatMessage  
- Fix for slash commands, return before SendChatMessage  
- Sync .toc Version to 1.4.6 and add Tharavol and Claude to the Author list  
