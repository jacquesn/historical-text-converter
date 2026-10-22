# Historical Text Converter

## Development Roadmap

**Document:** `02_DEVELOPMENT_ROADMAP.md`
**Version:** 1.0
**Status:** Development Blueprint
**Project:** Historical Text Converter
**Language:** Ruby

---

## 1. Purpose

This document defines the implementation roadmap for **Historical Text Converter (HTC)**.

The architecture document describes what the system should look like. This roadmap describes **how to build it incrementally**.

The project should be developed in small, independently verifiable milestones. Each milestone should leave the project in a working state.

The roadmap is intentionally designed so that individual milestones can be assigned to separate Claude Code sessions.

Every implementation session should begin by reviewing:

1. `00_PROJECT_CONSTITUTION.md`
2. `00a_GLOSSARY.md`
3. `00b_DECISION_LOG.md`
4. `00c_ARCHITECTURAL_PRINCIPLES.md`
5. `01_ARCHITECTURE.md`
6. This document

These documents constitute the governing design for the project.

---

# 2. Development Philosophy

Historical Text Converter should not be built as one large script.

Development should proceed from:

```text
Project Foundation
        ↓
Document Model
        ↓
Source Parsing
        ↓
Source Isolation
        ↓
Transformations
        ↓
Review System
        ↓
Writers
        ↓
End-to-End Integration
        ↓
Packaging and Release
```

Each stage should establish a stable foundation for the next.

The following principles govern development:

* Build the smallest useful thing first.
* Keep every milestone runnable.
* Keep tests green before moving forward.
* Do not prematurely implement future features.
* Do not mix parsing, transformation, and writing logic.
* Do not allow output requirements to distort the Document Model.
* Do not silently change architectural decisions.
* Record significant architectural changes in `00b_DECISION_LOG.md`.
* Add regression tests for discovered bugs.
* Prefer simple, explicit code over clever abstractions.
* Keep transformations independently testable.
* Preserve historical information unless removal is intentional and documented.

---

# 3. Milestone Structure

Each milestone should contain:

1. **Goal**
2. **Scope**
3. **Files to create or modify**
4. **Implementation requirements**
5. **Tests**
6. **Acceptance criteria**
7. **Deliverables**
8. **Stop conditions**

A milestone is complete only when its acceptance criteria have been satisfied.

A later milestone must not be used to conceal unfinished work from an earlier milestone.

---

# 4. Milestone 1 — Project Foundation

## Goal

Create the basic Ruby project structure and development environment.

At the end of this milestone, Historical Text Converter should be a valid Ruby project that can:

* load the main library;
* run a minimal CLI;
* load configuration;
* run RSpec;
* run RuboCop;
* report its version.

No historical-text transformation should be implemented yet.

## Scope

Create the basic project skeleton described in `01_ARCHITECTURE.md`.

## Files

Create the necessary foundation files, including:

```text
Gemfile
Rakefile
README.md
CHANGELOG.md
LICENSE
.gitignore
.rubocop.yml

bin/historical-text-converter

lib/historical_text_converter.rb
lib/historical_text_converter/version.rb
lib/historical_text_converter/cli.rb
lib/historical_text_converter/configuration.rb
lib/historical_text_converter/errors.rb

config/default.yml

spec/
```

Additional directories may be created where needed, but they should not contain speculative implementations.

## Implementation Requirements

* Establish the `HistoricalTextConverter` namespace.
* Establish semantic versioning.
* Establish the executable.
* Establish configuration loading.
* Establish the test framework.
* Establish RuboCop.
* Ensure the project can be installed and executed from a clean checkout.
* Keep dependencies minimal.

## Tests

At minimum:

* library loads successfully;
* version is available;
* configuration can be instantiated;
* CLI can execute;
* invalid CLI invocation produces a useful error;
* RSpec executes successfully.

## Acceptance Criteria

The following should work:

```bash
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec bin/historical-text-converter --help
```

All should complete successfully.

## Deliverable

A clean Ruby project skeleton suitable for continued development.

## Stop Condition

Do not begin parsing HTML or implementing transformations during this milestone.

---

# 5. Milestone 2 — Document Model

## Goal

Implement the semantic Document Model.

This is one of the most important milestones in the project.

The Document Model must become independent of:

* HTML;
* Nokogiri;
* RTF;
* DOCX;
* CLI concerns;
* transformation-specific logic.

## Scope

Implement the core objects defined by the architecture:

```text
Book
Metadata
Section
Heading
Paragraph
Quotation
Poem
List
ListItem
Footnote
PageBreak
Inline
Text
Emphasis
Node
```

Per HTC-0014, `Document` is the namespace (`HistoricalTextConverter::Document`),
not a class. A Book's front matter, body, and back matter are `Section`s.

Not every class needs complex behavior initially. The objective is to establish a clean semantic representation.

## Implementation Requirements

The model should support:

* hierarchical structure;
* blocks;
* inline elements;
* metadata;
* parent/child relationships where appropriate;
* traversal;
* text access;
* controlled mutation.

The model should represent meaning rather than source markup.

For example:

```text
HTML <p>
```

should eventually become:

```text
Paragraph
```

rather than remaining an HTML node inside the model.

## Tests

Test:

* object construction;
* child relationships;
* traversal;
* metadata;
* text nodes;
* headings;
* paragraphs;
* quotations;
* footnotes;
* nested structures where applicable.

## Acceptance Criteria

A test can construct a small historical document entirely without HTML:

```text
Book
 ├── Metadata
 └── Body (Section)
      ├── Heading
      ├── Paragraph
      └── Paragraph
```

The model can be traversed and inspected without any parser or writer dependency.

## Deliverable

A stable initial semantic Document Model.

## Stop Condition

Do not add EEBO-specific logic to the Document Model.

---

# 6. Milestone 3 — Parser Interface and EEBO Parser Foundation

## Goal

Create the parser architecture and begin parsing EEBO-TCP TEI XML.

The input is TCP's TEI XML, not the EEBO website's HTML (HTC-0015).

## Scope

Implement the parser interface and an EEBO parser, for example:

```text
parsers/parser.rb
parsers/eebo/parser.rb
parsers/eebo/...   (component files settled in the milestone prompt)
```

The original component list (`extractor`, `structure_detector`,
`artifact_detector`) assumed HTML input; the milestone prompt proposes
the TEI equivalent.

Use Nokogiri for XML parsing, with external entities and network access
disabled.

## Parser Responsibilities

The EEBO parser should:

* load XML safely;
* read metadata from the TEI header;
* map front matter, body, and back matter;
* identify semantic structures;
* create the Document Model;
* preserve source text;
* identify source artifacts where possible.

The parser should **not**:

* modernize spelling;
* Americanize spelling;
* rewrite grammar;
* correct printer errors;
* perform general text cleanup;
* produce RTF;
* produce DOCX.

## Important Principle

Parsing answers:

> “What does this source document contain?”

Transformation answers:

> “What changes should be made to it?”

Those questions must remain separate.

## Tests

Create small TEI fixtures, cut from real TCP texts, representing:

* headings;
* paragraphs;
* emphasis;
* quotations;
* page breaks, including inside paragraphs;
* notes;
* gaps;
* line-end word breaks;
* lists, if present in the sample texts;
* unusual TCP markup;
* malformed or unexpected markup.

## Acceptance Criteria

A representative EEBO-TCP XML file (`spec/fixtures/eebo/A13556.xml`) can
be parsed into a `Book`.

The resulting Book contains semantic elements rather than raw XML nodes.

## Deliverable

An initial working EEBO parser.

## Stop Condition

Do not implement modernization in the parser.

---

# 7. Milestone 4 — TEI Coverage and Source Artifacts

This milestone was originally "Source Isolation and Structural
Extraction": separating the book from the EEBO website. Reading TCP XML
removes that problem (HTC-0015), so the milestone is redirected.

## Goal

Make the EEBO parser reliable across the range of TCP texts, and make it
identify consistently everything in the encoding that is not the
author's text.

## Scope

Broaden TEI coverage using several additional TCP texts chosen to include
structures A13556 lacks, such as:

* verse (`<lg>`, `<l>`);
* lists;
* letters (`<opener>`, `<closer>`, `<salute>`, `<signed>`);
* tables and figures;
* back matter;
* deeply nested divisions;
* extensive non-English text.

Identify source and editorial artifacts, without deciding yet whether
they should be removed:

* illegible-text gaps;
* duplicate-page placeholders;
* transcriber additions (`rendition="simple:additions"`);
* omitted non-Latin text;
* unnumbered page breaks.

## Important Distinction

The parser identifies what exists.

A transformation decides what should happen to it.

For example, a duplicate-page placeholder may be represented and tagged
as a source artifact before a later transformation removes it.

## Tests

Use representative TCP fixtures and test:

* preservation of all text in each fixture;
* each newly supported structure;
* detection of each artifact type;
* handling of page boundaries;
* graceful handling of unrecognized elements (preserve and report, never
  silently drop).

## Acceptance Criteria

The parser handles a varied sample of TCP texts without losing text, and
every non-authorial element it meets is identified as such.

## Deliverable

Broad, tested TEI coverage and consistent artifact identification.

## Stop Condition

Do not combine artifact identification with spelling modernization.

---

# 8. Milestone 5 — Transformation Pipeline and Basic Cleanup

## Goal

Create the transformation framework and implement the first conservative cleanup transformations.

## Scope

Implement:

```text
transformations/transformation.rb
transformations/pipeline.rb
```

Then implement transformations for appropriate cleanup tasks.

Initial transformations should include:

* structural cleanup;
* artifact removal;
* character cleanup;
* word-boundary repair;
* whitespace normalization.

## Required Character Cleanup

The character:

```text
∣
```

must be removable through an explicit transformation.

It should not be silently stripped by the parser or writer.

## Pipeline

The pipeline should own transformation order.

The initial conceptual sequence is:

```text
Structural Cleanup
        ↓
Artifact Removal
        ↓
Character Cleanup
        ↓
Word-Boundary Repair
        ↓
Whitespace Normalization
```

Later transformations will follow these.

## Tests

Test every transformation independently.

For example:

```text
Input:  "the∣book"
Output: "thebook"
```

where that behavior is appropriate to the source representation.

Also test that legitimate characters are not accidentally removed.

Whitespace tests should include:

* repeated spaces;
* line breaks;
* paragraph boundaries;
* indentation;
* whitespace around punctuation;
* whitespace around inline elements.

## Acceptance Criteria

* Transformations can be run independently.
* Transformations can be composed into a pipeline.
* Pipeline order is deterministic.
* The same input produces the same output.
* The transformation framework can later support review logging.

## Deliverable

A working transformation pipeline with basic cleanup.

## Stop Condition

Do not implement spelling modernization yet.

---

# 9. Milestone 6 — Conservative Spelling Modernization

## Goal

Implement the core spelling-modernization engine.

This is the central transformation capability of Historical Text Converter.

## Scope

Implement:

```text
transformations/modernization/
```

or the equivalent structure established during implementation.

The engine should support:

* dictionary-based modernization;
* exceptions;
* protected forms;
* configurable rules;
* review logging;
* deterministic behavior.

## Initial Examples

The system should be capable of handling examples such as:

```text
dayes → days
hee   → he
```

but the implementation must not be limited to these examples.

## Historical Grammar

The modernization engine must not automatically change historical grammar.

Initially protected forms include:

```text
hath
doth
saith
thou
thee
thy
```

These should remain protected unless a future explicit configuration says otherwise.

## Dictionaries

Modernization data should live outside the Ruby implementation where practical.

For example:

```text
config/dictionaries/
```

may contain YAML dictionaries.

The code should provide the engine.

The YAML files should provide the data.

## External Resources

No existing tool produces a conservatively modernized, reviewable edition
from TCP texts (prior-art survey, 2026-10-22), but several resources can
seed this milestone's dictionaries. All of them are aids, not sources of
truth:

* every suggested entry must be reviewed by a person before it enters a
  YAML dictionary;
* no external spelling data is ever applied directly to a text;
* each dictionary entry taken from an external resource should record
  that resource, so its origin stays reviewable;
* each resource's license must be checked before its data is copied into
  this MIT-licensed project.

Candidates:

* **EarlyPrint** (HTC-0015): EEBO-TCP texts with a standard spelling
  (`@reg`) for many words, produced by MorphAdorner. These can be mined
  across texts for candidate entries. They contain errors (A13556
  regularizes "Aldermanbury" to "Aldermanburic") and may modernize
  further than this project's conservative rules allow.
* **MorphAdorner** (Northwestern): the tool behind EarlyPrint's standard
  spellings. Its spelling data may be usable directly. Availability and
  license not yet checked.
* **VARD 2** (Lancaster, `ucrel.lancs.ac.uk/vard`): an Early Modern
  English variant-spelling list and normalization tool. Free for
  non-commercial use only, so its data probably cannot be copied into
  this project; it may still be used to cross-check candidate entries.
* **eMOP word list** (Texas A&M, `emop.tamu.edu/node/97`): about 144,000
  words from the TCP transcriptions combined with VARD's variant list.
  License not yet checked.
* **VEP standardizer dictionary** (UW–Madison,
  `github.com/uwgraphics/VEP-pipeline`, compiled by Deidre Stuffer): a
  standardization dictionary for TCP texts. The repository has been
  inactive since 2017 and states no license.

For scale: Digital Puritan modernizes EEBO texts for readers with a list
of about 3,000 replacements, still reviewed by hand. Their list is not
published.

Neural or AI normalization models are not used to change text: they are
not deterministic and do not produce reviewable rules.

## Tests

Test:

* direct replacements;
* exceptions;
* protected forms;
* capitalization;
* punctuation;
* word boundaries;
* plural forms;
* possessives;
* words embedded in larger words;
* deterministic results;
* idempotence where applicable.

Example:

```text
dayes.
```

should become:

```text
days.
```

while preserving punctuation.

The transformation must not accidentally alter:

```text
dayesomething
```

as though it were the standalone word `dayes`.

## Acceptance Criteria

A configured dictionary can modernize historical spellings without rewriting historical grammar.

The modernization system can be expanded by changing data rather than rewriting transformation code.

## Deliverable

A conservative, test-driven modernization engine.

## Stop Condition

Do not add broad grammatical modernization.

---

# 10. Milestone 7 — Americanization

## Goal

Implement American spelling conversion as a separate transformation.

## Scope

Americanization must be independent of historical spelling modernization.

For example:

```text
labour → labor
```

should be handled by Americanization rather than being mixed into the general modernization engine.

## Design Requirement

A user should theoretically be able to configure:

```text
Modernization: ON
Americanization: OFF
```

or:

```text
Modernization: OFF
Americanization: ON
```

or:

```text
Modernization: ON
Americanization: ON
```

without the two systems becoming inseparable.

## Tests

Test:

* British → American forms;
* capitalization;
* word boundaries;
* exceptions;
* interaction with modernization;
* independent enable/disable behavior.

## Acceptance Criteria

Americanization can be enabled or disabled without changing the behavior of unrelated transformations.

## Deliverable

A separate Americanization transformation and dictionary.

## Stop Condition

Do not turn Americanization into general rewriting.

---

# 11. Milestone 8 — Review Log and Statistics

## Goal

Make transformations transparent and reviewable.

## Scope

Implement:

```text
review/change.rb
review/change_log.rb
review/statistics.rb
```

and appropriate reporters.

## Change Record

A change should be capable of recording information such as:

```text
Transformation
Original
Replacement
Location
Context
Rule
Confidence
```

Not every transformation will necessarily provide every field.

## Requirements

A user should be able to determine:

* what changed;
* which transformation changed it;
* where the change occurred;
* which rule caused it.

## Statistics

The system should eventually be able to report information such as:

```text
Words modernized: 143
British spellings Americanized: 27
Artifacts removed: 81
Character substitutions: 34
```

The exact statistics should follow the actual transformations rather than being fabricated.

## Tests

Test:

* change creation;
* change-log storage;
* ordering;
* statistics;
* serialization/reporting;
* transformations that generate changes;
* transformations that make no changes.

## Acceptance Criteria

A transformation can make a change and produce a corresponding review record.

## Deliverable

A functioning review and statistics subsystem.

## Stop Condition

Do not add elaborate reporting interfaces before the underlying change model is stable.

---

# 12. Milestone 9 — Printer-Error Correction

## Goal

Add a conservative system for known printer/transcription errors.

## Scope

Implement printer-error correction as its own transformation.

It must not be mixed with:

* spelling modernization;
* Americanization;
* parser logic.

## Requirements

Corrections should be:

* explicit;
* dictionary/rule driven where possible;
* conservative;
* testable;
* logged.

The system should never silently invent text.

## Tests

Test:

* known corrections;
* exceptions;
* word boundaries;
* logging;
* incorrect-context rejection;
* deterministic behavior.

## Acceptance Criteria

A known correction can be applied and recorded without introducing speculative corrections.

## Deliverable

A conservative correction transformation.

## External Resources

EarlyPrint (HTC-0015) corrects some TCP readings, including filling some
illegible-text gaps, without marking where it did so. Comparing an
EarlyPrint text with the TCP text it derives from would reveal those
changes, and they could become candidate corrections.

Such candidates are suggestions only: each must be reviewed by a person
before it enters the corrections dictionary, and must be recorded as
EarlyPrint's reading, never presented as the source's.

## Stop Condition

Do not create an AI-based guessing or reconstruction system.

---

# 13. Milestone 10 — RTF Writer

## Goal

Produce high-quality RTF from the semantic Document Model.

RTF is one of the initial production output formats.

## Scope

Implement:

```text
writers/writer.rb
writers/rtf_writer.rb
```

## Requirements

The writer should support the semantic structures actually implemented by the Document Model, including as appropriate:

* titles;
* headings;
* paragraphs;
* quotations;
* emphasis;
* lists;
* footnotes;
* page breaks.

## Important Principle

The writer must consume the Document Model.

It should not parse source markup.

It should not perform modernization.

It should not perform Americanization.

It should not contain historical-text transformation rules.

## Existing Tools to Evaluate First

Before writing RTF and DOCX writers by hand, evaluate existing converters
(prior-art survey, 2026-10-22):

* **pandoc**: converts Markdown and other formats to DOCX and RTF. The
  converter could write Markdown (or another intermediate format) from the
  Book and hand it to pandoc.
* **TEI Stylesheets** (`tei-c.org`): XSLT 2.0 transformations from TEI to
  DOCX, EPUB, and other formats. Requires Saxon (Java). The converter
  would write simple TEI from the Book.
* **TEI Garage / OxGarage**: a conversion service built on the TEI
  Stylesheets, available as a Docker image. The publicly hosted instance
  is not supported for production use.
* **Oxford Text Archive EPUBs**: original-spelling EPUBs of each TCP Phase
  I text. A useful reference for how TCP texts can be laid out, not a
  writer.

Any of these would still consume the Document Model, through an
intermediate format the converter writes. Each adds an external
dependency, which the architecture asks to keep minimal, so adopting one
requires a decision log entry weighing output quality and control over
footnotes, page breaks, and Unicode against that cost.

## RTF Escaping

RTF-specific escaping should be centralized.

Special characters must be handled safely.

Unicode text must remain readable in the resulting document.

## Tests

Tests should verify:

* valid RTF structure;
* escaping;
* paragraphs;
* emphasis;
* headings;
* Unicode;
* page breaks;
* footnotes where supported.

Where practical, output should also be validated by opening it in a real RTF-compatible application.

## Acceptance Criteria

A parsed and transformed Book can be written as an RTF document that preserves its semantic structure and readable formatting.

## Deliverable

Production-quality initial RTF output.

---

# 14. Milestone 11 — DOCX Writer

## Goal

Add DOCX as the second major production output format.

## Scope

Implement:

```text
writers/docx_writer.rb
```

using the selected Ruby DOCX library or a deliberately chosen alternative.

The dependency should be evaluated rather than adopted merely because it is popular.

The existing converters listed under Milestone 10 (pandoc, TEI
Stylesheets, TEI Garage) are alternatives to evaluate here as well.

## Requirements

The DOCX writer must consume the Document Model.

It must not depend on:

* source markup;
* transformation classes;
* source-specific cleanup logic.

## Tests

Test:

* paragraphs;
* headings;
* emphasis;
* quotations;
* lists;
* footnotes where supported;
* page breaks;
* Unicode;
* metadata where applicable.

## Acceptance Criteria

The same semantic Book can be sent to either:

```text
RTF Writer
```

or:

```text
DOCX Writer
```

without changing the Book or transformation pipeline.

## Deliverable

A functioning DOCX production writer.

---

# 15. Milestone 12 — End-to-End Pipeline

## Goal

Connect the complete application flow.

The canonical data flow should now be:

```text
EEBO-TCP XML
    ↓
EEBO Parser
    ↓
Document Model
    ↓
Transformation Pipeline
    ↓
Review / Statistics
    ↓
Writer
    ↓
RTF / DOCX
```

## Scope

Connect:

* CLI;
* configuration;
* parser;
* Document Model;
* transformations;
* review logging;
* writers.

## CLI Requirements

The CLI should support the architecture-defined concepts, including:

```text
input
output
format
config
profile
report
```

Exact command-line syntax should be established during implementation and documented.

## Example Conceptual Invocation

```bash
historical-text-converter \
  --input source.xml \
  --output book.rtf \
  --format rtf \
  --profile conservative
```

This is illustrative; the final CLI syntax should be determined by the implementation.

## Tests

Create an end-to-end fixture that exercises:

* XML parsing;
* artifact identification;
* artifact removal;
* `∣` removal;
* whitespace cleanup;
* modernization;
* Americanization;
* review logging;
* output generation.

## Acceptance Criteria

A single command can transform a supported EEBO-TCP XML source into a finished RTF or DOCX document.

---

# 16. Milestone 13 — Regression Corpus

## Goal

Establish a permanent collection of historical-text fixtures that protects the project against regressions.

## Scope

Create a fixture corpus representing real problems encountered during development.

The corpus should include examples of:

* EEBO markup;
* page markers;
* transcription artifacts;
* `∣`;
* antiquated spellings;
* protected historical grammar;
* British spellings;
* punctuation;
* quotations;
* footnotes;
* headings;
* unusual formatting;
* malformed source structures;
* known printer errors.

## Rule

Every significant bug discovered during development should result in a regression test.

The desired development cycle is:

```text
Bug discovered
      ↓
Minimal reproduction
      ↓
Regression fixture
      ↓
Test
      ↓
Code fix
      ↓
Green test suite
```

## Acceptance Criteria

Previously solved problems remain solved after subsequent changes.

## Deliverable

A growing historical-text regression corpus.

---

# 17. Milestone 14 — Profiles and Configuration

## Goal

Make the converter practical for different users and projects.

## Initial Profiles

The architecture proposes:

```text
scholarly
conservative
modern_reader
custom
```

These should not be implemented until the underlying transformations are stable.

## Requirements

Profiles should determine configuration rather than contain separate transformation implementations.

For example:

```yaml
modernization: true
americanization: false
printer_correction: false
```

could represent a particular profile.

## Important Principle

Profiles configure the same engine.

They should not create parallel code paths.

## Acceptance Criteria

A user can select a profile and receive the corresponding transformation configuration.

Custom configuration should be possible without modifying Ruby source code.

---

# 18. Milestone 15 — Documentation and User Experience

## Goal

Make the project understandable to someone who did not build it.

## Documentation

Complete or improve:

```text
README.md
CHANGELOG.md
docs/
```

Documentation should explain:

* what HTC does;
* what it does not do;
* installation;
* CLI usage;
* configuration;
* profiles;
* supported input;
* supported output;
* modernization philosophy;
* Americanization;
* review reports;
* limitations;
* development;
* testing;
* contribution.

## Historical Integrity Documentation

The documentation should explicitly explain that HTC:

* preserves meaning;
* preserves historical grammar by default;
* does not rewrite theological or literary ideas;
* uses conservative spelling modernization;
* does not invent missing text;
* records important transformations.

---

# 19. Milestone 16 — Release Preparation

## Goal

Prepare the project for an initial public-quality release.

## Scope

Review:

* dependencies;
* security;
* performance;
* error handling;
* documentation;
* CLI behavior;
* test coverage;
* output quality;
* configuration;
* versioning.

## Security Review

Verify that:

* untrusted source markup is handled safely, including XML external entities;
* JavaScript is not executed;
* arbitrary shell commands are not executed;
* output paths are controlled;
* generated documents are properly escaped;
* malformed source cannot cause uncontrolled behavior.

## Performance Review

Measure:

* parsing time;
* transformation time;
* memory usage;
* output generation time.

Do not optimize prematurely.

Optimization should address measured problems.

## Acceptance Criteria

A clean checkout can be used to:

1. install dependencies;
2. run the tests;
3. run the CLI;
4. process a supported EEBO document;
5. generate RTF;
6. generate DOCX;
7. inspect the review report.

---

# 20. Development Order Summary

The recommended implementation sequence is:

```text
01  Project Foundation
        ↓
02  Document Model
        ↓
03  Parser Interface / EEBO Parser
        ↓
04  Source Isolation
        ↓
05  Transformation Pipeline / Cleanup
        ↓
06  Conservative Modernization
        ↓
07  Americanization
        ↓
08  Review / Statistics
        ↓
09  Printer-Error Correction
        ↓
10  RTF Writer
        ↓
11  DOCX Writer
        ↓
12  End-to-End Pipeline
        ↓
13  Regression Corpus
        ↓
14  Profiles / Configuration
        ↓
15  Documentation
        ↓
16  Release Preparation
```

This order is intentional.

In particular:

* the Document Model precedes sophisticated transformations;
* parsing precedes transformation;
* transformations precede writers;
* reviewability is built into the system rather than bolted on afterward;
* profiles come after the underlying configuration system is proven;
* optimization comes after correctness.

---

# 21. Separate Session Development Protocol

Each milestone may be implemented in a separate Claude Code session.

The detailed rules for these sessions are in `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md`. `CLAUDE.md` is loaded automatically and points Claude to the governing documents:

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md
02_DEVELOPMENT_ROADMAP.md
```

Then provide the following instruction:

> You are implementing Milestone [NUMBER] of Historical Text Converter.
>
> Read and obey the project constitution, glossary, decision log, architectural principles, architecture document, and development roadmap before making changes.
>
> Implement only the scope of this milestone.
>
> Do not silently redesign the architecture.
>
> If an architectural change appears necessary, stop and explain the conflict before implementing it. If the change is approved, record it in the decision log.
>
> Keep the project runnable.
>
> Add tests for all new behavior.
>
> Do not remove existing tests merely to make the suite pass.
>
> Do not implement future milestones prematurely.
>
> At the end, report:
>
> 1. files created;
> 2. files modified;
> 3. functionality implemented;
> 4. tests added;
> 5. tests run and their results;
> 6. architectural decisions made;
> 7. unresolved issues;
> 8. recommended next step.

This protocol should be reused for every milestone.

---

# 22. Git Protocol

Development should be committed in logical units.

At minimum, each completed milestone should result in a commit.

Recommended pattern:

```text
milestone-01-project-foundation
milestone-02-document-model
milestone-03-eebo-parser
milestone-04-source-isolation
...
```

Commit messages may use a more conventional style, such as:

```text
feat: establish project foundation
feat: add semantic document model
feat: add EEBO parser
feat: add source isolation
feat: add transformation pipeline
```

The exact Git workflow is secondary to the important principle:

> Every milestone should have a recoverable, known-good state.

---

# 23. Rules for Architectural Changes

During implementation, unexpected problems will arise.

When a developer or Claude discovers that the current architecture is inadequate, it should **not silently change the architecture**.

Instead:

1. Identify the problem.
2. Explain why the current design is insufficient.
3. Propose one or more alternatives.
4. Identify consequences.
5. Obtain a decision.
6. Record the decision in `00b_DECISION_LOG.md`.
7. Update affected architectural documentation.
8. Implement the approved change.
9. Add tests protecting the new behavior.

This keeps the project history understandable.

---

# 24. Definition of Done

A milestone is not complete merely because the new code works in one example.

A milestone is complete when:

* the intended functionality exists;
* the code follows the architecture;
* relevant tests exist;
* existing tests still pass;
* RuboCop passes unless an intentional documented exception exists;
* the implementation does not unnecessarily anticipate later milestones;
* documentation has been updated where appropriate;
* errors are handled appropriately;
* the behavior is deterministic;
* the implementation is understandable;
* the acceptance criteria are satisfied.

---

# 25. Definition of a Stable Release

Historical Text Converter should eventually satisfy the following:

### Input

A supported EEBO-TCP XML document can be processed reliably.

### Parsing

Source and editorial artifacts are identified rather than silently kept or discarded.

### Structure

The source becomes a semantic Document Model.

### Cleanup

Known source artifacts and unwanted transcription characters can be removed explicitly.

### Modernization

Historical spelling can be conservatively modernized.

### Grammar

Historical grammar remains preserved by default.

### Americanization

British spelling can independently be converted to American spelling.

### Corrections

Known printer/transcription errors can be corrected conservatively and transparently.

### Reviewability

Transformations can produce a review/change log.

### Output

The same semantic document can be rendered to multiple formats.

### Configuration

Users can select profiles and configure transformations.

### Reproducibility

The same source, configuration, and application version produce deterministic results.

### Testing

Real historical-text fixtures protect against regressions.

### Documentation

A new developer can understand the architecture and a user can understand how to operate the converter.

---

# 26. Long-Term Expansion

Features outside the initial release should be considered only after the core architecture is stable.

Possible future work includes:

* additional historical-text sources;
* additional output formats;
* additional dictionaries;
* more sophisticated context-sensitive spelling rules;
* improved footnote handling;
* richer metadata;
* scholarly markup;
* TEI-related workflows;
* configurable editorial conventions;
* user-defined transformation rules;
* additional review/report formats.

Future functionality should extend the architecture rather than undermine it.

The project should resist feature growth that turns Historical Text Converter into an uncontrolled general-purpose rewriting system.

---

# 27. Guiding Development Question

Whenever a new feature is proposed, ask:

> **Does this feature help us convert historical text while preserving its meaning, structure, historical character, and scholarly integrity?**

If yes, determine where it belongs in the architecture.

If no, it probably does not belong in Historical Text Converter.

---

# 28. Final Development Principle

The objective is not merely to make the converter work.

The objective is to make it **trustworthy**.

A successful Historical Text Converter should allow a user to look at an output document and reasonably understand:

* where the text came from;
* what structure was detected;
* what was removed;
* what was modernized;
* what was Americanized;
* what was corrected;
* which rules caused those changes;
* and what remains intentionally historical.

The implementation should therefore favor:

```text
Correctness
    ↓
Transparency
    ↓
Testability
    ↓
Maintainability
    ↓
Extensibility
```

rather than short-term convenience.

The ultimate development goal is:

> **Build a deterministic, conservative, reviewable historical-text conversion system whose architecture can survive decades of additional sources, rules, formats, and editorial requirements.**
