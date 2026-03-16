# pzdataspec

Parser tools and Kaitai Struct specifications for Project Zomboid save and game data.

This project aims to deliver a robust parser for Project Zomboid save files, enabling seamless integration with the [pzmap2dzi](https://github.com/cff29546/pzmap2dzi) project.

This project focuses on analyzing game logic and developing maintainable `.ksy` schemas that accurately model the game's data structures, including save files. AI-assisted source analysis and verification workflows help ensure the schemas remain current and reliable. The project also offers tools for downstream users to parse and inspect game data efficiently.

# Key features

- **AI-assisted semi-automatic schema development**: Use agent skills to derive data specifications from decompiled source code, with iterative verification against game data.
- **Version-aware parsing**: Maintain separate schemas for different game versions, modeling version gates and format changes explicitly.
- **Broad format coverage**: Focus on save data formats, including map cells, tile definitions, and lot packs, with potential to expand to other game data types.
- **Downstream parsing tools**: Provide scripts and compiled parsers for users to easily parse game data and integrate with projects like [pzmap2dzi](https://github.com/cff29546/pzmap2dzi).

# Documentation

- [Quick start: building parsers and parsing files](docs/quick_start_parsing.md): how to set up and use the repository for parsing Project Zomboid save files.
- [Quick start: creating/updating data descriptions](docs/quick_start_data_description.md): how to use the [create_data_description skill](.github/skills/create_data_description/skill.md) to derive `.ksy` specifications from decompiled game source.
- [Architecture overview](docs/arch.md): key paths, workflows, and conventions in the repository.