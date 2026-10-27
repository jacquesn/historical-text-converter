# Milestone 4 — TEI Coverage and Source Artifacts

## Repository

`https://github.com/jacquesn/historical-text-converter`

Follow `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md`.

## Governing Documents

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md          (HTC-0014 to HTC-0017)
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md           (§11–16, §44, §63–65)
02_DEVELOPMENT_ROADMAP.md    (§7)
03_EEBO_TCP_ENCODING.md      (element inventory; TCP documentation)
```

## Objective

Make the EEBO parser handle every element that occurs in EEBO-TCP TEI P5
files, not only those in A13556, and identify consistently everything in
the encoding that is not the author's text.

## Evidence

From `03_EEBO_TCP_ENCODING.md`, a survey of 2,300 random Phase I texts:

* 53 elements occur under `/TEI/text`; the Milestone 3 parser handles 20.
* In a 300-text run of the current parser: 13 texts fail (`group`
  volumes have no top-level `body`); in 143 more, unrecognized elements
  are flattened, so verse lines, list items, and letter parts run
  together. No characters are lost in any text.
* Block structures inside running text are common: figures in 373 texts,
  lists in 283, tables in 173, block quotations inside paragraphs 4,465
  times.

## Fixtures

Added (CC0), chosen to cover the missing structures:

| ID | Covers |
|---|---|
| A54309 | letter parts, list, figure, back matter |
| A95820 | table, `floatingText`, `abbr`, letter parts |
| A10388 | verse, epigraph, `bibl`, back matter |
| A32628 | byline, `lb`, figure and `figDesc`, dateline |
| A45601 | postscript, verse lines, Latin |
| B03159 | stanzas, figure, `unclear` |
| A19568 | `group` volume (fails today), list, milestone, epigraph |
| A59445 | drama: `sp`, `speaker`, `stage`; verse; lists |

## Decisions (approved; recorded as HTC-0018)

**D1. Volumes and embedded texts.** In a `group` volume, the outer `front`
and `back` become the Book's front and back matter. Each inner `text`
becomes a `Section(kind: :text)` in the body, containing
`Section(kind: :front_matter | :body | :back_matter)` for its own parts.
`floatingText` (a letter or document set inside the text) becomes a
`Section` with `kind` from its `type` (default `:floating_text`), built
the same way.

**D2. Verse.** Add a block element `Line` holding a verse line's inline
content (`n` in metadata). `lg` becomes a `Poem` (with its `type`); a
`Poem` contains `Line`s, nested `Poem`s (stanzas), headings, and page
breaks. A `Line` outside `lg` is allowed wherever blocks are. This
replaces the provisional one-block-per-line `Poem` of HTC-0014.

**D3. Letters and document parts.** `opener`, `closer`, `epigraph`, and
`postscript` become `Section`s of those kinds. `salute`, `signed`,
`dateline`, and `byline` become `Paragraph`s tagged with that `role`.
Loose text directly inside an `opener` or `closer` becomes a
`Paragraph`.

**D4. Lists.** `list` → `List` (with its `type`); `item` → `ListItem`,
whose inline content is wrapped in a `Paragraph`. A `label` becomes a
`Paragraph(role: :label)` at the start of the `ListItem` it precedes. A
list's `head` becomes a `Heading` just before the `List`.

**D5. Tables.** Add block elements `Table`, `TableRow`, and `TableCell`.
A cell holds blocks (inline content wrapped in a `Paragraph`), with
`role`, `rows`, and `cols` in metadata. A table's `head` becomes a
`Heading` just before the `Table`.

**D6. Figures.** Add a block element `Figure`. Its `figDesc` (the
transcribers' description of the image) becomes a
`Paragraph(role: :description)` marked as an artifact (D11); any `head`,
`p`, `byline`, or `trailer` printed with the image are kept as usual.

**D7. Inline wrappers.** Add one inline container, `Span`, tagged with a
`role`, for inline elements that mark meaning rather than formatting:
`q` → `:quotation`, `bibl` → `:citation`, `date` → `:date`, `stage` →
`:stage_direction`, `label` → `:label`, `ref` → `:reference` (`target`),
`ptr` → an empty `:pointer`, `unclear` → `:unclear` (`reason`), `add` →
`:addition`, a lone `abbr` → `:abbreviation`. `choice` (`abbr` +
`expan`) follows HTC-0016 decision 8: the expansion's text, tagged
`expansion` and the abbreviation as printed. `hi rend="sub"` becomes a
new inline `Subscript` (architecture §12); other `hi` renditions stay
`Emphasis` with `rend`.

**D8. Drama.** Add a block element `Speech`: the `speaker` becomes its
first child, a `Paragraph(role: :speaker)`, followed by the speech's
blocks. `stage` between blocks becomes a
`Paragraph(role: :stage_direction)`.

**D9. Blocks inside running text.** When a block structure (figure,
table, list, verse, a `q` holding blocks, `floatingText`, speech) occurs
inside a paragraph, heading, line, list item, or cell, the container is
split around it: the text before, the block, then the text after in a
copy of the container tagged `continued: true`. Empty pieces are
dropped. Order is preserved, nothing is moved, and a writer can rejoin
continued pieces. (A `q` with only inline content becomes a `Span`, D7.)

**D10. Markers.** `lb` (a line break the transcribers marked) becomes a
newline in the text, like the printed line breaks already kept.
`milestone` becomes an empty `Span(role: :milestone)` with its `unit` and
`n`; between blocks, an empty `Paragraph` with the same tags.

**D11. Artifacts.** Every node that is not the author's text carries
`artifact:` in its metadata, alongside the specific tags already
recorded: `:gap` (illegible, foreign, music, math, …), `:duplicate_page`,
`:transcriber_addition` (page images marked `simple:additions`),
`:description` (`figDesc`), `:expansion`, `:glyph` (display form taken
from the TCP table), `:milestone`. Transformations select artifacts by
this one key.

**D12. Parse report.** Add `EEBO::Parser#parse_with_report`, returning the
Book and a report listing, with their paths: unrecognized elements,
glyphs missing from the TCP table, and elements from §4 of the encoding
reference. `parse` is unchanged. Unrecognized material is still kept in
the Book as before.

**D13. Documented but unobserved elements.** Handle deliberately, and
report (D12): `ab` → `Paragraph`; `fw` (running heads, catchwords) →
`Paragraph(role: :forme_work)`, an artifact; `headnote`, `tailnote` →
`Paragraph` with that role; `sic`/`corr` in `choice` → the printed text
(`sic`), tagged with the correction; `del` → `Span(role: :deletion)`;
`supplied` → `Span(role: :supplied)`, an artifact; `subst`, `above`,
`below` → their content, tagged. Language attributes (`lang`) are kept in
metadata wherever they occur.

## Required Files

```text
lib/historical_text_converter/document/{line,table,table_row,table_cell,figure,speech,span,subscript}.rb
lib/historical_text_converter/parsers/eebo/...    builders extended; report class
spec/...                                           per-decision unit specs; acceptance specs per fixture
03_EEBO_TCP_ENCODING.md                            "Milestone 4" column updated to the final handling
```

## Tests

* Unit specs per decision, using snippets cut from the fixtures.
* Each of the nine fixtures parses, contains no unrecognized elements,
  and keeps every word of the source (the A13556 check, generalized).
* Outside the suite: the parser runs over the 2,300-text sample with no
  errors, no unrecognized elements, and no character loss; the result is
  recorded in the final report.

## Acceptance Criteria

* All nine fixtures parse with every word preserved and no unrecognized
  elements.
* The 2,300-text sample parses with no errors and no character loss.
* Every artifact is identified by `artifact:`.
* `bundle exec rspec` and `bundle exec rubocop` pass.

## Out of Scope

* Any transformation (whitespace, `∣`, artifacts removal, modernization);
* deciding what writers do with continued pieces, figures, or artifacts;
* EarlyPrint data;
* HTML input.

## Stop Condition

Do not combine artifact identification with spelling modernization.

## Final Report

As in protocol §21.
