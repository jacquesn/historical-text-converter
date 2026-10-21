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
