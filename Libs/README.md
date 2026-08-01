# Vendored libraries

These libraries are third-party code redistributed with Incognito Resurrected so
the repository can be cloned straight into `Interface/AddOns` and run. They are
**not** covered by the addon's GPLv3 [LICENSE](../LICENSE) — each keeps its own
terms, listed below.

| Path | Project | License |
| --- | --- | --- |
| `AceAddon-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceConfig-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceConsole-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceDB-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceDBOptions-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceEvent-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceGUI-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceHook-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `AceLocale-3.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `CallbackHandler-1.0/` | Ace3 | Limited BSD — [ACE3-LICENSE.txt](ACE3-LICENSE.txt) |
| `LibStub/` | LibStub | Public Domain — [LibStub/LICENSE.txt](LibStub/LICENSE.txt) |

Ace3 and CallbackHandler-1.0 are distributed as one project by the Ace3
Development Team, so a single license file covers them. LibStub ships inside the
same distribution but is separately placed in the public domain by its authors.

Upstream: <https://github.com/WoWUIDev/Ace3>

The `#@no-lib-strip@` markers in
[IncognitoResurrected.toc](../IncognitoResurrected.toc) let the BigWigs packager
also produce a nolib build for users who obtain Ace3 elsewhere.
