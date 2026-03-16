# Quick start: building parsers and parsing files

Set up this repository on Windows, compile Kaitai parsers, and run your first parse/test workflow.

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

## 2. Configure paths

Edit `conf.txt` in repository root:

```txt
PZ_ROOT=D:\SteamLibrary\steamapps\common\ProjectZomboid
PZ_SAVE_ROOT=%UserProfile%\zomboid\Saves
MOD_ROOT=D:\SteamLibrary\steamapps\workshop\content\108600
```

Meaning:

- `PZ_ROOT`: Project Zomboid install path
- `PZ_SAVE_ROOT`: save root (contains mode folders like `Apocalypse`, `Sandbox`, etc.)
- `MOD_ROOT`: workshop mods root (used by save games with mods)

## 3. Build Kaitai parsers

From `data_spec/`:

Build latest numeric version:

```bat
build.bat
```

Build one version:

```bat
build.bat 244
```

Build one schema file:

```bat
build.bat spec\244\chunk.ksy
```

Build to a custom output folder:

```bat
build.bat 244 -o ..\output\custom_spec
```

By default, generated Python parser modules are written to `output/spec`.

## 4. Parse files

From `data_spec/scripts/`:

```bat
python parse.py <schema_name> <file1> [file2 ...] -o <output_txt>
```

Examples:

```bat
python parse.py chunk "<save_folder>\map\10\20.bin" -o "D:\tmp\chunk_10_20.txt"
python parse.py world_dictionary "<save_folder>\WorldDictionary.bin" -nv -o "D:\tmp\world_dictionary.txt"
python parse.py chunk "<save_folder>\10.bin" --params 244 -o "D:\tmp\chunk_with_params.txt"
```

Useful options:

- `-l, --lib-path`: parser library path (default: `output/spec`)
- `--params`: root args (comma-separated numbers/strings)
- `-d, --dump-field`: dump one binary field
- `-do, --dump-output`: path for dumped bytes
- `-nv, --no-verbose`: less console output

## 5. Parse SQLite blob fields

From `data_spec/scripts/`:

```bat
python parse_db.py <schema_name> <db_file> <table> -d <data_field> -a <arg_fields> -o <output_txt>
```

Example:

```bat
python parse_db.py base_vehicle "<save_folder>\vehicles.db" vehicles -d data -a worldversion -o "D:\tmp\vehicles.txt"
```

## 6. Run validation batches

From `data_spec/`:

Single save folder:

```bat
test.bat "<save_folder>" c v wd m vis
```

All saves under `PZ_SAVE_ROOT` (plus optional static file checks):

```bat
test_all_save.bat t lh lp c v wd m vis
```

Flags:

- `t`: parse `.tiles`
- `lh`: parse `.lotheader`
- `lp`: parse `.lotpack`
- `c`: parse chunk files
- `v`: parse `vehicles.db`
- `wd`: parse `WorldDictionary.bin`
- `m`: parse `metadata.bin`
- `vis`: parse `map_visited.bin`

Outputs and logs are written under `output/parsed/`.

## 7. Build release artifacts

From repo root:

```bat
release.bat
```

Other targets:

```bat
release.bat latest
release.bat 244
release.bat clean
```

Artifacts:

- `output/release/pzdataspec-<world_version>.zip`
- `output/release/release_notes.md`

## Troubleshooting

- `ksc` not found:
  - Ensure Kaitai compiler is installed and available on `PATH`.
- `python` imports fail during parse:
  - Rebuild parsers from `data_spec/` with `build.bat`.
  - Or pass `-l` to `parse.py` if using a custom parser output path.
- Decompile script cannot find game files:
  - Verify `PZ_ROOT` in `conf.txt`.
- Batch tests cannot find save folders:
  - Verify `PZ_SAVE_ROOT` in `conf.txt`.