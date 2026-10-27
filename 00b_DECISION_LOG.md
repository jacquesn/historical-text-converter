# Historical Text Converter
## Architectural Decision Log
Version: 1.0

---

# Purpose

This document records every significant architectural decision.

Each decision receives a unique identifier.

Decisions are never deleted.

If a decision changes, a new decision supersedes the previous one.

This provides a permanent architectural history.

---

# Decision Format

Decision ID

Date

Status

Decision

Reason

Consequences

Superseded By (optional)

---

## HTC-0001

Status:
Accepted

Decision:

Project name shall be Historical Text Converter.

Reason:

The software is intended to support multiple historical text sources,
not only EEBO.

Consequences:

Architecture shall remain parser-independent.

---

## HTC-0002

Status:
Accepted

Decision:

Primary implementation language shall be Ruby.

Reason:

Project maintainer is most experienced with Ruby.

Consequences:

Architecture and tooling shall prioritize Ruby conventions.

---

## HTC-0003

Status:
Accepted

Decision:

Project architecture shall follow a semantic Document Model.

Reason:

Transformations should operate on document meaning rather than HTML.

Consequences:

Parsers and writers remain independent.

---

## HTC-0004

Status:
Accepted

Decision:

Every transformation shall have exactly one responsibility.

Reason:

Single Responsibility Principle improves maintainability and testing.

Consequences:

Large transformations must be decomposed.

---

## HTC-0005

Status:
Accepted

Decision:

Historical grammar shall be preserved by default.

Reason:

Modernization should improve readability without changing authorial voice.

Consequences:

Words such as:

hath

doth

saith

thou

remain unchanged.

---

## HTC-0006

Status:
Accepted

Decision:

Spelling modernization shall be enabled by default.

Reason:

Readers benefit from improved readability.

Consequences:

Dictionary-based modernization engine required.

---

## HTC-0007

Status:
Accepted

Decision:

Americanization shall be an independent transformation.

Reason:

Not every user desires American spellings.

Consequences:

Americanization may be disabled independently.

---

## HTC-0008

Status:
Accepted

Decision:

Transformation dictionaries shall be external YAML files.

Reason:

Rules should be editable without modifying Ruby code.

Consequences:

Dictionary loader required.

---

## HTC-0009

Status:
Accepted

Decision:

Every transformation shall optionally generate review information.

Reason:

Users should understand every automated change.

Consequences:

Transformation logging subsystem required.

---

## HTC-0010

Status:
Accepted

Decision:

Project shall support multiple output writers.

Reason:

The transformation pipeline should be reusable.

Consequences:

Output generation shall depend only on the Document Model.

---

## HTC-0011

Status:
Accepted

Decision:

Configuration shall be YAML-based.

Reason:

Human-readable and version-controllable.

Consequences:

Configuration parser required.

---

## HTC-0012

Status:
Accepted

Decision:

The project shall be developed as though intended for open-source release.

Reason:

Encourages clean architecture, documentation, and testing.

Consequences:

Public APIs must be documented.

Automated tests are mandatory.

Coding standards shall be enforced.

---

## HTC-0013

Date:
2026-10-21

Status:
Accepted

Decision:

Development sessions shall use Claude through Claude Code instead of
ChatGPT. Claude may edit files in the working tree and run the
project's commands. The human developer controls Git: Claude does not
commit, push, or branch unless explicitly asked.

Reason:

Claude Code works directly in the repository, so it can apply changes
and run tests itself rather than handing complete files and commands
to the human developer. Keeping Git with the human developer keeps
every change reviewable before it is recorded.

Consequences:

`prompts/00_CHATGPT_DEVELOPMENT_PROTOCOL.md` is replaced by
`prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md`.

Claude reports test results it actually observed, rather than asking
the human developer to run and paste them.

`CLAUDE.md` carries current project state between sessions.

This decision concerns the development process only. The converter
itself does not call Claude or any other AI service.

---

## HTC-0014

Date:
2026-10-21

Status:
Accepted

Decision:

The Document Model shall have the following shape:

1. A `Book` holds `metadata`, `front_matter`, `body`, and `back_matter`,
   as described in `01_ARCHITECTURE.md` §9. Front and back matter default
   to empty sections.
2. `Document` is the namespace (`HistoricalTextConverter::Document`), not
   a class. The roadmap's `Document` container is the Book's `body`, a
   `Section`. Front matter, body, and back matter are all `Section`s,
   distinguished by `kind`.
3. Nodes are immutable. `with` returns a modified copy, and `rewrite`
   rebuilds a tree bottom-up, reusing unchanged subtrees.

Supporting choices:

- Because subtrees are shared between copies, nodes do not store a parent
  reference. `each_with_ancestors` reports each node's ancestors instead.
- A `Block` base class sits beside `Inline` so containers can state which
  kinds of children they accept. Constructors reject invalid children.
- `PageBreak` may appear between blocks and inside running text, because
  source page boundaries fall in both places.
- Every node's `metadata` is a `Metadata` object, including the Book's.

Reason:

The architecture's Book shape anticipates title pages, dedications, and
prefaces, which the EEBO parser will need. A class named
`Document::Document` would be confusing. Immutable nodes satisfy the
architecture's preference (§45), make transformations unable to change
unrelated documents, and make before-and-after comparison for the review
log straightforward.

Consequences:

Transformations return a new Book rather than modifying one in place.

Code that needs a node's parent must obtain it through traversal.

---

## HTC-0015

Date:
2026-10-22

Status:
Accepted

Decision:

The EEBO parser shall read EEBO-TCP TEI XML, the Text Creation
Partnership's own encoding of each text (for example
`github.com/textcreationpartnership/A13556`), instead of the HTML pages
that the University of Michigan website renders from it.

EarlyPrint XML is not a parser input. It may be consulted as an aid in
later milestones where it helps, under the project's own rules.

Reason:

A survey of A13556 (*Regula vitæ*, 1631) in all three forms found:

- EEBO HTML splits every paragraph that crosses a page into two `<p>`
  elements with no reliable continuation marker, does not distinguish
  front matter from body, separates margin notes from their anchors,
  adds website text to headings ("CHAP. 1. (Book 1)"), and wraps the
  book in website chrome.
- TCP TEI XML encodes all of these explicitly: `<pb/>` inside `<p>`,
  `<front>`/`<body>`/`<back>` with typed `<div>`s, `<note place>` at its
  point in the text, `<gap reason extent>`, `<g ref="char:EOLhyphen"/>`,
  `<argument>`, `<trailer>`, and a structured `<teiHeader>`. It is the
  source the website's HTML is generated from, so nothing is lost.
- EarlyPrint XML is the TCP text tokenized and annotated (lemma, part of
  speech, standard spelling in `@reg`), with abbreviations expanded and
  line-end hyphens joined. It also fills some illegible gaps with no
  markup recording that it did so, and is "not fully proofread". Using it
  as input would introduce unmarked conjectural readings, contrary to the
  Constitution, and would put spelling regularization in the parser.

Consequences:

The parser uses Nokogiri's XML parser, configured not to load external
entities or access the network.

Most of roadmap Milestone 4 (isolating the book from the website) is no
longer needed. Milestone 4 is redirected to broader TEI coverage and to
identifying source and editorial artifacts.

Where the governing documents say "EEBO HTML" as the input, read "EEBO-TCP
TEI XML". Rules about HTML (no transformation or writer inspects it; it
is parsed once; it is untrusted) apply to all source markup.

The parser preserves TCP's editorial features in the Document Model
rather than resolving them: line-end hyphen markers become `∣` (and
unhyphenated line-end breaks `¦`) in text, as the TCP display does, so
architecture §21–22 still apply; gaps are kept and identified as gaps.

EarlyPrint may later assist, for example:

- Milestone 6: its `@reg` spellings across many texts can suggest
  candidate entries for the YAML modernization dictionaries, each
  reviewed by a person before adoption. Known errors exist (A13556 has
  "Aldermanbury" regularized to "Aldermanburic").
- Abbreviation expansion: its `@orig`/expanded pairs can inform a
  transformation that expands abbreviations.
- Gap review: its filled readings can be offered as suggestions in a
  review report, clearly labelled as EarlyPrint conjectures.

Any such use must keep changes named, reviewable, and attributable, and
must never silently replace the TCP text.

An HTML parser may still be added later, behind the same parser
interface, if a text is available only as a web page.

`spec/fixtures/eebo/A13556.html` is retained as a reference copy of the
HTML form; the parser fixture is `spec/fixtures/eebo/A13556.xml`.

Note (2026-10-22): the reference HTML copy was removed before Milestone 3
was committed. Only `A13556.xml` is kept.

---

## HTC-0016

Date:
2026-10-22

Status:
Accepted

Decision:

The EEBO parser maps TCP TEI to the Document Model as follows (the twelve
decisions proposed in `prompts/03_MILESTONE_3_EEBO_PARSER.md`):

1. Notes: an inline `NoteReference` (new) marks where each note is
   anchored; the note is a `Footnote` (metadata `id`, `place`) placed
   immediately after the paragraph or heading that contains the
   reference. References and notes share ids `note-1`, `note-2`, … in
   document order.
2. `hi rend="sup"` becomes a `Superscript` (new inline element).
3. `div` becomes a `Section` with `kind` from `type` and `n` in metadata;
   `front`/`body`/`back` become the Book's three parts; `head` becomes a
   `Heading` whose level is the division's nesting depth.
4. `argument` → `Section(kind: :argument)`; `q` → `Quotation` with `bibl`
   as a `Paragraph` tagged `role: :citation`; `trailer` → `Paragraph`
   tagged `role: :trailer`.
5. `pb` → `PageBreak(page: n)` with `facs`, and `additions: true` for
   `rendition="simple:additions"`; a duplicate-page `gap` is folded into
   the preceding `PageBreak` as `duplicate: true`.
6. `g` line-end breaks become "∣" (`char:EOLhyphen`) and "¦"
   (`char:EOLunhyphen`); other glyphs keep their own text.
7. Inline `gap` becomes a `Text` of its `desc`, tagged `gap`, `reason`,
   `extent`. Gaps are never filled.
8. `expan` becomes a `Text` of its expansion, tagged `expansion` and the
   abbreviation glyph.
9. `seg rend="decorInit"` becomes plain text.
10. Only XML formatting whitespace is removed: indentation after a
    newline, whitespace at the edges of a block, and the newline after a
    `pb` or `note` that TCP keys on its own line between two printed
    lines (otherwise each page break and margin note would double the
    printed line break). Printed line breaks remain as "\n".
11. Unrecognized elements are kept as text tagged `unrecognized`.
12. Metadata comes from `teiHeader`: title, author, the original
    publisher, place, and date, identifiers grouped by type, and the
    availability statement.

Reason:

TCP encodes these features explicitly (HTC-0015). Each mapping preserves
the source and records its editorial features without resolving them, so
later transformations can make named, reviewable decisions.

Decision 1 originally said "top-level block". Placing a note after the
paragraph or heading that contains its reference keeps it beside its
text when that paragraph sits inside an argument or quotation.

Consequences:

The Document Model gains `NoteReference` and `Superscript`.

Parsers implement `parse_string(source)`; `Parser#parse(path)` reads the
file and calls it. Read failures and malformed XML raise `ParseError`.

Two paragraphs of A13556 still contain a doubled line break where the
XML formatter moved a closing `</hi>` onto its own indented line. No
words are joined; the Milestone 5 whitespace transformation will
normalize these.

---

## HTC-0017

Date:
2026-10-22

Status:
Accepted

Decision:

The TCP character table (`TCP_chars.html`, 1,624 glyphs) is kept as data
in `config/tcp_glyphs.yml`: each glyph name with its Unicode code point,
TCP mapping type, and display form, with the source and retrieval date
in the file header.

When a `<g>` element is empty and is not a line-end break, the EEBO
parser emits the table's display form as a `Text` tagged `glyph: <ref>`.
A glyph the table lacks becomes an empty `Text` tagged `glyph` and
`unrecognized: "g"`, never silently dropped. Glyphs with their own text
keep it.

Reason:

Some P5 glyphs are empty elements whose printed form exists only in the
TCP table (for example `char:abquam`, `char:abrum`, `char:aber`). In a
2,300-text sample every such glyph sat inside `<expan>`, so no text was
lost, but the parser would otherwise drop one met elsewhere.

The table agrees with HTC-0015's line-end glyphs (`∣` U+2223, `¦` U+00A6).

Consequences:

The TCP documentation states no license for the table. It is factual
character-mapping data for CC0 texts, kept with attribution. Before
publishing the project, confirm its terms with the TCP
(tcp-info@umich.edu) or replace it.

The file is generated, not edited by hand.

Note (2026-10-23): every TCP file's header points `char:` refs to
`tcpchars.xml` in the CC0-licensed `textcreationpartnership/Texts`
repository. It defines 42 of the 44 glyphs used in a 2,300-text sample;
`abrum` and `abur` (standard Unicode characters) appear only in
`TCP_chars.html`. Either a CC0 subset or a combination could replace the
current table if its license cannot be confirmed.

---

## HTC-0018

Date:
2026-10-23

Status:
Accepted

Decision:

The EEBO parser handles every element observed in a 2,300-text survey of
EEBO-TCP P5 files (`03_EEBO_TCP_ENCODING.md`), as proposed in
`prompts/04_MILESTONE_4_TEI_COVERAGE.md`:

- D1. A `group` volume's outer front and back matter are the Book's; each
  inner `text` is a `Section(kind: :text)` holding its own
  front-matter, body, and back-matter sections. `floatingText` is a
  `Section` of its `type` (default `:floating_text`), built the same way.
- D2. New block `Line`; `lg` is a `Poem` of lines, nested poems, headings,
  and page breaks. This supersedes HTC-0014's provisional `Poem`.
- D3. `opener`, `closer`, `epigraph`, `postscript` are `Section`s of those
  kinds; `salute`, `signed`, `dateline`, `byline` are `Paragraph`s with
  that `role`.
- D4. `list` is a `List` with its headings before it; `item` is a
  `ListItem`; a `label` joins the item it precedes.
- D5. New blocks `Table`, `TableRow`, `TableCell`; a table's headings come
  before it.
- D6. New block `Figure`; its `figDesc` is a `Paragraph(role:
  :description)`, an artifact.
- D7. New inline `Span` with a `role` for `q`, `bibl`, `date`, `stage`,
  `label`, `ref`, `ptr`, `unclear`, `add`, and a lone `abbr`; `choice`
  with `expan` gives the expansion (HTC-0016 decision 8); new inline
  `Subscript` for `hi rend="sub"`.
- D8. New block `Speech`: a `Paragraph(role: :speaker)` then the speech;
  `stage` between blocks is a `Paragraph(role: :stage_direction)`.
- D9. A block inside running text splits its container: the text before,
  the block, then the text after tagged `continued: true`.
- D10. `lb` is a newline; `milestone` is an empty `Span(:milestone)`, or an
  empty `Paragraph` with the same tags between blocks.
- D11. Every non-authorial node carries `artifact:` (`:gap`,
  `:duplicate_page`, `:transcriber_addition`, `:description`,
  `:expansion`, `:glyph`, `:milestone`, `:forme_work`, `:supplied`).
- D12. `Parser#parse_with_report` returns the Book and a `ParseReport` of
  unrecognized elements, glyphs missing from the TCP table, and
  documented-but-unobserved elements, with their paths.
- D13. Documented but unobserved elements are handled deliberately and
  reported: `ab`, `fw` (artifact), `headnote`, `tailnote`, `sic`/`corr`,
  `del`, `supplied` (artifact), `subst`, `above`, `below`. `lang` is kept
  in metadata wherever it occurs.

Supporting choices made in implementation:

- Running text met directly between blocks (in a division, note, cell,
  list item, opener, and so on) is gathered into a `Paragraph`, as D3–D5
  do for their elements. It is no longer flagged as unrecognized.
- A page break, gap, milestone, or note stands alone only when no running
  text follows it before the next block; otherwise it opens the
  paragraph. (Without this, `<note><gap/>.</note>` split the full stop
  from the gap.)
- A duplicate-page gap is folded into its page break inside running text
  as well as between blocks (HTC-0016 decision 5).
- A note between blocks becomes a `Footnote` in place, with no
  reference.
- Content inside a `list`, `table`, or `row` that is not an item, row, or
  cell is wrapped in one, so nothing is dropped.
- A heading of verse, a list, a table, or a figure is one level below its
  division's.
- A standalone `sic` or `corr` is a `Span` of that role.

Reason:

The survey found 53 elements in use, of which Milestone 3 handled 20. In
a 300-text run, 13 texts failed to parse and 143 lost structure, though
none lost characters.

Consequences:

All nine fixtures and all 2,300 sampled texts parse with no errors, an
empty parse report, and every word kept.

The Document Model gains `Line`, `Table`, `TableRow`, `TableCell`,
`Figure`, `Speech`, `Span`, and `Subscript`.

Writers must handle `continued` pieces and artifacts; a transformation
may rejoin or remove them.

Note (2026-10-26): HTC-0019 T5 supersedes D11's `:transcriber_addition`
kind and HTC-0016 decision 5's `additions: true`: a `simple:additions`
page break is tagged `handwritten_additions: true` and is not an
artifact.

---

## HTC-0019

Date:
2026-10-26

Status:
Accepted

Decision:

The transformation framework and the first cleanup transformations are
built as proposed in `prompts/05_MILESTONE_5_TRANSFORMATION_PIPELINE.md`:

- T1. `Transformation#apply(book, context)` returns a new Book. Each
  transformation has a stable `name` (its class name) and is idempotent.
- T2. `Transformations::Context` carries the configuration and a
  `Review::ChangeLog`. One `Review::Change` (transformation, original,
  replacement, location, rule) is recorded per changed or removed node.
  A `Review::Location` is the node's path of child positions in the Book
  the transformation received, plus the nearest preceding printed page
  number.
- T3. `Transformations::Pipeline` owns the order, as a constant in code.
  Configuration (`transformations:` in YAML) only enables, disables, and
  configures each transformation.
- T4. The order is RemoveArtifacts (default kinds `duplicate_page`,
  `milestone`, `forme_work`), RemoveEmptyBlocks, RepairBrokenWords,
  RemoveDividerCharacters, NormalizeWhitespace. This changes the
  conceptual order of architecture §20: word repair runs before divider
  removal, because `∣` is the evidence of a broken word, and empty-block
  removal follows artifact removal, which creates empty blocks.
- T5. A page break with `rendition="simple:additions"` is tagged
  `handwritten_additions: true`. This supersedes HTC-0016 decision 5's
  `additions: true` and HTC-0018 D11's `:transcriber_addition` artifact
  kind: the TCP keying specification defines the SGML original
  (`PB MS="Y"`) as "any page that contains handwritten corrections,
  deletions, glosses, etc.", so these are real pages.
- T6. After a page break or note on its own line, the parser removes the
  indentation as well as the newline (HTC-0016 decision 10).
- T7. Paragraph pieces split around blocks (HTC-0018 D9) are left as
  they are; presenting them is a writer decision.

Supporting choices made in implementation:

- Running text is the content of a `Paragraph`, `Line`, or `Heading`.
  Within it, text tagged in metadata (gaps, expansions, glyphs) is never
  edited and counts as content; page breaks, note references, and empty
  spans are passed over.
- RemoveEmptyBlocks removes paragraphs, lines, headings, and sections
  with no content. It never removes the Book's three parts or a node
  tagged `artifact:` (removing artifacts is RemoveArtifacts' choice), and
  it never removes an empty table cell, which keeps the table's shape.
- Each transformation's settings live under its snake-case name
  (`remove_artifacts:`) with `enabled:`.

Reason:

In a 300-text sample, deleting `∣` alone repairs 161,927 of 162,803
line-end word breaks; the other 876 have whitespace after the break,
usually before a gap, and can be repaired only while the `∣` remains.
6,069 of 10,043 `simple:additions` page breaks are the only break for
their page image, so removing them as artifacts would delete page
boundaries.

Consequences:

A parsed Book can be cleaned into running text with no line-end break
characters, printed line breaks, or runs of spaces, while every change is
named and located. Review reports and statistics remain Milestone 8.

Over the 2,300-text sample, the pipeline leaves no line-end break
markers, line breaks, or runs of spaces in running text, keeps every
word (with line-end breaks joined) and every gap, and is idempotent. It
records 2,525 duplicate pages and 10,742 milestones removed, 12 empty
blocks removed, and 9,595 broken words repaired.

---

# Amendment Procedure

A new architectural decision may:

Introduce a new capability

Clarify an existing decision

Supersede a previous decision

Deprecate a previous decision

Historic decisions remain in this document permanently.

---

# Status Values

Accepted

Proposed

Deprecated

Superseded

Rejected

Experimental

---

# Versioning

This document shall be updated whenever an architectural decision
changes.

No architectural change is considered complete until recorded here.
