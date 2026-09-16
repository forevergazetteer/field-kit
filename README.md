# Gazetteer Field Kit

Companion addon for [The Forever Gazetteer](https://forevergazetteer.com).  
Logs loot, quests, and targets locally so we can build the Forever database.

**Free.** No ads, no donation popups, no in-game telemetry, no network calls.

## Install

1. Download the repo (or a release zip).
2. Copy the files into:

`World of Warcraft/_forever_/Interface/AddOns/GazetteerFieldKit/`

The folder name must be `GazetteerFieldKit`. If the Forever client uses a different product folder (`_classic_`, `_classic_era_`), use that `Interface/AddOns` path instead.

3. Restart the client. Enable the addon. If it is marked out of date, enable **Load out of date AddOns** until we set `## Interface` from `GetBuildInfo()`.

## Commands

| Command | What it does |
|---|---|
| `/gfk` | Toggle the last-20 events window |
| `/gfk export` | Print how many events are stored |
| `/gfk clear` | Clear this session's list (saved log remains) |

Data lives in SavedVariables after logout:

`WTF/Account/<account>/SavedVariables/GazetteerFieldKit.lua`

Upload is on the website later. Do not paste that file into public Discord if you care about character names.

## Policy

Visible source. No premium features in the addon. Report issues to hello@forevergazetteer.com.