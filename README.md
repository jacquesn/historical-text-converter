# Historical Text Converter

Historical Text Converter is a Ruby application for transforming historical
texts into clean, modern, readable editions while preserving their structure,
meaning, and scholarly integrity.

It begins with Early English Books Online (EEBO) sources and is designed to
support additional repositories and output formats in the future.

> The software modernizes presentation — not ideas.

## Status

**Version 0.1.0 — Milestone 1 (Project Foundation).**

The project skeleton, CLI, configuration loading, and test tooling are in
place. Historical-text conversion is not yet implemented. See
[`02_DEVELOPMENT_ROADMAP.md`](02_DEVELOPMENT_ROADMAP.md) for what comes next.

## Requirements

- Ruby 3.1 or later
- Bundler

## Installation

```bash
git clone https://github.com/jacquesn/historical-text-converter.git
cd historical-text-converter
bundle install
```

## Usage

```bash
bundle exec bin/historical-text-converter --help
bundle exec bin/historical-text-converter --version
```

## Configuration

Default settings live in [`config/default.yml`](config/default.yml). A custom
YAML file may override any subset of them; nested settings are deep-merged
over the defaults.

## Development

```bash
bundle exec rspec      # run the test suite
bundle exec rubocop    # check coding standards
bundle exec rake       # default task: run the test suite
```

## Project Documents

| Document | Purpose |
| --- | --- |
| [`00_PROJECT_CONSTITUTION.md`](00_PROJECT_CONSTITUTION.md) | Goals, non-goals, and project rules |
| [`00a_GLOSSARY.md`](00a_GLOSSARY.md) | Project terminology |
| [`00b_DECISION_LOG.md`](00b_DECISION_LOG.md) | Architectural decision history |
| [`00c_ARCHITECTURAL_PRINCIPLES.md`](00c_ARCHITECTURAL_PRINCIPLES.md) | How design decisions are evaluated |
| [`01_ARCHITECTURE.md`](01_ARCHITECTURE.md) | Technical architecture specification |
| [`02_DEVELOPMENT_ROADMAP.md`](02_DEVELOPMENT_ROADMAP.md) | Milestones and acceptance criteria |

## License

Released under the MIT License. See [`LICENSE`](LICENSE).
