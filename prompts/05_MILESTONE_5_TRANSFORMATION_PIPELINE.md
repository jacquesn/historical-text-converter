# Milestone 5 — Transformation Pipeline and Basic Cleanup

## Repository

`https://github.com/jacquesn/historical-text-converter`

Follow `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md`.

## Governing Documents

```text
00_PROJECT_CONSTITUTION.md       (§3–5, Configuration, Logging)
00b_DECISION_LOG.md              (HTC-0014 to HTC-0018)
00c_ARCHITECTURAL_PRINCIPLES.md  (Principles 5–16)
01_ARCHITECTURE.md               (§17–22, §30–31, §45)
02_DEVELOPMENT_ROADMAP.md        (§8)
03_EEBO_TCP_ENCODING.md
```

## Objective

Create the transformation framework and the first conservative cleanup
transformations, so a parsed Book can be turned into clean running text
while every change stays named, configurable, and reviewable.

## Evidence

From the parsed 300-text sample (2,300-text survey, `03_EEBO_TCP_ENCODING.md`):

| Pattern in parsed text | Count | Meaning |
|---|---:|---|
| `∣` inside a word (`shy∣neth`) | 161,927 | TCP keeps both halves of a line-end hyphenated word together; removing `∣` alone repairs it |
| `∣` then whitespace (`in∣⏎•…itable`) | 876 | A break that needs repair, mostly before a gap |
| `¦` inside a word / then whitespace | 1,337 / 14 | Same, for breaks without a printed hyphen |
| literal `-` then a newline (`Popish-⏎Plot`) | 6 | Real hyphens; must not be joined |
| newlines inside paragraphs | 238,386 | Printed line breaks |
| space before punctuation (`〉 ;`) | 182 | As transcribed, mostly beside gaps |
| runs of spaces after a page break | 2,026 | A parser bug (below) |

Page breaks with `rendition="simple:additions"`: 6,069 of 10,043 are the
only page break for their image. The TCP keying specification defines
the SGML original (`PB MS="Y"`): "Any page that contains handwritten
corrections, deletions, glosses, etc." They are real pages, not
artifacts.

## Decisions (approved; recorded as HTC-0019)

**T1. Interface.** `Transformation#apply(book, context)` returns a new
Book (nodes are immutable, HTC-0014). Each transformation has a stable
`name` (its class name, such as `RemoveDividerCharacters`) and is
idempotent: applying it twice gives the same Book as once.

**T2. Context and change records.** `Transformations::Context` carries the
configuration and a change log. Add a minimal `Review::Change`
(transformation, original, replacement, location, rule) and
`Review::ChangeLog` (`record`, `changes`, `count`, `by_transformation`) so
every change is recorded from the start; reports and statistics remain
Milestone 8. One Change is recorded per changed or removed node. A
location is the node's path of child positions from the Book root plus
the nearest preceding printed page number, so a reader can find it.

**T3. Pipeline.** `Transformations::Pipeline` owns the order, as a
constant in code (Principle 11). Configuration decides only which
transformations run and with what settings, under `transformations:` in
YAML; every transformation can be disabled there without code changes
(Constitution, Configuration).

**T4. Transformations and order.** The roadmap's conceptual order is
adjusted: word repair must run before divider removal, because `∣` is
the evidence of a broken word; and empty-block removal must follow
artifact removal, which creates the empty blocks.

1. **RemoveArtifacts** — removes nodes whose `artifact:` kind is listed
   in configuration. Default list: `duplicate_page`, `milestone`,
   `forme_work`. Kept by default, because each stands for text or marks
   uncertainty: `gap`, `expansion`, `glyph`, `supplied`, `description`.
2. **RemoveEmptyBlocks** (structural cleanup) — removes paragraphs,
   lines, and sections left with no content. The Book's three parts are
   never removed.
3. **RepairBrokenWords** (word-boundary repair) — removes the whitespace
   immediately after `∣` or `¦` when more text follows in the same block,
   looking past page breaks and note references (which stay in place).
   Never joins across blocks; never touches a literal `-`.
4. **RemoveDividerCharacters** (character cleanup) — deletes `∣` and `¦`.
   The characters are listed in configuration.
5. **NormalizeWhitespace** — within each block of running text, collapses
   every run of whitespace, including printed line breaks, to one space,
   across the boundaries of inline elements, and trims the block's edges.
   It does not add or remove space around punctuation.

**T5. Handwritten additions (corrects HTC-0018 D11).** A page break with
`rendition="simple:additions"` is a real page whose image has handwritten
annotations. The parser tags it `handwritten_additions: true` instead of
`artifact: :transcriber_addition`, so no transformation removes it.

**T6. Parser whitespace fix.** After a page break on its own line, the
parser removes the newline TCP adds but leaves the indentation that
followed it (2,026 cases of stray spaces). Clean indentation first, then
remove the newline (HTC-0016 decision 10).

**T7. Continued pieces.** Paragraph pieces split around blocks (HTC-0018
D9) are left as they are; how to present them is a writer decision.

## Required Files

```text
lib/historical_text_converter/transformations/{transformation,context,pipeline}.rb
lib/historical_text_converter/transformations/cleanup/{remove_artifacts,remove_empty_blocks,repair_broken_words,remove_divider_characters,normalize_whitespace}.rb
lib/historical_text_converter/review/{change,change_log}.rb
config/default.yml                 transformations: settings for each
spec/...                           per transformation; pipeline; review
```

## Tests

* Each transformation independently, including the roadmap's cases
  (`"the∣book"` → `"thebook"`), the legitimate characters it must not
  touch, and idempotence.
* Whitespace: repeated spaces, line breaks, paragraph boundaries,
  indentation, punctuation, and inline-element boundaries.
* The pipeline: order, enabling and disabling from configuration,
  determinism, and change recording.
* Acceptance on the fixtures: after the pipeline, no `∣`, `¦`, newline, or
  run of spaces remains in running text; no word is lost (the words equal
  the source words with line-end breaks joined); gaps are untouched.
* Outside the suite: the pipeline over the 2,300-text sample, recorded in
  the final report.

## Acceptance Criteria

* Transformations run independently and compose into a pipeline.
* Pipeline order is deterministic; the same input gives the same output.
* Every change is recorded with its transformation and location.
* `bundle exec rspec` and `bundle exec rubocop` pass.

## Out of Scope

* Spelling modernization, Americanization, printer-error correction;
* review reports and statistics (Milestone 8);
* CLI integration (Milestone 12);
* rejoining continued pieces or presenting artifacts (writers).

## Stop Condition

Do not implement spelling modernization yet.

## Final Report

As in protocol §21.
