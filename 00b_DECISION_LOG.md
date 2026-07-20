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
