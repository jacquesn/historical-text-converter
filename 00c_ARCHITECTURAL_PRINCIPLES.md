# Historical Text Converter
## Architectural Principles
Version: 1.0

---

# Purpose

This document describes the architectural philosophy of Historical Text
Converter.

Unlike the Constitution, which establishes immutable project rules, these
principles explain how architectural decisions should be evaluated.

Future contributors should understand these principles before introducing
new features or modifying existing ones.

---

# Principle 1
## The Document Model Is Sacred

The Document Model is the heart of the application.

Everything else exists to create it, transform it, or serialize it.

The Document Model shall never contain HTML.

The Document Model shall never contain parser-specific objects.

The Document Model shall never contain writer-specific objects.

Every transformation operates on the Document Model.

Every writer consumes the Document Model.

Protecting the purity of the Document Model is the project's highest
architectural priority.

---

# Principle 2
## Parse Once

HTML should be parsed exactly once.

After parsing, no code should inspect HTML again.

Every parser converts source documents into the Document Model.

Every subsequent stage operates only on semantic objects.

This prevents parser logic from leaking into transformations.

---

# Principle 3
## Semantic First

The application understands meaning before appearance.

A Heading is not merely large text.

A Footnote is not merely smaller text.

A Quotation is not merely indented text.

Formatting represents semantics rather than visual styling.

---

# Principle 4
## Composition Over Inheritance

Favor small collaborating objects.

Avoid deep inheritance hierarchies.

If behavior can be composed, compose it.

Inheritance should be reserved for genuinely substitutable types.

---

# Principle 5
## One Reason To Change

Every class should have one responsibility.

Every transformation performs one task.

Every parser performs one task.

Every writer performs one task.

When a class has multiple reasons to change, split it.

---

# Principle 6
## Data Beats Code

Transformation rules belong in data whenever practical.

Prefer over Ruby source code:
- YAML
- JSON
- configuration
- dictionaries

The application should become more capable by adding data rather than
modifying algorithms.

---

# Principle 7
## Explicit Beats Implicit

Hidden behavior is discouraged.

Every transformation should be named.

Every configurable behavior should appear in configuration.

Every automatic decision should be explainable.

---

# Principle 8
## Preserve Information

Never throw information away unless intentionally removing an artifact.

If information cannot yet be represented,
preserve it until a suitable representation exists.

Lossless processing is preferred.

---

# Principle 9
## Idempotence

Running the same transformation twice should produce the same result as
running it once whenever possible.

Repeated processing should not continue changing the document.

---

# Principle 10
## Determinism

The same input and configuration shall always produce the same output.

Avoid hidden randomness.

Avoid dependence upon execution order unless explicitly documented.

---

# Principle 11
## Transformations Are Independent

Transformations should not know about each other.

Each receives a document.

Each returns a document.

Ordering belongs to the pipeline, not the transformations.

---

# Principle 12
## Minimize Side Effects

Transformations should avoid mutating unrelated objects.

Prefer returning modified objects over changing global state.

Side effects complicate testing.

---

# Principle 13
## Public APIs Are Stable

Public interfaces should change slowly.

Internal implementations may evolve.

Users should rarely need to modify their workflows when upgrading.

---

# Principle 14
## Small Objects

Classes should remain small.

Methods should remain short.

Objects should represent concepts rather than utility collections.

Large "God classes" are prohibited.

---

# Principle 15
## Favor Readability

Historical Text Converter is expected to live for many years.

Readable code is more valuable than clever code.

Future maintainers should understand the system quickly.

---

# Principle 16
## Every Change Is Reviewable

Users should be able to discover:
- what changed
- where
- why
- which transformation performed it

Every automatic modification should be traceable.

---

# Principle 17
## Errors Should Educate

Error messages should explain:
- what happened
- why
- how to fix it

Avoid cryptic exceptions whenever practical.

---

# Principle 18
## Testing Is Part Of Design

A feature that cannot be tested is usually poorly designed.

Design for testability.

Favor dependency injection.

Avoid hidden dependencies.

---

# Principle 19
## Progressive Complexity

The simplest solution that satisfies today's requirements should be
preferred.

Do not introduce abstraction solely because it may someday be useful.

However, extension points anticipated by the Constitution should remain
available.

---

# Principle 20
## Prefer Extension To Modification

New capabilities should usually be added by introducing new parsers,
writers, transformations, or dictionaries.

Existing code should rarely require modification.

This follows the Open/Closed Principle.

---

# Principle 21
## The Pipeline Owns Workflow

Individual transformations never decide execution order.

The pipeline defines:
- which transformations run
- their order
- their configuration

Transformations remain reusable.

---

# Principle 22
## Configuration Is A User Interface

Configuration files are part of the application's public interface.

They should be:
- human-readable
- well documented
- stable
- backward compatible whenever practical.

---

# Principle 23
## Every Dependency Has A Cost

Adding a gem increases:
- maintenance
- security surface
- upgrade complexity
- startup time

Only introduce dependencies that provide substantial value.

---

# Principle 24
## Performance Follows Correctness

Correct output is more important than fast output.

Once correctness is established,
optimize measurable bottlenecks.

Never sacrifice clarity for speculative performance.

---

# Principle 25
## Historical Integrity

The software modernizes presentation.

It does not modernize ideas.

It does not rewrite history.

It does not reinterpret authors.

Its purpose is to reduce barriers to reading while preserving the
author's voice.

---

# Principle 26
## The User Is In Control

Users choose:
- profiles
- transformations
- writers
- logging
- review reports

The application should provide excellent defaults while remaining highly
configurable.

---

# Principle 27
## Documentation Is Code

Architecture documentation is part of the project.

When architecture changes,
documentation changes first or simultaneously.

Outdated documentation is considered a bug.

---

# Principle 28
## Build For Decades

Assume this project will still be useful ten years from now.

Choose names, abstractions, and interfaces that will age well.

Avoid fashionable patterns that reduce long-term clarity.

---

# Final Principle

Historical Text Converter exists to make historical texts more accessible
without compromising their integrity.

Whenever two design options appear equally attractive,
choose the one that best preserves meaning,
improves maintainability,
and keeps the architecture simple.
