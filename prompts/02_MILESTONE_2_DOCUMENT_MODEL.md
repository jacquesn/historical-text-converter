# Milestone 2 — Document Model

## Repository

`https://github.com/jacquesn/historical-text-converter`

Follow `prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md`.

## Governing Documents

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md          (especially HTC-0014)
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md           (§8–13, §44–45)
02_DEVELOPMENT_ROADMAP.md    (§5)
```

## Objective

Implement the semantic Document Model: the representation of a historical
work that parsers produce, transformations change, and writers consume.
It must be independent of HTML, Nokogiri, output formats, the CLI, and any
particular transformation.

## Current Scope

The classes listed in roadmap §5, in the shape fixed by HTC-0014:

* `Book` with `metadata`, `front_matter`, `body`, `back_matter`;
* `Metadata`;
* `Node`, with `Block` and `Inline` bases;
* blocks: `Section`, `Heading`, `Paragraph`, `Quotation`, `Poem`, `List`,
  `ListItem`, `Footnote`;
* inlines: `Text`, `Emphasis`;
* `PageBreak`, permitted in both block and inline content.

## Required Files

```text
lib/historical_text_converter/document.rb
lib/historical_text_converter/document/*.rb   (one file per class)
lib/historical_text_converter/errors.rb       (add DocumentError)
lib/historical_text_converter.rb              (require document)
spec/historical_text_converter/document_spec.rb
spec/historical_text_converter/document/*_spec.rb
```

Specs mirror `lib/`, as in Milestone 1 and as rubocop-rspec expects.

## Implementation Requirements

* Nodes are immutable. Copies are made with `with` and `rewrite`;
  unchanged subtrees are reused.
* Nodes expose `children`, `metadata`, `text`, and depth-first traversal
  (`each`, via `Enumerable`, and `each_with_ancestors`).
* Constructors reject children a node may not contain, raising
  `DocumentError`.
* Nodes compare by class and attributes.
* Formatting is represented by nodes (`Emphasis`), never by markup in text.

## Tests

Construction, child relationships, traversal, metadata, text nodes,
headings, paragraphs, quotations, footnotes, nested structures, and the
acceptance criterion below.

## Acceptance Criteria

A test constructs a small historical document without HTML, then traverses
and inspects it:

```text
Book
 ├── Metadata
 └── Body (Section)
      ├── Heading
      ├── Paragraph
      └── Paragraph
```

`bundle exec rspec` and `bundle exec rubocop` pass.

## Out of Scope

* EEBO-specific logic of any kind (Milestone 2 stop condition);
* parsers, transformations, writers;
* full validation (architecture §44) beyond constructor type checks;
* footnote references, line and stanza structure, and further inline
  elements, until a source requires them.

## Final Report

As in protocol §21.
