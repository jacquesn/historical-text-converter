# Historical Text Converter — Claude Code context

Ruby CLI that turns historical texts (starting with EEBO HTML) into clean,
modernized editions while preserving structure, meaning, and historical grammar.

## Read first

The governing docs are authoritative; read them before non-trivial work:

- `00_PROJECT_CONSTITUTION.md` — goals, non-goals, hard rules
- `00b_DECISION_LOG.md` — architectural decisions (HTC-xxxx); record new ones here
- `00c_ARCHITECTURAL_PRINCIPLES.md`
- `01_ARCHITECTURE.md` — technical blueprint
- `02_DEVELOPMENT_ROADMAP.md` — milestones, acceptance criteria, stop conditions
- `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md` — how Claude sessions run
  (plan → approval → edit → run tests → report; human controls Git)
- `prompts/NN_MILESTONE_*.md` — per-milestone prompts

Key rules: Parser → Document Model → Transformations → Writer. No transformation
touches HTML. One responsibility per transformation. Every change is named and
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

## Current state (2026-10-21)

Milestone 1 (Project Foundation) — committed (`3335eec`).

Milestone 2 (Document Model) — implemented and verified (rspec: 100
examples; rubocop clean), **not yet committed**. Design is recorded in
HTC-0014: immutable nodes, no stored parent (use `each_with_ancestors`),
`Document` is a namespace, Book body/front/back matter are `Section`s.

Conventions:

- rubocop-rspec enforces one expectation per example and at most 5
  memoized helpers per group; examples that check an exit code together
  with a message use `:aggregate_failures`.
- Specs mirror `lib/` (`spec/historical_text_converter/...`) and wrap
  themselves in `module HistoricalTextConverter; module Document` so
  class names stay short.

Next steps:

1. Review and commit Milestone 2.
2. Then Milestone 3 — Parser Interface and EEBO Parser Foundation.

Open loose ends: `profile: conservative` in config has no profile definition yet;
`01_ARCHITECTURE.md` references a not-yet-written `05_MODERNIZATION_SPEC.md`;
`01_ARCHITECTURE.md` §4's tree shows `spec/document/` and `docs/`, but specs
mirror `lib/` and docs live at the repo root.
