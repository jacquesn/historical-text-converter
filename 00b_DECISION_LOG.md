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
