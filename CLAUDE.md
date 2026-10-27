# Historical Text Converter — Claude Code context

Ruby CLI that turns historical texts (starting with EEBO-TCP TEI XML) into clean,
modernized editions while preserving structure, meaning, and historical grammar.

## Read first

The governing docs are authoritative; read them before non-trivial work:

- `00_PROJECT_CONSTITUTION.md` — goals, non-goals, hard rules
- `00b_DECISION_LOG.md` — architectural decisions (HTC-xxxx); record new ones here
- `00c_ARCHITECTURAL_PRINCIPLES.md`
- `01_ARCHITECTURE.md` — technical blueprint
- `02_DEVELOPMENT_ROADMAP.md` — milestones, acceptance criteria, stop conditions
- `03_EEBO_TCP_ENCODING.md` — what EEBO-TCP P5 files contain; TCP docs; parser handling
- `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md` — how Claude sessions run
  (plan → approval → edit → run tests → report; human controls Git)
- `prompts/NN_MILESTONE_*.md` — per-milestone prompts

Key rules: Parser → Document Model → Transformations → Writer. No transformation
touches source markup. One responsibility per transformation. Every change is named and
reviewable. Rules/dictionaries live in YAML, not Ruby. Preserve historical grammar
(hath, doth, thou) by default. Never rewrite ideas or invent text.

## Working agreement

- Work one milestone at a time and respect each milestone's **Stop Condition**.
- Do not commit or push unless asked.
- Update docs alongside architectural changes (docs are code).

## Keeping this file current

Claude maintains this file. Update it, without being asked, before ending
any turn where one of these changed:

- **Current state**: milestone progress, completed next steps, new next
  steps, or loose ends opened or closed. Keep the date in the heading
  current, and drop items once they're done or recorded elsewhere.
- **Commands**: a new or changed way to build, test, lint, or run.
- **Rules or conventions**: anything a future session must know that
  isn't obvious from the code or the governing docs.

Keep it short: this file is a pointer and a status board. Architectural
decisions go in `00b_DECISION_LOG.md`, not here. Don't log per-session
history; replace stale state rather than appending to it.

## Commands

```bash
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec bin/historical-text-converter --help
```

## Current state (2026-10-26)

Milestone 1 (Project Foundation) — committed (`3335eec`).

Milestone 2 (Document Model) — committed (`17e6ed6`). Design is recorded in
HTC-0014: immutable nodes, no stored parent (use `each_with_ancestors`),
`Document` is a namespace, Book body/front/back matter are `Section`s.

Milestone 3 (EEBO Parser) — committed (`09863bc`). Input is EEBO-TCP TEI
XML, not HTML (HTC-0015); TEI→model mapping is HTC-0016. Fixture:
`spec/fixtures/eebo/A13556.xml` (Taylor, *Regula vitæ*, 1631; CC0). The
acceptance spec (`parser_parse_a13556_spec.rb`) checks counts and that
every source word survives parsing.

Conventions:

- rubocop-rspec enforces one expectation per example and at most 5
  memoized helpers per group; examples that check an exit code together
  with a message use `:aggregate_failures`.
- Specs mirror `lib/` (`spec/historical_text_converter/...`) and wrap
  themselves in `module HistoricalTextConverter; module ...` so class
  names stay short.
- Parser specs use `parse_tei(body_xml, front:, header:)` from
  `spec/support/tei_helper.rb` with snippets cut from real TCP texts.
- In specs, replace Nokogiri nodes with `Nokogiri::XML::Text` nodes, not
  strings: `replace("&c.")` parses the string as markup and drops it.

Next steps:

1. Milestone 4 — TEI Coverage and Source Artifacts: implemented and
   verified, **not yet committed**. HTC-0017 (glyph table) and HTC-0018
   (D1–D13). rspec 264 examples, rubocop clean. All 9 fixtures and the
   2,300-text sample parse with no errors, empty parse report, every
   word kept (`spec/support/source_words.rb`). Review and commit, then
   Milestone 5 — Transformation Pipeline and Basic Cleanup.

Ruby: the Gemfile requires Ruby >= 4.0, so 3.2+/4.0 APIs are fine.

TCP encoding documentation (SGML-era names; P5 files use TEI P5 names, and
no TCP P5 schema is published): keying spec
`textpartnership.net/docs/dox/instruct2.html`; production DTD (86
elements) `…/docs/code/eebo2prf.dtd.txt`; per-structure guides
`…/docs/oxdox/encoding/` and `…/oxdox/transcription/`; character table
(1,624 `char:` glyphs with display forms) `…/docs/code/TCP_chars.html`.
EarlyPrint's P5-derived RelaxNG schema:
`schemata.earlyprint.org/schemata/tei_earlyprint.rng`.

EarlyPrint XML (`bitbucket.org/eads004/<prefix>/raw/master/<ID>.xml`) is a
later aid, never an input: e.g. mining `@reg` for candidate M6 dictionary
entries (human-reviewed), abbreviation expansions, labelled gap
suggestions. See HTC-0015 and roadmap §9.

Prior art (surveyed 2026-10-22): no existing tool turns TCP TEI into a
structured, conservatively modernized, reviewable DOCX/RTF edition. Parts
exist and may be reused, licenses permitting: spelling data from VARD 2
(free for non-commercial use only), eMOP word list, MorphAdorner/EarlyPrint
`@reg` (for M6 dictionaries); TEI Stylesheets / TEI Garage and OTA EPUBs
for format conversion (evaluate before building writers, M10–11).
Recorded in roadmap §9 (M6), §12 (M9), §13–14 (M10–11).

Open loose ends: `profile: conservative` in config has no profile definition yet;
`01_ARCHITECTURE.md` references a not-yet-written `05_MODERNIZATION_SPEC.md`;
`01_ARCHITECTURE.md` §4's tree shows `spec/document/` and `docs/`, but specs
mirror `lib/` and docs live at the repo root; two A13556 paragraphs keep a
doubled line break from XML formatting (HTC-0016) for Milestone 5 to normalize;
TCP glyph table license unconfirmed (HTC-0017 note: CC0 `tcpchars.xml` covers
42 of 44 glyphs used).
