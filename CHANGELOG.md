# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-10-21

### Added

- Project skeleton, Gemfile, Rakefile, and RuboCop configuration.
- `HistoricalTextConverter` namespace and version constant.
- Executable `bin/historical-text-converter` with `--help` and `--version`.
- YAML configuration loading with deep-merged overrides (`config/default.yml`).
- Error hierarchy: `Error`, `ConfigurationError`, `CLIError`.
- RSpec suite covering library loading, version, configuration, and CLI.
