# Historical Text Converter

## EEBO-TCP Encoding Reference

**Purpose:** What can appear in an EEBO-TCP TEI P5 file, so the EEBO parser
handles structures deliberately rather than only those met in fixtures.
**Status:** Survey of 2026-10-22.

---

# 1. Sources

The TCP documented its encoding for the original SGML files. The TEI P5
files on GitHub, which the parser reads (HTC-0015), were converted from
that SGML; no TCP schema or element mapping for the P5 form is published.
The SGML documentation therefore says what may occur, and the survey in §3
says how it is spelled in P5.

| Source | Use |
|---|---|
| TCP Keying/Coding Specifications — `https://www.textpartnership.net/docs/dox/instruct2.html` | When each element is used; attribute values (SGML names). |
| TCP production DTD — `https://www.textpartnership.net/docs/code/eebo2prf.dtd.txt` | Formal list of the 86 SGML elements. |
| Oxford encoding guides — `https://www.textpartnership.net/docs/oxdox/encoding/` | One page per structure: letters, drama, figures, gaps, lists, notes, tables, title pages, division types. |
| Oxford transcription guides — `https://www.textpartnership.net/docs/oxdox/transcription/` | Abbreviations, foreign text, punctuation, symbols. |
| TCP structure notes — `https://www.textpartnership.net/docs/oxdox/technical/structure.html` | `group` volumes: shared front and back matter around several texts. |
| TCP character table — `https://www.textpartnership.net/docs/code/TCP_chars.html` | All 1,624 glyphs (`<g ref="char:NAME">`); copied to `config/tcp_glyphs.yml` (HTC-0017). No license stated. |
| TCP character declarations — `https://raw.githubusercontent.com/textcreationpartnership/Texts/master/tcpchars.xml` | The P5 `char:` definitions every TCP header points to (`listPrefixDef`): 274 TCP-specific glyphs, in the CC0-licensed `Texts` repository. Defines 42 of the 44 glyphs used in the sample; `abrum` and `abur` (standard Unicode characters) are only in the table above. |
| TCP division types — `https://www.textpartnership.net/docs/dox/typepref.html` | Preferred `div` `type` values. |
| TEI P5 Guidelines — `https://tei-c.org/release/doc/tei-p5-doc/en/html/` | General meaning of each P5 element. |
| EarlyPrint schema — `http://schemata.earlyprint.org/schemata/tei_earlyprint.rng` | A formal P5 schema for EarlyPrint's derivative of these texts; a cross-check. |

---

# 2. Method

* Index: `https://raw.githubusercontent.com/textcreationpartnership/Texts/master/TCP.csv`
  (61,316 texts; 25,368 freely available EEBO texts, i.e. Phase I).
* Sample: 2,300 freely available EEBO texts drawn at random (300 with
  Python `random.seed(20261022)`, then 2,000 more with seed `202610222`).
* Every element under `/TEI/text` was counted, with its parents and
  attribute values, and compared with the DTD and the EarlyPrint schema.

An element used by fewer than about 1 in 2,000 texts may be missing from
the sample; §4 lists the DTD elements not observed.

---

# 3. Elements in TEI P5 files

"Texts" is the number of the 2,300 sampled texts using the element.
"Parser handling" is what the EEBO parser builds (HTC-0016 to HTC-0018;
D numbers refer to HTC-0018). Every element in the table is handled.

| Element | Texts | Usual parents | Attributes | Parser handling |
|---|---:|---|---|---|
| `body` | 2300 | `text`, `floatingText` |  | Book body (HTC-0015) |
| `div` | 2300 | `div`, `body`, `front` | `type`, `lang`, `subtype`, `rend` | `Section(kind: type)` |
| `pb` | 2299 | `p`, `div`, `l` | `rendition` | `PageBreak`; duplicate pages folded in (artifact) |
| `hi` | 2271 | `p`, `item`, `note` | `rend` | `Emphasis`; `Superscript`, `Subscript` (D7) |
| `p` | 2257 | `div`, `sp`, `argument` | `rend` | `Paragraph` |
| `head` | 2236 | `div`, `list`, `lg` | `type` | `Heading` (level from division depth) |
| `g` | 2128 | `p`, `hi`, `note` | `ref` | text; `∣`/`¦`; empty → TCP display form (HTC-0017) |
| `desc` | 1743 | `gap` |  | gap display text |
| `gap` | 1743 | `p`, `hi`, `note` | `reason`, `extent` | `Text` of its display form (artifact `:gap`) |
| `trailer` | 1543 | `div`, `body`, `lg` | `type` | `Paragraph(role: :trailer)` |
| `front` | 1516 | `text` | `lang` | Book front matter |
| `closer` | 1423 | `div`, `body`, `postscript` |  | `Section(kind: :closer)` (D3) |
| `signed` | 1260 | `closer`, `opener`, `div` |  | `Paragraph(role: :signed)` (D3) |
| `seg` | 1198 | `p`, `label`, `hi` | `rend`, `type` | its content |
| `back` | 1064 | `text` |  | Book back matter |
| `q` | 1028 | `p`, `div`, `epigraph` | `rend`, `type`, `lang` | `Quotation` between blocks or holding blocks; `Span(:quotation)` in running text (D7, D9) |
| `l` | 1002 | `lg`, `div`, `sp` | `lang` | `Line` (D2) |
| `opener` | 959 | `div`, `body`, `lg` |  | `Section(kind: :opener)` (D3) |
| `note` | 906 | `p`, `l`, `item` | `place`, `rend`, `type` | `NoteReference` + `Footnote` after its block |
| `item` | 818 | `list` | `ana` | `ListItem` (D4) |
| `list` | 818 | `div`, `item`, `p` | `type` | `List`, headings before it (D4) |
| `date` | 746 | `dateline`, `head`, `closer` |  | `Span(:date)` (D7) |
| `salute` | 679 | `opener`, `closer`, `div` |  | `Paragraph(role: :salute)` (D3) |
| `lg` | 667 | `div`, `sp`, `q` | `lang`, `type`, `rend` | `Poem` (D2) |
| `dateline` | 653 | `closer`, `opener` |  | `Paragraph(role: :dateline)` (D3) |
| `figure` | 649 | `p`, `div`, `head` |  | `Figure` (D6) |
| `bibl` | 632 | `q`, `epigraph`, `div` |  | `Paragraph(role: :citation)` between blocks; `Span(:citation)` in running text (D7) |
| `expan` | 409 | `p`, `l`, `hi` |  | `Text` of expansion (artifact `:expansion`) |
| `am` | 407 | `expan` |  | within `expan` |
| `ex` | 407 | `expan` |  | within `expan` |
| `epigraph` | 330 | `div`, `body` |  | `Section(kind: :epigraph)` (D3) |
| `argument` | 237 | `div`, `body` |  | `Section(kind: :argument)` |
| `floatingText` | 237 | `div`, `q`, `p` | `lang`, `type`, `rend` | `Section(kind: type)` with its own parts (D1) |
| `abbr` | 216 | `p`, `item`, `cell` |  | `Span(:abbreviation)`; in `choice`, kept as metadata (D7) |
| `label` | 212 | `list`, `item`, `p` | `type` | `Paragraph(role: :label)` joined to its item; `Span(:label)` in running text (D4, D7) |
| `cell` | 184 | `row` | `role`, `cols`, `rows` | `TableCell` (D5) |
| `row` | 184 | `table` | `role` | `TableRow` (D5) |
| `table` | 184 | `p`, `item`, `head` | `rend` | `Table`, headings before it (D5) |
| `figDesc` | 180 | `figure` |  | `Paragraph(role: :description)`, artifact (D6) |
| `sp` | 179 | `div`, `q`, `item` |  | `Speech` (D8) |
| `speaker` | 175 | `sp` |  | `Paragraph(role: :speaker)` (D8) |
| `group` | 118 | `text` |  | body of separate texts (D1) |
| `text` | 118 | `group` | `lang` | `Section(kind: :text)` with its own parts (D1) |
| `milestone` | 114 | `p`, `l`, `item` | `type`, `unit` | empty `Span(:milestone)`; empty `Paragraph` between blocks; artifact (D10) |
| `byline` | 104 | `div`, `figure`, `body` |  | `Paragraph(role: :byline)` (D3) |
| `lb` | 97 | `p`, `cell`, `q` |  | newline (D10) |
| `stage` | 88 | `div`, `sp`, `l` |  | `Paragraph(role: :stage_direction)`; `Span` in running text (D7, D8) |
| `unclear` | 75 | `p`, `l`, `hi` | `reason` | `Span(:unclear)` (D7) |
| `postscript` | 67 | `div`, `body` |  | `Section(kind: :postscript)` (D3) |
| `add` | 27 | `cell`, `p`, `l` |  | `Span(:addition)` (D7) |
| `choice` | 7 | `p`, `cell`, `item` |  | expansion `Text`, or the reading as printed (D7, D13) |
| `ref` | 3 | `l`, `p`, `cell` | `target` | `Span(:reference)` (D7) |
| `ptr` | 1 | `p` | `target` | empty `Span(:pointer)` (D7) |

---

# 4. SGML to P5 differences

Observed renamings:

| SGML (DTD, keying spec) | TEI P5 (GitHub files) |
|---|---|
| `DIV1` … `DIV7` | nested `div` |
| `LETTER`, `FLOATEXT` | `floatingText` (`type="letter"` for letters) |
| `FIGDESC` | `figDesc` |
| `GAP DESC="…"` | `gap reason="…"` with a `desc` child holding the display form |
| `NOTE PLACE="marg"`, `"foot"` | `note place="margin"`, `"bottom"` |
| character entities (`&abque;`) | `<g ref="char:abque"/>` |
| abbreviation with expansion | `expan` (`am` + `ex`), or `choice` (`abbr` + `expan`) |

DTD elements not observed in the 2,300 P5 texts: `ab`, `fw` (running
heads, catchwords), `headnote`, `tailnote`, `del`, `supplied`, `subst`,
`sic`, `corr`, `above`, `below`. Of these, the EarlyPrint schema allows
`ab`, `fw`, `del`, `supplied`, `subst`, `sic`, `corr`. The parser handles
each deliberately and reports it when met (HTC-0018 D12, D13):

| Element | Parser handling |
|---|---|
| `ab` | `Paragraph` |
| `fw` | `Paragraph(role: :forme_work)`, artifact |
| `headnote`, `tailnote` | `Paragraph` with that role |
| `sic` / `corr` in `choice` | `Span(:sic)` of the reading as printed, with the correction in metadata |
| `del`, `subst`, `above`, `below` | `Span` with that role |
| `supplied` | `Span(:supplied)`, artifact |

---

# 5. Attribute values

| Attribute | Values observed (most frequent first) |
|---|---|
| `div/@type` | 1,260 distinct: part, chapter, section, poem, title_page, subpart, epigram, subsection, … |
| `div/@lang`, `lg/@lang`, `q/@lang`, `floatingText/@lang` | lat, eng, fre, grc, ang, ita, spa, heb, wel, … |
| `note/@place` | margin, bottom, parend, marg1, inline, marg2, end |
| `gap/@reason` | 30 distinct: illegible, foreign, music, duplicate, math, "illegible: faint", "illegible: missing", "illegible: in gutter", … |
| `hi/@rend` | (none: italic), sup, margQuotes, blackletterType, sub, IrishType, AngloSaxonType, stage |
| `q/@rend` | margQuotes, "inline margQuotes", roman |
| `lg/@type` | 14 distinct: refrain, sonnet, song, chorus, poem, anagram, speech, verse, … |
| `head/@type` | sub, illustration, song |
| `cell/@role`, `row/@role` | label, total |
| `cell/@cols`, `cell/@rows` | spans |
| `seg/@rend` | decorInit, above |
| `milestone/@unit` | unspecified, "Comment.", Moneths, year |
| `pb/@rendition` | simple:additions |
| `unclear/@reason` | blotted |

---

# 6. Block structures inside running text

TCP places block structures inside paragraphs, list items, table cells,
headings, and verse lines (occurrences in the 2,300 texts):

| Context | Occurrences | Texts |
|---|---:|---:|
| `item` > `list` | 7,458 | 173 |
| `p` > `figure` | 2,198 | 373 |
| `p` > `table` | 1,959 | 173 |
| `p` > `list` | 1,539 | 283 |
| `p` > `floatingText` | 143 | 58 |
| `head` > `figure` | 271 | 130 |
| `q` with block content inside running text | 4,465 | — |

The Document Model keeps blocks and inline content apart (HTC-0014). The
parser splits the running text around each such block, tagging the text
after it `continued: true` (HTC-0018 D9).

---

# 7. Parser results on the sample

With the Milestone 4 parser (2026-10-23), all 2,300 sampled texts parse
with no errors and an empty parse report (no unrecognized elements, no
unknown glyphs), and every word of each source is kept, checked with
`spec/support/source_words.rb`. Structure counts match the source: for
example 80,516 `Line`s from 80,513 `l` (three lines split around blocks),
and one `Poem`, `Speech`, `Table`, `Figure`, or `List` per `lg`, `sp`,
`table`, `figure`, or `list`.
