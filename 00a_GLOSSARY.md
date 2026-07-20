# Historical Text Converter
## Glossary
Version: 1.0

---

# Purpose

This glossary defines the project's terminology.

All documentation, source code, tests, and prompts shall use these
definitions consistently.

---

# Artifact

Any non-original content produced by a parser or transcription rather
than by the historical author.

Examples include:

• page markers
• website navigation
• HTML menus
• OCR confidence values
• transcription metadata

Artifacts are removed by transformations.

---

# Americanization

The process of converting British spellings to American spellings.

Examples:
- labour → labor
- honour → honor
- colour → color

Americanization is independent of spelling modernization.

---

# Block

A semantic document element.

Examples:
- Paragraph
- Heading
- Quotation
- Poem
- Table
- Illustration
- Footnote

Every block is represented by its own Ruby object.

---

# Book

The root object of the internal document model.

A Book contains:
- Front Matter
- Body
- Back Matter
- Metadata

---

# Configuration

A YAML file describing which transformations are enabled and how they
behave.

Configuration changes behavior without modifying source code.

---

# Conservative Modernization

The default modernization profile.

Characteristics:

• modern spelling

• preserve historical grammar

• preserve sentence structure

• preserve author's vocabulary

Examples:
- hee → he
- dayes → days
- hath → hath
- thou → thou

---

# Context Rule

A transformation rule that depends on neighboring words or document
structure.

Example:
- Replace "hee" only when it is a complete word.

---

# Dictionary

A human-editable collection of transformation mappings.

Examples:
- hee:
  - modern: he
- publique:
  - modern: public

Dictionaries are data, not code.

---

# Document Model

The semantic representation of a document.

The Document Model contains no HTML.

It contains objects representing the meaning of the document.

---

# Footnote

An authorial or editorial note associated with a location in the text.

Footnotes are represented separately from paragraphs.

---

# Front Matter

Material before the primary body of the work.

Examples:
- Title page
- Dedication
- Preface
- Table of Contents
- Introduction

---

# Historical Grammar

The grammatical forms used by the original author.

Examples:
- hath
- doth
- saith
- thou
- thy

Historical grammar is preserved unless explicitly configured otherwise.

---

# Modernization

Updating spelling or typography while preserving meaning.

Modernization does NOT rewrite the author's ideas.

---

# Parser

A component that converts an external source into the Document Model.

Examples:
- EEBO Parser
- ECCO Parser
- Project Gutenberg Parser

---

# Pipeline

The ordered sequence of processing stages.

Input

↓

Parser

↓

Document Model

↓

Transformations

↓

Writer

↓

Output

---

# Profile

A named collection of configuration settings.

Examples:
- scholarly
- conservative
- modern_reader

---

# Review Log

A record describing every transformation applied to a document.

The review log may be exported as:
- Text
- CSV
- JSON
- HTML

---

# Rule

A single transformation definition.

Every rule performs exactly one operation.

---

# Semantic Element

A document object representing meaning rather than appearance.

Examples:
- Heading
- Paragraph
- Quotation
- Footnote
- List

---

# Source Document

The original input supplied to the parser.

Examples:
- HTML
- XML
- Plain text
- Markdown
- OCR

---

# Transformation

A single operation performed on the Document Model.

Examples:
- RemovePageMarker
- RepairBrokenWord
- ModernizeSpelling
- AmericanizeSpelling
- NormalizeWhitespace

Every transformation has one responsibility.

---

# Transformation Pipeline

The ordered collection of transformations applied to a document.

Each transformation operates independently.

---

# Writer

A component that converts the Document Model into an output format.

Examples:
- DOCX Writer
- RTF Writer
- Markdown Writer
- HTML Writer

---

# Workspace

The collection of files used while processing one document.

May include:
- temporary files
- logs
- reports
- generated output

No workspace files become part of the source document.
