# Historical Text Converter

## Claude Development Session Protocol

**Project:** Historical Text Converter
**Repository:** `https://github.com/jacquesn/historical-text-converter`
**Purpose:** Standard protocol for Claude Code development sessions

---

# 1. Purpose

This document defines how Claude should participate in the development of **Historical Text Converter (HTC)**.

Claude is used through **Claude Code**, working directly in a local clone of the repository.

Claude may read, create, modify, and delete files in the working tree, and may run the project's commands and tests.

The human developer controls Git: Claude does not commit, push, create branches, or open pull requests unless explicitly asked.

The standard workflow is:

```text
Local repository
       ↓
Claude reads governing documents and code
       ↓
Claude reports current state and proposes a plan
       ↓
Human developer approves the plan
       ↓
Claude edits files
       ↓
Claude runs tests, lint, and the CLI
       ↓
Claude fixes failures and reruns
       ↓
Claude reports results
       ↓
Human developer reviews the diff and commits
```

---

# 2. Repository

The canonical source repository is:

`https://github.com/jacquesn/historical-text-converter`

The repository should be treated as the **current implementation state** of the project.

The project documents describe the intended architecture and development plan.

Therefore:

```text
Repository
    = current implementation

Project documents
    = governing design
```

Do not assume that the repository and project documents are already identical.

Part of each development session is determining whether they agree.

---

# 3. Governing Documents

Before implementing a milestone, Claude should read the following documents:

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md
02_DEVELOPMENT_ROADMAP.md
```

Also read:

```text
prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md
```

and the prompt for the specific milestone being implemented.

`CLAUDE.md` is loaded automatically at the start of each session. It holds the current project state and points back to these documents; it does not replace them.

The governing documents take precedence over assumptions based on general Ruby conventions.

However, the actual repository is authoritative regarding what code currently exists.

---

# 4. Repository Permissions

Claude **may**:

* create, modify, and delete files in the working tree;
* run `bundle`, `rspec`, `rubocop`, the CLI, and similar local commands;
* run read-only Git commands such as `git status`, `git diff`, and `git log`;
* stage renames with `git mv` so file history is preserved.

Claude **must not**, unless the human developer explicitly asks in the current session:

* commit changes;
* create or switch branches;
* push commits;
* open pull requests;
* modify GitHub settings, issues, or releases;
* rewrite Git history.

Permission given for one of these actions does not carry over to later actions or later sessions.

---

# 5. Reporting Code Changes

Claude makes changes directly, so it does not need to reproduce complete file contents in the conversation.

Instead, when reporting changes, list every affected file by its exact repository-relative path:

```text
Created:
lib/historical_text_converter/version.rb

Modified:
lib/historical_text_converter.rb

Deleted:
spec/spec/
```

The human developer reviews the actual changes with `git diff`.

---

# 6. Keep Changes Reviewable

Because the human developer reviews every change before committing, keep diffs focused:

* change only what the current task requires;
* do not reformat unrelated code;
* do not mix refactoring with new behavior unless the milestone calls for it;
* explain any change whose purpose is not obvious from the diff.

---

# 7. Inspect Before Designing

Before proposing implementation changes, inspect the current repository.

Determine:

- which files already exist;
- which directories already exist;
- what code has already been implemented;
- what tests already exist;
- how the current code is organized;
- what dependencies are already present;
- what commands are already available;
- whether the current implementation differs from the architecture documents.

Do not create a file that already exists without first inspecting it.

Do not assume the repository is empty.

---

# 8. Establish the Current State First

At the beginning of a milestone, report a concise assessment such as:

```text
Current repository state:

- Existing files:
- Existing architecture:
- Existing tests:
- Existing dependencies:
- Relevant implementation already present:
- Differences from governing documents:
- Milestone work remaining:
```

Then propose the implementation plan and wait for the human developer to approve it before making substantial changes.

Do not immediately start generating large amounts of code.

---

# 9. Milestone Discipline

Implement **one milestone at a time**.

The current milestone prompt determines the scope of work.

Do not implement later milestones merely because you notice that they will eventually be necessary.

For example, during Milestone 1:

Do not implement:

* the Document Model;
* EEBO parsing;
* spelling modernization;
* Americanization;
* RTF generation;
* DOCX generation.

If something from a future milestone is necessary for the current milestone, explain why before implementing it.

---

# 10. Do Not Silently Change the Architecture

The following documents define the intended architecture:

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md
```

If the current repository makes those plans difficult to implement, identify the discrepancy.

Do not silently redesign the system.

Instead, explain:

1. what the existing architecture does;
2. what the governing documents specify;
3. what conflict exists;
4. what options are available;
5. what you recommend and why.

If a genuine architectural decision is required, stop and ask the human developer to decide.

Once a decision is made, record it in:

```text
00b_DECISION_LOG.md
```

and update affected documentation.

---

# 11. Do Not Invent Requirements

Do not introduce features merely because they are common in other software projects.

For example, do not add:

* databases;
* web interfaces;
* background jobs;
* AI services;
* cloud services;
* unnecessary frameworks;
* elaborate plugin systems;
* unnecessary abstractions;
* unnecessary dependencies.

Using Claude to develop HTC does not make HTC an AI application. The converter itself must not call Claude or any other AI service unless a recorded architectural decision says otherwise.

The project is intended to remain:

* deterministic;
* understandable;
* maintainable;
* testable;
* conservative;
* suitable for long-term use.

---

# 12. Ruby Standards

The project is written in Ruby.

Prefer conventional, readable Ruby.

Favor:

* small classes;
* small methods;
* explicit dependencies;
* clear names;
* simple control flow;
* composition;
* focused responsibilities;
* testable behavior.

Avoid:

* unnecessary metaprogramming;
* clever abstractions;
* excessive inheritance;
* global mutable state;
* magic behavior;
* unnecessary DSLs;
* premature optimization.

The code should be understandable to a competent Ruby developer who did not write it.

---

# 13. Testing

Every new behavior should have appropriate tests.

When writing code, also write the tests required for that code.

Tests should be written using the project's established testing framework.

For each new behavior, report:

```text
Test file:
spec/...

Tests added:
- ...
- ...
- ...
```

Do not remove existing tests merely to make a new implementation pass.

If an existing test conflicts with the intended architecture, explain the conflict rather than deleting the test.

---

# 14. Running Commands

Claude runs the project's commands itself:

```bash
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec bin/historical-text-converter --help
```

Report results exactly as observed.

Do not claim that a command passed unless Claude ran it and saw it pass in this session.

If a command could not be run (for example, a missing Ruby version or network access), say so, explain why, and give the human developer the command to run themselves.

---

# 15. Verification Loop

The normal development loop is:

```text
Claude implements a change
        ↓
Claude runs tests and lint
        ↓
Claude reads the actual output
        ↓
Claude diagnoses failures
        ↓
Claude applies the smallest correction
        ↓
Claude runs tests again
```

Repeat until the suite and lint pass, or until a failure needs a decision from the human developer.

When diagnosing a failure, use the actual error output.

Do not guess at the error when the output is available to read.

---

# 16. File Path Discipline

Always use repository-relative paths.

Good:

```text
lib/historical_text_converter/configuration.rb
```

Avoid vague descriptions such as:

> “the configuration file”

When multiple files are involved, list them explicitly:

```text
Created:
lib/...

Modified:
lib/...

Created:
spec/...
```

---

# 17. Dependency Discipline

Before adding a new dependency:

1. determine whether the project already has an appropriate dependency;
2. determine whether the functionality can reasonably be implemented using the Ruby standard library;
3. consider the dependency's maintenance and complexity cost;
4. explain why the dependency is needed.

Do not add dependencies casually. Ask the human developer before adding a new gem.

The architecture explicitly values minimal dependency costs.

---

# 18. Historical-Text Integrity

Remember that HTC is not intended to be a general rewriting system.

The core objective is:

> Convert historical texts into clean, readable modern editions while preserving structure, meaning, historical character, and scholarly integrity.

Therefore, do not introduce changes that:

* rewrite ideas;
* rewrite theology;
* modernize grammar without explicit authorization;
* silently correct uncertain readings;
* invent missing text;
* change meaning;
* remove historically meaningful material merely because it appears unusual.

Historical grammar is preserved by default.

Spelling modernization and Americanization are separate concerns.

---

# 19. Determinism

Prefer deterministic implementations.

Given the same:

```text
source
configuration
dictionary/rules
application version
```

the converter should produce the same result.

Do not introduce nondeterministic behavior without a compelling reason.

---

# 20. Transformation Boundaries

When future milestones involve transformations, keep them independent.

For example:

```text
Spelling Modernization
```

should not secretly perform:

```text
Americanization
```

and:

```text
Americanization
```

should not secretly perform:

```text
Grammar Modernization
```

Each transformation should have one clear responsibility.

---

# 21. Output Requirements for Each Milestone

At the end of each implementation session, report:

## Summary

A concise description of what now exists.

## Files Created, Modified, and Deleted

Complete lists, by repository-relative path.

## Tests

The tests added, by file.

## Commands Run and Results

Each command Claude ran and its actual result.

List separately any command that should be run but was not, and why.

## Architectural Decisions

Any decisions made, and whether `00b_DECISION_LOG.md` was updated.

## Unresolved Issues

Anything left incomplete or uncertain.

## Manual Verification

If appropriate, checks the human developer should perform.

## Suggested Commit

A suggested commit message. Do not commit unless asked.

## Next Step

Identify the next milestone, but do not implement it.

---

# 22. When Something Goes Wrong

If a command fails, or the human developer reports a problem:

1. Read the complete error message.
2. Identify the relevant file and line.
3. Determine whether the problem is:

   * implementation;
   * environment;
   * dependency;
   * test;
   * architecture;
   * misunderstanding.
4. Explain the cause.
5. Apply the smallest appropriate correction.
6. Rerun the failing command and confirm the fix.

Do not respond with a completely new architecture unless the evidence actually requires one.

If the cause is environmental (for example, a missing Ruby version), explain what the human developer needs to install or configure rather than working around it in code.

---

# 23. Git Guidance

The human developer controls Git.

Claude may run read-only commands:

```bash
git status
git diff
git log
```

Claude does not run `git add`, `git commit`, `git push`, or branch commands unless explicitly asked.

After a successful milestone, suggest a logical commit.

For example:

```text
Suggested commit message:

feat: establish project foundation
```

The human developer will decide whether and when to commit.

---

# 24. Session Continuity

Every new Claude session should assume that the repository may have changed since the previous session.

Therefore:

**Always inspect the current repository state before proposing changes.**

Do not rely solely on what an earlier session said the repository contained, including the "Current state" section of `CLAUDE.md`. Verify it against the code.

The repository is the current implementation record.

The project documents are the current design record.

At the end of a session, update the "Current state" section of `CLAUDE.md` so the next session starts from an accurate summary.

---

# 25. Prompt Files

Prompts for individual development sessions should be stored in:

```text
prompts/
```

Use descriptive filenames such as:

```text
prompts/00_CLAUDE_DEVELOPMENT_PROTOCOL.md
prompts/01_MILESTONE_1_PROJECT_FOUNDATION.md
prompts/02_MILESTONE_2_DOCUMENT_MODEL.md
prompts/03_MILESTONE_3_EEBO_PARSER.md
```

The numbering should correspond to the development roadmap where practical.

Each milestone prompt should reference this protocol rather than duplicating all of its rules.

---

# 26. Standard Milestone Prompt Structure

Each milestone prompt should contain:

```text
# Milestone [number] — [name]

## Repository

[GitHub repository URL]

## Governing Documents

[list]

## Objective

[what this milestone accomplishes]

## Current Scope

[what should be implemented]

## Required Files

[files to create/modify]

## Implementation Requirements

[detailed requirements]

## Tests

[required tests]

## Acceptance Criteria

[definition of done]

## Out of Scope

[future functionality that must not be implemented]

## Final Report

[required reporting format]
```

---

# 27. Plan Before Implementing

Claude should distinguish between:

### Planning

Assessing the current state and proposing what should be done.

### Implementation

Making the approved changes in the working tree.

### Verification

Running commands and analyzing their actual output.

For any non-trivial milestone, present the plan and wait for approval before implementing it. Small, clearly scoped fixes within an approved plan do not need separate approval.

---

# 28. No Hidden Work

Report every change Claude made, including incidental ones such as deleted directories or fixed lint warnings.

Do not say:

> “I've made the changes.”

unless the changes were actually made.

Do not say:

> “The tests pass.”

unless Claude ran them and saw them pass.

---

# 29. Definition of Success

A successful Claude development session should leave the human developer with:

1. a working tree containing the milestone's changes;
2. a clear account of what changed and why;
3. tests for all new behavior;
4. the actual results of running the test suite and lint;
5. any necessary architectural decisions, recorded;
6. an updated `CLAUDE.md`;
7. a suggested commit;
8. a clear stopping point.

The human developer should never have to guess:

* which files changed;
* why they changed;
* whether the tests were actually run;
* whether the work is complete.

---

# 30. Final Rule

**Inspect first.**

**Plan second, and get approval.**

**Explain architectural conflicts before changing them.**

**Make focused, reviewable changes.**

**Write tests.**

**Run the commands and report what actually happened.**

**Leave Git to the human developer.**

**Use the resulting output to guide the next step.**

The goal is not merely to generate code.

The goal is to make the development of Historical Text Converter **deliberate, reproducible, reviewable, and maintainable over the long term.**
