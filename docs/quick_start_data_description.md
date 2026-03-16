# Quick start: creating/updating data descriptions

Use this guide when a Project Zomboid update changes save formats and existing `.ksy` specs no longer parse cleanly.

## Scenario

After a game update, one or more checks start failing (for example `chunk`, `metadata`, or `vehicles.db` parsing). Your goal is to:

1. Decompile the updated game build.
2. Locate serializer/deserializer changes.
3. Update or add `.ksy` schemas for the new world version.
4. Verify against real save data.

## 1. Prerequisites

Install:

- Windows 10+
- Python 3.10+
- Java 17+
- Kaitai Struct Compiler (`ksc`) on `PATH`
- `curl` on `PATH`

Install Python dependencies:

```bat
python -m pip install kaitaistruct pyyaml
```

## 2. Configure repository paths

Edit `conf.txt` at repository root:

```txt
PZ_ROOT=D:\SteamLibrary\steamapps\common\ProjectZomboid
PZ_SAVE_ROOT=%UserProfile%\zomboid\Saves
MOD_ROOT=D:\SteamLibrary\steamapps\workshop\content\108600
```

## 3. Decompile the updated game

From repository root:

```bat
scripts\decompile_game.bat
```

What this gives you:

- Decompiled source under `output/decompiled/<world_version>/`
- Updated world-version mapping in `data_spec/spec/version_mapping.yaml`

If the update is fresh, confirm a new numeric folder exists in `output/decompiled/`.

## 4. Generat save data for testing

Play the updated game and generate save data

- Starting a clean new game is recommended.
- A good save for testing should include a variety of game objects (for example dead zombies, dead animals, player-built structures, vehicles, etc.) to maximize code path coverage.
- Keep the visited map area reasonably small to limit the number of chunk files generated for testing efficiency.

## 5. Use the `create_data_description` skill workflow

This repo leverages the agent skill in github-copilot for the ai-assisted schema derivation and update workflow.
You can simply ask in agent mode to trigger the workflow.

```prompt
Create/update the data description for world version <version> based on the decompiled source.
Here is an save game generated with the updated game you can use for verification: <path_to_save_folder>.
```

When asking an agent to derive or update schema, make sure to provide:

- target world version (you'll get this from step 3)
- a fresh save game generated with the updated game for verification (step 4)

The agent will walk through the workflow to analyze the source code, create/update the `.ksy` spec, and verify against the provided save data. You can also check the [skill documentation](.github/skills/create_data_description/skill.md) for detailed workflow and tips.

In most cases, the agent should be able to complete the workflow with minimal guidance. However, if you notice the agent is stuck for long time or other unexpected behavior, you can check the agent logs and generated markdown analysis file for troubleshooting, and provide additional guidance to the agent if needed (Note: this may require expert knowledge including but not limited to reverse engineering, programming languages proficiency, LLM harnessing and/or familiarity with the game and organization of this repository).

## 6. Compile and run

Follow the instructions in [Quick start: building parsers and parsing files](docs/quick_start_parsing.md) to build the generated `.ksy` and run parsers against the save data for verification.