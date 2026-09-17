# Gazetteer Field Kit

Companion addon for [The Forever Gazetteer](https://forevergazetteer.com).  
Logs loot, quests, and targets locally so we can build the Forever database.

**Free.** No ads, no donation popups, no in-game telemetry, no network calls.

## Install

1. Download the repo (or a release zip).
2. Copy the files into:

`World of Warcraft/_classic_beta_/Interface/AddOns/GazetteerFieldKit/`

The folder name must be `GazetteerFieldKit`. Forever beta uses the `_classic_beta_` product folder (not `_forever_`).

3. Restart the client and enable the addon. `## Interface` is **16001** (client `1.60.1`, build `69893`, recorded 2026-09-17). If a later patch marks it out of date, enable **Load out of date AddOns** until we bump TOC.

## Commands

| Command | What it does |
|---|---|
| `/gfk` | Toggle the last-20 events window |
| `/gfk build` | Print version, build, date, and Interface (copies to clipboard if the client allows) |
| `/gfk export` | Print how many events are stored |
| `/gfk clear` | Clear this session's list (saved log remains) |

Data lives in SavedVariables after logout:

`WTF/Account/<account>/SavedVariables/GazetteerFieldKit.lua`

Upload is on the website later. Do not paste that file into public Discord if you care about character names.

## Policy

Visible source. No premium features in the addon. Report issues to hello@forevergazetteer.com.