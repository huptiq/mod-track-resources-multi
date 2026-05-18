# mod-track-resources-multi

An [AzerothCore](https://www.azerothcore.org/) module for WotLK (3.3.5a) that allows players to track multiple resources simultaneously.

## The Problem

In vanilla WotLK, activating any resource tracking ability (Track Herbs, Track Minerals, etc.) will cancel any other tracking that is currently active. This is enforced at the spell system level — all spells that apply `SPELL_AURA_TRACK_RESOURCES` are placed in the `SPELL_SPECIFIC_TRACKER` exclusivity group, which means they are mutually exclusive by design.

The underlying aura handler (`HandleAuraTrackResources`) already supports multiple simultaneous trackers. It works with independent bit flags on the `PLAYER_TRACK_RESOURCES` field, so there is nothing stopping multiple tracking auras from coexisting at the data layer. The restriction is purely a classification issue.

## The Fix

This module hooks into `OnLoadSpellCustomAttr`, which fires once per spell during server startup after spell specifics have been computed. For any spell that applies `SPELL_AURA_TRACK_RESOURCES`, the module overrides its `_spellSpecific` classification from `SPELL_SPECIFIC_TRACKER` to `SPELL_SPECIFIC_NORMAL`. This removes the mutual exclusivity constraint without touching any core files.

No database changes. No core patches. Drop in the module and rebuild.

## Requirements

- AzerothCore (recent enough to have the `OnLoadSpellCustomAttr` hook in `GlobalScript`)
- CMake build with modules support (`-DMODULES=static` or `-DMODULES=dynamic`)

## Installation

1. Clone or copy this folder into your `modules/` directory:

```
git clone https://github.com/huptiq/mod-track-resources-multi.git modules/mod-track-resources-multi
```

2. Re-run CMake and rebuild:

```
cmake ../ <your existing flags>
make -j$(nproc)
make install
```

No additional configuration is needed.

## How It Works

AzerothCore loads spell data at startup and calls `OnLoadSpellCustomAttr(SpellInfo* spell)` for every spell after `_spellSpecific` has been initialized. The module iterates over each spell's effects and, if it finds `SPELL_AURA_TRACK_RESOURCES`, sets `spell->_spellSpecific = SPELL_SPECIFIC_NORMAL`. From that point on, `IsAuraExclusiveBySpecificWith()` will no longer consider resource tracking spells mutually exclusive, and they can stack freely.

## License

MIT
