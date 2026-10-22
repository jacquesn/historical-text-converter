# Milestone 3 — Parser Interface and EEBO Parser Foundation

## Repository

`https://github.com/jacquesn/historical-text-converter`

Follow `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md`.

## Governing Documents

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md          (especially HTC-0014, HTC-0015)
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md           (§14–16, §21–22, §47, §59, §63–65)
02_DEVELOPMENT_ROADMAP.md    (§6)
```

## Objective

Define the parser interface and build an EEBO parser that turns an
EEBO-TCP TEI XML file into a `Book`, preserving the source text and
identifying, but not resolving, its editorial features.

## Current Scope

* the parser interface;
* an EEBO parser covering every TEI element that occurs in
  `spec/fixtures/eebo/A13556.xml`;
* the Document Model additions listed under Proposed Decisions.

TEI elements that A13556 does not use (verse, lists, letters, tables,
figures) belong to Milestone 4.

## Source Survey (A13556)

`<text>` contains `<front>` (`div type="title_page"`, `div type="preface"`)
and `<body>` (12 `div type="chapter" n="…"`, which contain 12
`div type="error"` and 8 `div type="objection"`). There is no `<back>`.

| TEI | Count | Notes |
|---|---|---|
| `p` | 328 | Paragraphs are whole; page breaks fall inside them. |
| `pb` | 284 | 242 inside `p` (13 of those inside `hi`), 42 between blocks. `n` = printed page number; absent when unnumbered. |
| `hi` | 1,202 | Italic; 3 have `rend="sup"`. |
| `g` | 1,831 | `char:EOLhyphen` (1,744, empty), `char:EOLunhyphen` (7, empty), `char:punc` (36, "▪"), `char:cmbAbbrStroke` (40, combining macron), `char:abque` (4, inside `expan/am`). |
| `note place="margin"` | 222 | All inside `p`, at their point in the text. |
| `gap` | 225 | `reason`: illegible (with `extent` "1 letter", "1 word", "1 span", …), foreign, duplicate (26, "1 page", between a `pb` and the next `pb`). Each has a `desc` holding TCP's display form ("•", "〈◊〉", "〈…〉", "〈 in non-Latin alphabet 〉"). |
| `head` | 33 | One per `div` except the title page. |
| `argument` | 32 | Chapter and sub-division summaries, containing `p`. |
| `q` + `bibl` | 1 | Title-page scripture quotation with its citation. |
| `trailer` | 1 | "FINIS." |
| `seg rend="decorInit"` | 2 | Decorated initial letter. |
| `expan`/`am`/`ex` | 4 | Abbreviation "{que}". |

Text nodes keep the printed line breaks as newlines. The file is also
pretty-printed, so newlines followed by indentation appear before and
between elements.

## Decisions (approved; recorded as HTC-0016)

1. **Notes.** Add an inline `NoteReference` node at the note's point in
   the text, carrying the note's identifier. Represent the note itself as
   a `Footnote` (no label; metadata `place: "margin"`, `id`) placed
   immediately after the paragraph or heading that contains the
   reference. (Originally "top-level block"; refined in HTC-0016.)
   Writers decide whether margin notes become footnotes, endnotes, or
   side notes. (`Footnote` is a block and cannot sit inside a paragraph,
   and TCP notes carry no printed mark to use as a label.)
2. **Superscript.** Add an inline `Superscript` node for `hi rend="sup"`
   (`y<sup>e</sup>`). The architecture already lists it as a future
   inline element (§12).
3. **Divisions.** Each `div` becomes a `Section` with `kind` from its
   `type` (`:title_page`, `:preface`, `:chapter`, `:error`, `:objection`)
   and `n` in metadata. `<front>`, `<body>`, `<back>` become the Book's
   front matter, body, and back matter. `head` becomes a `Heading` whose
   level is the division's nesting depth (chapter 1, error 2).
4. **Other blocks.** `argument` → `Section(kind: :argument)`;
   `q` → `Quotation`, with its `bibl` as a `Paragraph` tagged
   `role: :citation`; `trailer` → `Paragraph` tagged `role: :trailer`.
5. **Page breaks.** `pb` → `PageBreak(page: n)`, `page` nil when `n` is
   absent. Metadata keeps `facs` and marks `rendition="simple:additions"`.
   A duplicate-page `gap` is folded into the preceding `PageBreak` as
   `duplicate: true`.
6. **Glyphs.** `char:EOLhyphen` → "∣" and `char:EOLunhyphen` → "¦" in the
   text, as TCP's display renders them (HTC-0015; architecture §21–22).
   Other `g` elements contribute their own text ("▪", combining macron).
7. **Gaps.** An inline `gap` becomes a `Text` holding its `desc`, with
   metadata `gap: true`, `reason`, and `extent`. The parser never fills a
   gap.
8. **Abbreviations.** `expan` becomes a `Text` holding the expansion
   ("que") with metadata `expansion: true` and the abbreviation glyph
   (`char:abque`), so a later transformation can choose how to present
   it.
9. **Decorated initials.** `seg rend="decorInit"` becomes plain `Text`;
   "WHat" stays as printed.
10. **Whitespace.** The parser removes only whitespace that comes from
    XML formatting: leading and trailing whitespace inside each block,
    and indentation after a newline. Printed line breaks stay as "\n".
    (Refined in HTC-0016: also the newline after a `pb` or `note` that
    TCP keys on its own line.)
    All other whitespace handling belongs to the Milestone 5
    transformation.
11. **Unrecognized elements.** Keep their text (as `Text` inline, or a
    `Paragraph` at block level) tagged `unrecognized: "<element name>"`.
    Never drop text silently.
12. **Metadata.** From `<teiHeader>`: `title`, `author`, publication
    `publisher`, `pub_place`, `date` (from `sourceDesc`), `idno` values
    (`DLPS`, `STC`, …), and the availability statement.

## Required Files

```text
lib/historical_text_converter/parsers/parser.rb        interface
lib/historical_text_converter/parsers/eebo/parser.rb   entry point; safe XML loading
lib/historical_text_converter/parsers/eebo/header_reader.rb   teiHeader → Metadata
lib/historical_text_converter/parsers/eebo/block_builder.rb   div, head, p, argument, q, trailer, notes
lib/historical_text_converter/parsers/eebo/inline_builder.rb  text, hi, g, gap, pb, expan, seg, note references
lib/historical_text_converter/document/note_reference.rb
lib/historical_text_converter/document/superscript.rb
lib/historical_text_converter/errors.rb                 add ParseError
spec/support/tei_helper.rb                              wraps TEI snippets cut from A13556
spec/historical_text_converter/parsers/...              specs mirroring lib/
```

These replace the roadmap's HTML-era `extractor`, `structure_detector`,
and `artifact_detector` (HTC-0015).

## Implementation Requirements

* `Parser#parse(path)` returns a `Book`; `parse_string(string)` does the
  same for an XML string, for small fixtures.
* XML is loaded strictly, with network access and external entity
  loading disabled. Malformed XML raises `ParseError`; it is never
  silently repaired.
* The parser does not modernize, Americanize, correct, fill gaps, remove
  `∣`, or expand abbreviations into the running text.
* Nokogiri objects never reach the Document Model.

## Tests

* Small fixtures for: title page, heading levels, paragraph with page
  break, page break inside italics, margin note, superscript, each gap
  type, duplicate page, line-end hyphens, argument, quotation with
  citation, trailer, abbreviation, decorated initial, unrecognized
  element, malformed XML, external entity (not resolved).
* Acceptance test on the full `A13556.xml`.

## Acceptance Criteria

* `A13556.xml` parses into a `Book` with 2 front-matter sections and 12
  chapters.
* Counts survive parsing: 328 paragraphs, 284 page breaks, 222 notes
  with 222 references, 225 gaps (26 as duplicate pages).
* All words of the source text are present: the Book's text, with `∣`
  and `¦` included, matches the TEI `<text>` text after the same
  whitespace rule (decision 10), apart from text the decisions move
  (notes) or fold (duplicate-page `desc`).
* `bundle exec rspec` and `bundle exec rubocop` pass.

## Out of Scope

* TEI structures not in A13556 (Milestone 4);
* any transformation, including `∣` removal and whitespace cleanup;
* EarlyPrint data (a later aid, HTC-0015);
* HTML input;
* CLI integration.

## Final Report

As in protocol §21.
