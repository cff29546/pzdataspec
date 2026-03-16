# create_data_description examples

This folder contains end-to-end examples for the `create_data_description` skill.

Each example folder includes:
- input source snippet(s) (`input/`) in Java, C#, or Python,
- generated-style Kaitai output (`output/*.ksy`),
- source analysis (`output/*_analysis.md`),
- type index (`output/*_type_index.md`),
- sub-task TODO/spec (`output/*_subtasks_todo.md`) when sub-tasks exist.

## Example list

- [Example 1: Variable Conditional Bitmap](examples/01_variable_conditional_bitmap)
   - Focus: Covers variable-length arrays, conditional logic, bitmap/flags.
   - Input: Java serializer snippet.
   - Output: `.ksy` + analysis + type index.
- [Example 2: Dynamic Abstract Dispatch](examples/02_dynamic_abstract_dispatch)
   - Focus: dynamic abstract/derived dispatch and correspondence table.
   - Input: C# abstract component serializer + id-to-type map.
   - Output: `.ksy` + analysis + type index.
- [Example 3: Substructure with Mock Verification](examples/03_substructure_with_mock_verification)
   - Focus: covered-length mock type for early macro verification.
   - Input: Java top-level block with unresolved child serializer.
   - Output: `.ksy` + analysis + type index + sub-tasks TODO.
- [Example 4: Version Gated Substructures](examples/04_version_gated_substructures)
   - Focus: sub-structures and version-gated fields.
   - Input: Java nested serializers with `worldVersion` checks.
   - Output: `.ksy` + analysis + type index.
- [Example 5: Polymorphic Dispatch Table](examples/05_polymorphic_dispatch_table)
   - Focus: polymorphic records with dynamic dispatch table.
   - Input: Java type-id factory/dispatch snippet.
   - Output: `.ksy` + analysis + type index + sub-tasks TODO.
- [Example 6: Loop Native KSY Expressions](examples/06_loop_native_ksy_expressions)
   - Focus: loop/reduction logic in native `.ksy` expressions.
   - Input: Python generator over byte arrays.
   - Output: `.ksy` + analysis + type index.
- [Example 7: Remaining Stream Conditional Typing](examples/07_remaining_stream_conditional_typing)
   - Focus: remaining-stream-length based conditional typing.
   - Input: Python generator with optional tail bytes.
   - Output: `.ksy` + analysis + type index.
- [Example 8: Custom Process Length Calculation](examples/08_custom_process_length_calc)
   - Focus: complex length calculation via target-language custom process.
   - Input: Python generator with derived length semantics.
   - Output: `.ksy` + analysis + type index + Python process helper.
   - Remark: custom process helpers should only be used as a last resort when length semantics cannot be expressed with native `.ksy` constructs, as they lock the spec to a specific target language. Always justify this choice to the developer and document the reasoning clearly.

## Notes

- These examples are intentionally compact and educational.
- Naming and style are aligned with this repository (`num_*`, `len_*`, world-version gates, `doc` fields).
- You can adapt these patterns directly when creating real specs under `data_spec/spec/<version>/`.
- See [Example test workflow](example_test.md) for how to run and verify these examples.
