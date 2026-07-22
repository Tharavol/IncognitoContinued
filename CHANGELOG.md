# Incognito Resurrected

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
