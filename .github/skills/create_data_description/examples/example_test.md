## Example test workflow scripts

Run all examples:

```bat
run_workflow.bat
```

Run one example:

```bat
run_workflow.bat 02_dynamic_abstract_dispatch
```

The workflow performs:
1. Compile/run source generators (`java` / `c#`) or execute Python generators to produce binary sample data.
2. Compile `.ksy` into a Python parser (`ksc -t python`).
3. Parse generated binary via unified parser `data_spec/scripts/parse.py` and write `parsed.txt` in each example output folder.

## Cleanup (best practice)

Recommended pattern:
- Keep example source inputs and reference outputs (`.ksy`, `*_analysis.md`, `*_type_index.md`) in git.
- Remove runtime/build artifacts after test runs (`*.class`, `bin/`, `obj/`, generated `*.bin`, `output/lib`, `parsed.txt`).

Quick cleanup commands:

```bat
clean_workflow.bat all
```

Modes:

```bat
clean_workflow.bat build
clean_workflow.bat generated
```

`examples/.gitignore` is configured to ignore these generated artifacts by default.
