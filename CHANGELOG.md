# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Parser interface (`HistoricalTextConverter::Parser`) and EEBO parser
  (`Parsers::EEBO::Parser`) for EEBO-TCP TEI XML (HTC-0015, HTC-0016).
  Preserves the transcription, including page breaks, margin notes,
  gaps, line-end word breaks, and abbreviations, and identifies their
  editorial character. XML is parsed strictly, without external entities
  or network access.
- `Superscript` and `NoteReference` inline Document elements.
- `ParseError`.

- Semantic Document Model (`HistoricalTextConverter::Document`): `Book`,
  `Metadata`, `Node`, `Block`, `Inline`, `Section`, `Heading`, `Paragraph`,
  `Quotation`, `Poem`, `List`, `ListItem`, `Footnote`, `PageBreak`, `Text`,
  and `Emphasis`. Nodes are immutable and support traversal, text access,
  and copy-on-change with `with` and `rewrite` (HTC-0014).
- `DocumentError` for invalid document structure.

## [0.1.0] - 2026-10-21

### Added

- Project skeleton, Gemfile, Rakefile, and RuboCop configuration.
- `HistoricalTextConverter` namespace and version constant.
- Executable `bin/historical-text-converter` with `--help` and `--version`.
- YAML configuration loading with deep-merged overrides (`config/default.yml`).
- Error hierarchy: `Error`, `ConfigurationError`, `CLIError`.
- RSpec suite covering library loading, version, configuration, and CLI.
