# Historical Text Converter

## Architecture Specification

**Version:** 1.0
**Status:** Proposed
**Language:** Ruby
**Primary initial source:** EEBO HTML
**Primary initial outputs:** DOCX and RTF

---

# 1. Purpose

This document defines the technical architecture of Historical Text
Converter.

It specifies:

* the major components of the application;
* the responsibilities of those components;
* the relationships between components;
* the document-processing pipeline;
* the internal Document Model;
* parser and writer interfaces;
* transformation architecture;
* configuration architecture;
* logging and review architecture;
* error handling;
* extension points.

This document is an implementation blueprint.

It does not specify individual historical spelling rules. Those belong in
`05_MODERNIZATION_SPEC.md`.

---

# 2. Architectural Overview

Historical Text Converter follows this architecture:

```text
                    SOURCE DOCUMENT
                          │
                          ▼
                    ┌───────────┐
                    │   Parser  │
                    └─────┬─────┘
                          │
                          ▼
                 ┌─────────────────┐
                 │  Document Model │
                 └────────┬────────┘
                          │
                          ▼
                ┌───────────────────┐
                │ Transformation    │
                │ Pipeline          │
                └────────┬──────────┘
                         │
             ┌───────────┴───────────┐
             │                       │
             ▼                       ▼
      ┌─────────────┐        ┌─────────────┐
      │ Review Log  │        │ Document    │
      │ / Statistics│        │ Model       │
      └─────────────┘        └──────┬──────┘
                                    │
                                    ▼
                              ┌──────────┐
                              │  Writer  │
                              └────┬─────┘
                                   │
                                   ▼
                                OUTPUT
```

The central architectural rule is:

> Parsers create the Document Model. Transformations modify the Document
> Model. Writers consume the Document Model.

No component should bypass this architecture without an explicit
architectural decision.

---

# 3. Major Components

The application consists of the following major components:

```text
HistoricalTextConverter
│
├── CLI
├── Configuration
├── Parsers
│   └── EEBO
│
├── Document Model
│
├── Transformations
│   ├── Structural Cleanup
│   ├── Text Cleanup
│   ├── Modernization
│   └── Americanization
│
├── Review / Logging
│
└── Writers
    ├── DOCX
    ├── RTF
    ├── Plain Text
    ├── Markdown
    └── HTML
```

Only the first implementations of these components are required for
Version 1.

The architecture should nevertheless permit future implementations.

---

# 4. Recommended Directory Structure

The initial project should use the following structure:

```text
historical-text-converter/
│
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── README.md
├── CHANGELOG.md
├── Rakefile
├── .gitignore
├── .rubocop.yml
│
├── bin/
│   └── historical-text-converter
│
├── lib/
│   └── historical_text_converter.rb
│
├── lib/historical_text_converter/
│   │
│   ├── version.rb
│   ├── cli.rb
│   ├── configuration.rb
│   ├── errors.rb
│   │
│   ├── document/
│   │   ├── book.rb
│   │   ├── metadata.rb
│   │   ├── node.rb
│   │   ├── document.rb
│   │   ├── section.rb
│   │   ├── heading.rb
│   │   ├── paragraph.rb
│   │   ├── quotation.rb
│   │   ├── poem.rb
│   │   ├── list.rb
│   │   ├── list_item.rb
│   │   ├── footnote.rb
│   │   ├── page_break.rb
│   │   ├── inline.rb
│   │   ├── text.rb
│   │   └── emphasis.rb
│   │
│   ├── parsers/
│   │   ├── parser.rb
│   │   └── eebo/
│   │       ├── parser.rb
│   │       ├── extractor.rb
│   │       ├── structure_detector.rb
│   │       └── artifact_detector.rb
│   │
│   ├── transformations/
│   │   ├── transformation.rb
│   │   ├── pipeline.rb
│   │   │
│   │   ├── cleanup/
│   │   │   ├── remove_artifacts.rb
│   │   │   ├── remove_divider_characters.rb
│   │   │   ├── repair_hyphenation.rb
│   │   │   └── normalize_whitespace.rb
│   │   │
│   │   ├── modernization/
│   │   │   ├── modernize_spelling.rb
│   │   │   ├── americanize.rb
│   │   │   ├── dictionary.rb
│   │   │   ├── rule.rb
│   │   │   └── rule_engine.rb
│   │   │
│   │   └── corrections/
│   │       └── correct_printer_errors.rb
│   │
│   ├── review/
│   │   ├── change.rb
│   │   ├── change_log.rb
│   │   ├── statistics.rb
│   │   └── reporters/
│   │       ├── text_reporter.rb
│   │       ├── csv_reporter.rb
│   │       └── json_reporter.rb
│   │
│   └── writers/
│       ├── writer.rb
│       ├── docx_writer.rb
│       ├── rtf_writer.rb
│       ├── markdown_writer.rb
│       ├── html_writer.rb
│       └── text_writer.rb
│
├── config/
│   ├── default.yml
│   ├── profiles/
│   │   ├── scholarly.yml
│   │   ├── conservative.yml
│   │   └── modern_reader.yml
│   │
│   └── dictionaries/
│       ├── archaic.yml
│       ├── american.yml
│       └── corrections.yml
│
├── spec/
│   ├── spec_helper.rb
│   │
│   ├── document/
│   ├── parsers/
│   ├── transformations/
│   ├── review/
│   └── writers/
│
├── fixtures/
│   ├── eebo/
│   ├── documents/
│   └── expected/
│
└── docs/
    ├── 00_PROJECT_CONSTITUTION.md
    ├── 00a_GLOSSARY.md
    ├── 00b_DECISION_LOG.md
    ├── 00c_ARCHITECTURAL_PRINCIPLES.md
    └── 01_ARCHITECTURE.md
```

The exact structure may be refined during implementation, but changes
should be recorded in the Decision Log.

---

# 5. Application Entry Point

The public Ruby entry point shall be:

```ruby
require "historical_text_converter"
```

The library namespace shall be:

```ruby
HistoricalTextConverter
```

All project classes should reside within this namespace.

Example:

```ruby
HistoricalTextConverter::Document::Book
```

---

# 6. CLI

The command-line interface is the primary user interface for Version 1.

A basic invocation should eventually look like:

```bash
historical-text-converter input.html
```

The converter should support explicit output:

```bash
historical-text-converter input.html \
  --output book.docx \
  --format docx
```

Configuration:

```bash
historical-text-converter input.html \
  --config config.yml
```

Profile:

```bash
historical-text-converter input.html \
  --profile conservative
```

Review report:

```bash
historical-text-converter input.html \
  --report changes.csv
```

The CLI should remain thin.

It should parse arguments and invoke application services.

Business logic must not reside in the CLI.

---

# 7. Configuration

Configuration shall be represented by a dedicated object:

```ruby
HistoricalTextConverter::Configuration
```

Configuration responsibilities include:

* loading YAML;
* applying defaults;
* selecting a profile;
* enabling/disabling transformations;
* selecting writers;
* configuring logging;
* locating dictionaries.

The rest of the application should receive configuration rather than
reading YAML files directly.

---

# 8. Document Model

The Document Model is the central data structure.

It represents the semantic structure of the historical work.

The model must not contain:

* HTML nodes;
* Nokogiri objects;
* writer-specific objects;
* output-format-specific markup.

---

# 9. Root Document

The root object should be:

```ruby
HistoricalTextConverter::Document::Book
```

A Book contains:

```text
metadata
front_matter
body
back_matter
```

Example:

```ruby
Book
├── Metadata
├── Front Matter
│   ├── Title Page
│   ├── Dedication
│   └── Preface
├── Body
│   ├── Chapter
│   │   ├── Heading
│   │   ├── Paragraph
│   │   └── Quotation
│   └── Chapter
└── Back Matter
```

---

# 10. Node Architecture

All semantic document elements should derive from a common conceptual
Node interface.

The exact Ruby implementation may use inheritance or composition, but
the public behavior should be consistent.

A Node should expose enough information for transformations and writers
to operate without knowing its concrete origin.

At minimum:

```ruby
node.children
node.parent
node.metadata
```

where appropriate.

---

# 11. Block Elements

Initial block elements include:

```text
Section
Heading
Paragraph
Quotation
Poem
List
ListItem
Footnote
PageBreak
```

Additional elements may be introduced when required by real source
documents.

Do not create semantic elements speculatively.

---

# 12. Inline Elements

Inline content must support formatting without embedding HTML.

Initial inline concepts include:

```text
Text
Emphasis
```

Future inline elements may include:

```text
Strong
SmallCaps
Superscript
Subscript
Link
Citation
```

Only introduce an element when a source or output requirement justifies it.

---

# 13. Formatting

Formatting is represented semantically.

For example:

```ruby
Emphasis.new(
  children: [
    Text.new("important")
  ]
)
```

is preferable to:

```ruby
Text.new("<em>important</em>")
```

The latter violates the Document Model boundary.

---

# 14. Parser Interface

All parsers shall implement a common interface.

Conceptually:

```ruby
class Parser
  def parse(source)
    raise NotImplementedError
  end
end
```

A parser receives a source and returns a Book.

Example:

```ruby
book = EEBO::Parser.new.parse("book.html")
```

The parser must not perform modernization.

---

# 15. EEBO Parser

The EEBO parser is the first production parser.

It shall:

1. Load the HTML.
2. Parse it with Nokogiri.
3. Identify the actual book content.
4. Ignore website navigation and surrounding interface.
5. Detect structural elements.
6. Preserve formatting represented by the source.
7. Extract footnotes where identifiable.
8. Construct the Document Model.

The EEBO parser should not:

* modernize spelling;
* Americanize spelling;
* correct printer errors;
* remove `∣`;
* normalize whitespace beyond what is necessary to construct the model.

Those operations belong to later transformations.

---

# 16. EEBO Source Isolation

EEBO pages may contain material that is not part of the book.

Examples include:

```text
PAGE [UNNUMBERED]
PAGE [1]
navigation
website controls
metadata
transcription interface elements
```

The parser must distinguish source material from the book itself.

This distinction is a parser responsibility because it depends upon the
source format.

---

# 17. Transformation Interface

Every transformation shall implement a common interface.

Conceptually:

```ruby
class Transformation
  def apply(book, context)
    raise NotImplementedError
  end
end
```

A transformation receives:

* the Book;
* transformation context.

It returns the transformed Book.

The transformation may also record changes in the review log.

---

# 18. Transformation Context

The context object may provide:

```text
configuration
change_log
statistics
logger
```

This prevents transformations from depending on global state.

Example:

```ruby
context.change_log.record(...)
```

rather than:

```ruby
GlobalChangeLog.record(...)
```

---

# 19. Transformation Pipeline

The pipeline owns transformation order.

Conceptually:

```ruby
pipeline = TransformationPipeline.new([
  RemoveArtifacts.new,
  RemoveDividerCharacters.new,
  RepairHyphenation.new,
  NormalizeWhitespace.new,
  ModernizeSpelling.new,
  Americanize.new
])

book = pipeline.call(book)
```

The pipeline should not contain the implementation of individual
transformations.

---

# 20. Transformation Ordering

The initial conceptual order is:

```text
1. Structural cleanup
2. Artifact removal
3. Character cleanup
4. Word-boundary repair
5. Whitespace normalization
6. Spelling modernization
7. Americanization
8. Printer-error correction
9. Final validation
```

The exact ordering shall be verified through tests.

A transformation that depends upon an earlier transformation must document
that dependency.

---

# 21. Divider Character Removal

The character:

```text
∣
```

shall be removed by a dedicated transformation.

It shall not be removed by the parser.

It shall not be removed by the modernization engine.

This permits the operation to be independently tested and configured.

---

# 22. Word-Boundary Repair

Historical transcriptions may contain words broken across lines or pages.

For example:

```text
pesti∣
ferous
```

may represent:

```text
pestiferous
```

The repair transformation must distinguish:

* genuine hyphenation;
* transcription separators;
* punctuation;
* intentional line breaks.

The algorithm must be conservative.

When uncertain, it should preserve the source rather than invent a reading.

---

# 23. Modernization Engine

Modernization shall be implemented independently from the parser.

The engine consists conceptually of:

```text
Modernization
│
├── Dictionary
├── Rules
├── Exceptions
└── Review Logging
```

The modernization engine operates on textual content inside the Document
Model.

---

# 24. Tokenization

Word-based transformations shall operate on tokens rather than arbitrary
substrings.

For example:

```text
hee
```

may become:

```text
he
```

but the sequence `hee` appearing inside another word must not be altered
unless an explicit rule requires it.

This prevents accidental transformations.

---

# 25. Protected Words

Some historical forms must remain unchanged under the conservative
modernization profile.

Initial protected forms include:

```text
hath
doth
saith
thou
thee
thy
```

The protection mechanism shall be configurable.

---

# 26. Americanization Engine

Americanization shall be implemented as a separate transformation.

Example:

```text
labour → labor
honour → honor
colour → color
defence → defense
```

The Americanization engine must not contain historical spelling
modernization rules.

This separation permits:

```text
modern spelling + British spelling
```

as well as:

```text
modern spelling + American spelling
```

---

# 27. Dictionaries

Dictionaries shall be external data files.

Recommended format:

```yaml
hee:
  modern: he
  type: spelling

dayes:
  modern: days
  type: spelling

labour:
  modern: labor
  type: american
```

The dictionary loader shall validate dictionary entries before use.

Invalid dictionary data should produce a clear configuration error.

---

# 28. Rule Engine

Some transformations cannot safely be implemented as simple dictionary
entries.

The rule engine supports:

* contextual replacements;
* morphological patterns;
* protected words;
* case handling;
* punctuation-aware transformations.

Rules should be conservative.

When an algorithm cannot confidently determine the intended reading,
it should leave the text unchanged and optionally report it for review.

---

# 29. Printer Errors

Printer-error correction is separate from spelling modernization.

An obvious error may be corrected only when the intended reading is
sufficiently clear.

Corrections should be:

* configurable;
* explicitly identified;
* logged.

The software must never silently make substantive editorial decisions.

---

# 30. Review System

The review subsystem records transformations.

The central object is:

```ruby
HistoricalTextConverter::Review::Change
```

A Change should contain, where available:

```text
transformation
original text
replacement text
location
context
rule
confidence
```

---

# 31. Change Log

The Change Log collects Change objects.

It should support:

```ruby
change_log.changes
change_log.count
change_log.by_transformation
```

It should also support exporting reports.

---

# 32. Statistics

Statistics should summarize processing.

Examples:

```text
Paragraphs processed: 4,283

Characters removed: 1,286

Words modernized: 3,842

British spellings Americanized: 217

Printer errors corrected: 14
```

Statistics are informational and must not alter the document.

---

# 33. Writers

All writers implement a common conceptual interface:

```ruby
class Writer
  def write(book, destination)
    raise NotImplementedError
  end
end
```

A writer receives a completed Book.

It does not inspect source HTML.

It does not perform transformations.

---

# 34. DOCX Writer

The DOCX writer shall initially support:

* paragraphs;
* headings;
* italics;
* quotations;
* footnotes;
* page breaks;
* basic metadata.

DOCX generation must preserve the semantic structure of the Document
Model.

---

# 35. RTF Writer

The RTF writer shall support at minimum:

* paragraphs;
* headings;
* italics;
* quotations;
* footnotes where technically practical;
* page breaks;
* Unicode text.

RTF escaping must be handled centrally.

Raw source text must never be inserted directly into RTF without escaping.

---

# 36. Plain Text Writer

The plain-text writer is primarily a debugging and validation tool.

It should provide a readable representation of the final Document Model.

It should not attempt to reproduce visual formatting.

---

# 37. Markdown Writer

The Markdown writer is useful for:

* debugging;
* version control;
* human inspection;
* intermediate processing.

Semantic structures should map naturally to Markdown.

---

# 38. HTML Writer

The HTML writer is useful for:

* browser review;
* debugging;
* future web interfaces.

Generated HTML must be independent of the source HTML.

---

# 39. Writer Selection

Writer selection belongs to the application layer.

Example:

```ruby
writer = WriterFactory.for(:docx)
writer.write(book, output_path)
```

The factory should not contain writer implementation details.

---

# 40. Dependency Flow

Dependencies should flow inward.

```text
CLI
 │
 ▼
Application
 │
 ├── Configuration
 ├── Parser
 ├── Pipeline
 │    └── Transformations
 │
 └── Writer
```

The Document Model sits at the center.

Parsers may depend on the Document Model.

Transformations may depend on the Document Model.

Writers may depend on the Document Model.

The Document Model must not depend on parsers or writers.

---

# 41. External Dependencies

Initial expected dependencies:

```text
nokogiri
yaml
rspec
rubocop
```

A DOCX library may be evaluated during the writer milestone.

Additional dependencies require justification.

---

# 42. Error Classes

Application-specific errors should be namespaced.

Examples:

```ruby
HistoricalTextConverter::Error

HistoricalTextConverter::ParseError

HistoricalTextConverter::ConfigurationError

HistoricalTextConverter::TransformationError

HistoricalTextConverter::WriterError
```

Errors should provide actionable messages.

---

# 43. Logging

The application may provide normal logging for:

* warnings;
* errors;
* progress;
* statistics.

Transformation review information belongs in the Change Log rather than
ordinary application logs.

---

# 44. Validation

The application should validate the Document Model between major stages
when practical.

Validation should detect:

* malformed nodes;
* orphaned footnotes;
* invalid parent-child relationships;
* impossible structures;
* missing required metadata.

Validation should not attempt to judge historical correctness.

---

# 45. Immutability vs Mutation

The implementation may mutate Document Model objects for performance,
provided that mutation is controlled and testable.

However:

* transformations must not modify unrelated documents;
* shared objects must not be unexpectedly changed;
* global mutable state is prohibited.

If immutable transformations prove practical without unreasonable
complexity, they are preferred.

---

# 46. Testing Architecture

Tests should exist at four levels.

## Unit Tests

Test individual classes.

Example:

```text
Dictionary
Paragraph
ModernizeSpelling
RemoveDividerCharacters
```

## Integration Tests

Test groups of components.

Example:

```text
EEBO Parser → Document Model
```

## Pipeline Tests

Test complete transformation sequences.

Example:

```text
EEBO HTML
→ parse
→ cleanup
→ modernization
→ final Book
```

## End-to-End Tests

Test:

```text
input HTML
→ output DOCX/RTF
```

---

# 47. Fixtures

Realistic fixtures are essential.

The project should maintain small HTML samples representing:

* title pages;
* ordinary paragraphs;
* italic text;
* headings;
* footnotes;
* page markers;
* broken words;
* quotations;
* lists;
* unusual typography;
* EEBO navigation.

Fixtures should be small enough to understand manually.

---

# 48. Regression Testing

Every discovered bug should receive:

1. a minimal fixture;
2. a test reproducing the problem;
3. a correction;
4. a regression test.

A bug is not considered fixed until its regression test passes.

---

# 49. CLI Integration Testing

At least one end-to-end test should invoke the actual command-line interface.

The test should verify:

* successful processing;
* expected output file;
* expected exit status;
* useful errors for invalid input.

---

# 50. API Stability

The following should be considered public interfaces:

```ruby
HistoricalTextConverter
HistoricalTextConverter::Configuration
HistoricalTextConverter::Document
HistoricalTextConverter::Parser
HistoricalTextConverter::Transformation
HistoricalTextConverter::Writer
```

Internal implementation classes may change more freely.

---

# 51. Versioning

The project shall use Semantic Versioning.

```text
MAJOR.MINOR.PATCH
```

Breaking public API changes require a major version.

Backward-compatible functionality requires a minor version.

Bug fixes require a patch version.

---

# 52. Future Parser Architecture

Future parsers should implement the parser interface and produce the same
Document Model.

For example:

```text
EEBOParser
ECCOParser
GutenbergParser
InternetArchiveParser
```

may all produce:

```text
Book
```

The transformation pipeline should not need to know which parser produced
the Book.

---

# 53. Future Writer Architecture

Future writers should consume the same Document Model.

For example:

```text
DocxWriter
RtfWriter
EpubWriter
PdfWriter
MarkdownWriter
```

may all consume:

```text
Book
```

No writer should require parser-specific information.

---

# 54. Application Service

The application should eventually expose a high-level service resembling:

```ruby
HistoricalTextConverter::Application
```

Conceptually:

```ruby
application.convert(
  source: input,
  parser: :eebo,
  profile: :conservative,
  writer: :docx,
  output: destination
)
```

The Application coordinates components.

It should not implement their internal logic.

---

# 55. Factory Objects

Factories may be used where selection is configuration-driven.

Examples:

```text
ParserFactory
WriterFactory
ProfileFactory
```

Factories should remain small.

Do not create factories merely to wrap a single constructor without a
real selection problem.

---

# 56. No AI Dependency

Version 1 shall not require an external AI service.

Historical Text Converter must be deterministic and usable offline once
its Ruby dependencies are installed.

AI-assisted features may be considered in a future version.

If introduced, AI output must never silently replace deterministic
processing.

---

# 57. Reproducibility

A conversion should be reproducible.

Given:

```text
same source
same application version
same configuration
same dictionaries
```

the result should be equivalent.

The application should record enough metadata to identify the processing
environment when requested.

---

# 58. Intermediate Representations

The application may eventually support saving the Document Model to an
intermediate format.

Possible future format:

```text
JSON
XML
```

This is not required for Version 1.

The architecture should not prevent it.

---

# 59. Security

Source HTML must be treated as untrusted input.

The application must not:

* execute JavaScript;
* execute embedded source code;
* follow arbitrary commands;
* write outside requested destinations;
* interpret source HTML as executable application logic.

Generated HTML and documents must escape source content appropriately.

---

# 60. File Handling

The application should:

* verify input exists;
* verify it is readable;
* report encoding problems;
* avoid overwriting output by default;
* provide an explicit overwrite option.

Temporary files should be cleaned up reliably.

---

# 61. Encoding

UTF-8 shall be the internal text encoding.

Source encodings must be normalized into UTF-8 during parsing.

Writers shall encode output according to their format requirements.

Unicode characters must be preserved whenever possible.

---

# 62. Whitespace

Whitespace normalization belongs to transformations.

Parsers may normalize whitespace only where necessary to correctly construct
the Document Model.

Writers are responsible for output-format-specific whitespace.

---

# 63. Page Information

Historical page boundaries may be useful information.

The parser should preserve meaningful page boundaries when identifiable.

Whether those boundaries appear in the final output is a configuration
decision.

EEBO interface markers such as:

```text
PAGE [UNNUMBERED]
```

are not automatically considered meaningful page boundaries.

---

# 64. Editorial vs Authorial Material

The system should distinguish, when the source allows it, between:

* authorial text;
* authorial notes;
* printer material;
* editorial notes;
* source metadata.

When such distinctions cannot be reliably determined, the application
should preserve the material and report uncertainty rather than silently
discard it.

---

# 65. Uncertainty

Historical text processing necessarily involves uncertainty.

The system shall prefer:

preservation

over

speculation.

When an automatic transformation is uncertain, the preferred behavior is:

```text
leave unchanged
+
record for review
```

rather than:

```text
guess
+
silently change
```

---

# 66. Location Tracking

Changes should eventually be associated with a meaningful location.

Possible location information:

```text
chapter
section
paragraph
page
character offset
```

The exact location model will be specified during implementation.

Location tracking should not require writers to understand parser-specific
coordinates.

---

# 67. Provenance

The system should preserve source provenance where available.

Metadata may include:

```text
source
source URL
source identifier
retrieval date
parser
parser version
configuration profile
application version
```

Provenance is metadata, not book text.

---

# 68. CLI Exit Codes

The CLI should eventually distinguish:

```text
0  success

1  general processing error

2  invalid command/configuration

3  input parsing error

4  output generation error
```

Exact values may be refined during CLI implementation.

---

# 69. Progress Reporting

For large books, the CLI should provide useful progress information.

Progress reporting must not contaminate generated output files.

It should be possible to disable progress output for scripting.

---

# 70. Batch Processing

The architecture should permit future commands such as:

```bash
historical-text-converter books/*.html
```

without redesigning the parser or transformation layers.

Batch processing is not required for the first milestone.

---

# 71. Parallel Processing

Parallel processing may eventually be used for multiple independent books.

Individual Book processing should remain isolated.

No global mutable state should prevent parallel processing.

---

# 72. Testing Real Historical Material

Synthetic unit tests are necessary but insufficient.

The project should maintain a small collection of real historical
examples representing difficult cases.

These examples should be legally distributable or limited to appropriately
licensed material.

---

# 73. Development Workflow

Each milestone should:

1. begin from the current repository;
2. read all governing documentation;
3. implement only its assigned scope;
4. add tests;
5. run the complete test suite;
6. update documentation when necessary;
7. update the Decision Log for architectural changes.

---

# 74. Architectural Changes

A developer must not casually alter a foundational architectural decision.

When a change is necessary:

1. explain the problem;
2. identify the affected principle;
3. propose alternatives;
4. choose the preferred solution;
5. record the decision in `00b_DECISION_LOG.md`;
6. update this document if necessary;
7. implement the change;
8. add regression tests.

---

# 75. Implementation Priority

When tradeoffs arise, prioritize:

1. Historical integrity
2. Correctness
3. Testability
4. Maintainability
5. User configurability
6. Performance
7. Convenience

Performance should not override correctness.

Convenience should not override historical integrity.

---

# 76. Version 1 Scope

Version 1 should focus on:

* Ruby project foundation;
* EEBO HTML parsing;
* semantic Document Model;
* cleanup transformations;
* conservative spelling modernization;
* optional Americanization;
* review logging;
* DOCX output;
* RTF output;
* CLI;
* configuration;
* comprehensive tests.

Future formats and parsers should not delay Version 1.

---

# 77. Architectural Success Criteria

The architecture will be considered successful when:

1. An EEBO HTML document can be parsed without writer-specific logic.

2. The resulting Book can be transformed without reference to HTML.

3. The same Book can be written as DOCX, RTF, Markdown, or plain text.

4. Modernization can be enabled or disabled independently.

5. Americanization can be enabled or disabled independently.

6. Every automatic transformation can be reviewed.

7. New transformation rules can be added without changing parser code.

8. A new parser can be added without changing transformation code.

9. A new writer can be added without changing parser code.

10. Tests can identify regressions in any major component.

---

# 78. Canonical Data Flow

The canonical Version 1 flow is:

```text
                 EEBO HTML
                     │
                     ▼
              ┌─────────────┐
              │ EEBO Parser │
              └──────┬──────┘
                     │
                     ▼
                  Book
                     │
                     ▼
          Structural Validation
                     │
                     ▼
           Transformation Pipeline
                     │
          ┌──────────┼──────────┐
          │          │          │
       Cleanup  Modernization  Review
          │          │          │
          └──────────┼──────────┘
                     │
                     ▼
             Final Validation
                     │
                     ▼
                   Book
                     │
              ┌──────┴──────┐
              │             │
              ▼             ▼
           DOCX           RTF
```

---

# 79. Final Architectural Rule

The entire application should be understandable through one sentence:

> Historical Text Converter converts source documents into a semantic
> historical-text model, applies explicit and reviewable transformations,
> and renders the resulting model into user-selected output formats.

When a proposed feature does not fit this model, its architectural impact
must be examined before implementation.
