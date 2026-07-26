# Incognito Resurrected

## [v1.6.1](https://github.com/Tharavol/IncognitoResurrected/tree/v1.6.1) (2026-07-26)
[Full Changelog](https://github.com/Tharavol/IncognitoResurrected/compare/v1.5.1...v1.6.1) [Previous Releases](https://github.com/Tharavol/IncognitoResurrected/releases)

- Explicitly document this repository as a fork of [Starlynk1/IncognitoResurrected](https://github.com/Starlynk1/IncognitoResurrected), diverged at v1.4.6, in README.md and Credits.md  
- Remove upstream's `X-Curse-Project-ID` from the .toc; this fork is not published under their CurseForge listing  
- Bump version to 1.6.x to end reuse of version numbers already used by upstream for different code. Upstream independently reused v1.4.7/v1.5.0/v1.5.1 for unrelated changes after our v1.4.6 fork point (and is at 1.5.2 on their develop branch as of this writing), so those version strings now mean different things in each repository. Future versions here will stay numerically ahead of upstream's to avoid further collisions  
- Evaluated upstream's `ChatCompat`-based EditBox-hook rewrite (their fix attempt for the same PvP `ADDON_ACTION_FORBIDDEN` bug class we fixed in v1.5.1) and declined to adopt it: their approach still has to force-disable the raid/battleground/arena/dungeon toggles on modern Retail (interface >= 11.0.0, i.e. every version we ship) because `EditBox:SetText()` still taints in those combat-instance contexts. Our existing fix (fully unhooking `C_ChatInfo.SendChatMessage` for the duration of combat via PLAYER_REGEN_DISABLED/ENABLED) already avoids the taint without disabling any feature, so it stays  

## [v1.5.1](https://github.com/Tharavol/IncognitoResurrected/tree/v1.5.1) (2026-07-21)
[Full Changelog](https://github.com/Tharavol/IncognitoResurrected/compare/v1.5.0...v1.5.1) [Previous Releases](https://github.com/Tharavol/IncognitoResurrected/releases)

- Fix "ADDON_ACTION_BLOCKED" error still occurring when sending chat in combat  
    The v1.4.7 fix skipped prefixing in combat but still called through the hook body, which was not enough: the client blocks any call routed through an addon-replaced protected function while in combat, regardless of what that function does. Now the SendChatMessage/SendMessage hooks are fully unhooked on PLAYER_REGEN_DISABLED and reinstalled on PLAYER_REGEN_ENABLED, so the protected functions are untouched by the addon for the duration of combat  
- Sync .toc Version to 1.5.1  

## [v1.5.0](https://github.com/Tharavol/IncognitoResurrected/tree/v1.5.0) (2026-07-20)
[Full Changelog](https://github.com/Tharavol/IncognitoResurrected/compare/v1.4.7...v1.5.0) [Previous Releases](https://github.com/Tharavol/IncognitoResurrected/releases)

- Drop support for Classic/Classic Era/other legacy WoW versions; addon now targets modern (Retail) WoW only  
    Removed ClassicAPI.lua and the Classic/Retail API-detection branching; RetailAPI.lua's hooks merged directly into IncognitoResurrected.lua  
    Removed the LFR/Community option visibility gating that only existed to hide those features on Classic  
- Trim .toc Interface line to Retail-only versions  
- Sync .toc Version to 1.5.0  

## [v1.4.7](https://github.com/Tharavol/IncognitoResurrected/tree/v1.4.7) (2026-07-20)
[Full Changelog](https://github.com/Tharavol/IncognitoResurrected/compare/v1.4.6...v1.4.7) [Previous Releases](https://github.com/Tharavol/IncognitoResurrected/releases)

- Fix "ADDON_ACTION_BLOCKED" error sending chat while in combat/instanced content  
    Skip name-prefixing during InCombatLockdown() so the protected SendChatMessage/SendMessage call is never tainted  
- Sync .toc Version to 1.4.7  

## [v1.4.6](https://github.com/Starlynk1/IncognitoResurrected/tree/v1.4.6) (2026-01-25)
[Full Changelog](https://github.com/Starlynk1/IncognitoResurrected/compare/v1.4.5...v1.4.6) [Previous Releases](https://github.com/Starlynk1/IncognitoResurrected/releases)

- Merge pull request #50 from Starlynk1/bugfix/slash-command-errors  
    Fix for slash commands, return before SendChatMessage  
- Fix for slash commands, return before SendChatMessage  
- Sync .toc Version to 1.4.6 and add Tharavol and Claude to the Author list  
