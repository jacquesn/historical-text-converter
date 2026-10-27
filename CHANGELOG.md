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
- TCP character table as data (`config/tcp_glyphs.yml`); the EEBO parser
  gives empty glyphs their TCP display form (HTC-0017).
- EEBO-TCP encoding reference (`03_EEBO_TCP_ENCODING.md`) and eight more
  TCP fixtures for Milestone 4.
- EEBO parser coverage of every element in a 2,300-text survey (HTC-0018):
  `group` volumes and embedded texts, verse, letters, lists, tables,
  figures, drama, inline quotations and citations, and block structures
  inside running text.
- Document elements `Line`, `Table`, `TableRow`, `TableCell`, `Figure`,
  `Speech`, `Span`, and `Subscript`.
- `artifact:` metadata on every non-authorial node, and
  `Parser#parse_with_report` with `ParseReport`.

- Semantic Document Model (`HistoricalTextConverter::Document`): `Book`,
  `Metadata`, `Node`, `Block`, `Inline`, `Section`, `Heading`, `Paragraph`,
  `Quotation`, `Poem`, `List`, `ListItem`, `Footnote`, `PageBreak`, `Text`,
  and `Emphasis`. Nodes are immutable and support traversal, text access,
  and copy-on-change with `with` and `rewrite` (HTC-0014).
- `DocumentError` for invalid document structure.

- Transformation framework (HTC-0019): `Transformations::Transformation`,
  `Context`, and `Pipeline`, with a fixed order and per-transformation
  settings under `transformations:` in configuration.
- Cleanup transformations: `RemoveArtifacts`, `RemoveEmptyBlocks`,
  `RepairBrokenWords`, `RemoveDividerCharacters`, `NormalizeWhitespace`.
- `Review::Change`, `Review::ChangeLog`, and `Review::Location`; every
  transformation records each change it makes.

### Changed

- Minimum Ruby version raised from 3.1 to 4.0.
- `transformations:` settings in configuration are mappings with
  `enabled:` (was `modernization: true`).
- A page break with `rendition="simple:additions"` is tagged
  `handwritten_additions: true`, not as an artifact (HTC-0019 T5).

### Fixed

- The EEBO parser no longer leaves indentation after a page break or
  note on its own line (HTC-0019 T6).

## [0.1.0] - 2026-10-21

### Added

- Project skeleton, Gemfile, Rakefile, and RuboCop configuration.
- `HistoricalTextConverter` namespace and version constant.
- Executable `bin/historical-text-converter` with `--help` and `--version`.
- YAML configuration loading with deep-merged overrides (`config/default.yml`).
- Error hierarchy: `Error`, `ConfigurationError`, `CLIError`.
- RSpec suite covering library loading, version, configuration, and CLI.
