# Gazetteer Field Kit

Companion addon for [The Forever Gazetteer](https://forevergazetteer.com).  
Logs loot, quests, and targets locally so we can build the Forever database.

**Free.** No ads, no donation popups, no in-game telemetry, no network calls.

## Install

1. Download the repo (or a release zip).
2. Copy the files into:

`World of Warcraft/_classic_beta_/Interface/AddOns/GazetteerFieldKit/`

The folder name must be `GazetteerFieldKit`. Forever beta uses the `_classic_beta_` product folder (not `_forever_`).

3. Restart the client and enable the addon. `## Interface` is **16001**. Hotfix build numbers change often; they do not require a Field Kit update unless this Interface value changes. If a later patch marks the addon out of date, enable **Load out of date AddOns** until we bump TOC.

## Commands

| Command | What it does |
|---|---|
| `/gfk` | Toggle the last-20 events window |
| `/gfk build` | Print version, build, date, and Interface |
| `/gfk export` | Print how many events are stored |
| `/gfk clear` | Reset this login’s target dedup (saved log remains) |

`target` rows are creatures only. Player and pet units are skipped. The same spawn GUID is logged once per login; a new spawn of the same npc id is logged again. Map x/y is the **player** stand-point until a Forever NPC-position API exists.

Also logged: loot window slots (item id + source GUID, including `GameObject-` / `sourceObjectId` for nodes), gossip/quest greeting (quests on an NPC), instance enter/leave, quest title and NPC on accept/turn-in. Other players’ loot chat is ignored. Empty or duplicate loot windows are skipped.

Data lives in SavedVariables after logout:

`WTF/Account/<account>/SavedVariables/GazetteerFieldKit.lua`

Upload is on the website later. Do not paste that file into public Discord if you care about character names.

## Policy

Visible source. No premium features in the addon. Report issues to hello@forevergazetteer.com.