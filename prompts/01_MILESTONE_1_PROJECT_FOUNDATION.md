# Historical Text Converter — Milestone 1: Project Foundation

## Repository

Canonical repository:

`https://github.com/jacquesn/historical-text-converter`

Follow:

`prompts/00_CHATGPT_DEVELOPMENT_PROTOCOL.md`

That document defines the rules for all Historical Text Converter development sessions, including the requirement that you operate as a **read-only development assistant**.

You must provide me with the file paths, code, tests, and commands I need to make the changes manually.

Do not make changes to the repository yourself.

---

# 1. Governing Documents

Before doing any implementation work, read the following documents from the repository:

```text
00_PROJECT_CONSTITUTION.md
00a_GLOSSARY.md
00b_DECISION_LOG.md
00c_ARCHITECTURAL_PRINCIPLES.md
01_ARCHITECTURE.md
02_DEVELOPMENT_ROADMAP.md
prompts/00_CHATGPT_DEVELOPMENT_PROTOCOL.md
```

Also inspect the current contents of the GitHub repository.

The repository represents the **current implementation state**.

The documents represent the **intended project design**.

Do not assume that they are already identical.

---

# 2. Milestone

This session is for:

**Milestone 1 — Project Foundation**

The goal is to establish a clean, minimal Ruby foundation on which the rest of Historical Text Converter can be built.

---

# 3. Objective

At the end of this milestone, the project should have a functioning Ruby development foundation that can:

* load the main library;
* expose the `HistoricalTextConverter` namespace;
* report the application version;
* load basic configuration;
* provide a minimal CLI;
* display CLI help;
* display the application version;
* provide a basic error hierarchy;
* run RSpec;
* run RuboCop.

No historical-text conversion functionality should be implemented during this milestone.

---

# 4. First Task: Inspect Before Designing

Before proposing any code changes, inspect the repository.

Determine:

* which files already exist;
* which directories already exist;
* whether a Ruby project is already initialized;
* whether a `Gemfile` already exists;
* whether RSpec is already configured;
* whether RuboCop is already configured;
* whether a CLI already exists;
* whether configuration already exists;
* whether tests already exist;
* what dependencies are already present;
* what version information already exists;
* whether any implementation from Milestone 1 has already been completed.

Then give me a concise report:

```text
## Current Repository State

### Existing Structure
...

### Existing Ruby Infrastructure
...

### Existing Tests
...

### Existing Dependencies
...

### Existing CLI
...

### Existing Configuration
...

### Differences from Milestone 1
...

### Recommended Changes
...
```

Do not generate implementation code until you have completed this inspection.

---

# 5. Important: Preserve Existing Work

If part of Milestone 1 has already been implemented, do not replace it merely because you would have implemented it differently.

Instead:

1. inspect the existing implementation;
2. determine whether it satisfies the architecture and milestone requirements;
3. retain good existing work;
4. modify only what is necessary.

If existing code conflicts with the governing documents, explain the conflict before proposing a change.

---

# 6. Project Structure

Establish the foundation described in `01_ARCHITECTURE.md`.

The intended foundation includes:

```text
Gemfile
Gemfile.lock
LICENSE
README.md
CHANGELOG.md
Rakefile
.gitignore
.rubocop.yml

bin/
└── historical-text-converter

lib/
└── historical_text_converter.rb

lib/historical_text_converter/
├── version.rb
├── cli.rb
├── configuration.rb
└── errors.rb

config/
└── default.yml

spec/
```

Do not blindly create every file if the repository already contains an appropriate equivalent.

Do not create speculative files for later milestones.

---

# 7. Ruby Namespace

Establish the primary namespace:

```ruby
HistoricalTextConverter
```

Follow normal Ruby naming conventions.

The main library should be requireable in the normal Ruby fashion.

The namespace should provide a clean foundation for the classes that will be added in later milestones.

---

# 8. Version

Establish the application's version.

Use semantic versioning.

The version should be available programmatically.

For example, the project should eventually support something conceptually equivalent to:

```ruby
HistoricalTextConverter::VERSION
```

The exact implementation should follow the architecture and existing repository conventions.

Do not over-engineer version management during this milestone.

---

# 9. Gemfile and Dependencies

Establish the project's initial dependency structure.

The architecture identifies the following expected dependencies:

* Nokogiri;
* YAML/Ruby YAML support;
* RSpec;
* RuboCop.

Use the appropriate Ruby standard-library mechanism for YAML rather than adding a separate YAML dependency unnecessarily.

Use appropriate dependency groups where appropriate.

Do not add dependencies for later functionality unless there is a specific foundation-level reason.

In particular, do not add DOCX or other output-format dependencies during this milestone merely because they will be needed later.

After determining what the repository already contains, recommend the smallest appropriate dependency set.

---

# 10. Configuration Foundation

Establish the initial configuration system.

Create or complete:

```text
config/default.yml
```

and:

```text
lib/historical_text_converter/configuration.rb
```

The configuration system should provide a foundation for:

* default settings;
* user configuration;
* profiles;
* transformation settings.

However, do not implement the complete transformation configuration system yet.

Do not invent a large collection of settings.

Only establish what is necessary for the foundation and what is supported by the governing architecture documents.

---

# 11. CLI Foundation

Create or complete:

```text
bin/historical-text-converter
```

and:

```text
lib/historical_text_converter/cli.rb
```

The CLI must remain thin.

It should handle concerns such as:

* command-line argument parsing;
* help;
* version;
* basic configuration loading;
* user-facing CLI errors.

It must not contain:

* HTML parsing;
* EEBO extraction;
* Document Model logic;
* spelling modernization;
* Americanization;
* RTF generation;
* DOCX generation.

Those belong to later layers.

---

# 12. Required CLI Behavior

Implement at least:

```text
--help
--version
```

The following should be possible after I manually apply your changes:

```bash
bundle exec bin/historical-text-converter --help
```

and:

```bash
bundle exec bin/historical-text-converter --version
```

The executable should provide useful output rather than merely proving that the Ruby file can be executed.

If an invalid option or invocation is supplied, the CLI should produce a sensible error and appropriate exit behavior.

Use normal Ruby CLI conventions.

---

# 13. Error Hierarchy

Create or complete:

```text
lib/historical_text_converter/errors.rb
```

Establish a small, useful namespaced error hierarchy.

Do not create a large collection of speculative exception classes.

Errors should eventually allow callers to distinguish application-specific failures from ordinary Ruby errors.

The exact hierarchy should follow `01_ARCHITECTURE.md`.

---

# 14. RSpec

Establish RSpec as the project's test framework.

Create the appropriate test configuration and initial tests.

At minimum, test:

### Library

* the main library loads;
* the primary namespace exists.

### Version

* the version constant exists;
* the version has the expected semantic-version form.

### Configuration

* default configuration can be loaded;
* configuration can be instantiated successfully.

### CLI

* help works;
* version works;
* invalid CLI usage is handled appropriately.

Do not write tests for functionality that belongs to later milestones.

---

# 15. RuboCop

Establish the project's RuboCop configuration.

The project should support:

```bash
bundle exec rubocop
```

Avoid disabling broad categories of rules simply to make the project pass.

Use a minimal, understandable `.rubocop.yml`.

If an exception is genuinely necessary, explain why.

---

# 16. Rake

Establish a useful `Rakefile`.

At minimum, provide a straightforward way to run the test suite.

If appropriate, make the default Rake task run the tests.

Keep the Rakefile simple.

Do not build a complicated task system during Milestone 1.

---

# 17. README

Create or update:

```text
README.md
```

The README should accurately explain:

* what Historical Text Converter is;
* the current project status;
* that development is incremental;
* how to install dependencies;
* how to run the tests;
* how to run RuboCop;
* how to invoke the CLI;
* what Milestone 1 currently provides.

Clearly distinguish implemented functionality from planned functionality.

Do not describe EEBO conversion, spelling modernization, RTF generation, or DOCX generation as implemented unless they actually already exist in the repository.

---

# 18. CHANGELOG

Create or update:

```text
CHANGELOG.md
```

Record the foundation work appropriate to this milestone.

Do not invent previous releases or pretend that unreleased functionality already exists.

---

# 19. LICENSE

Inspect the existing repository and governing documents for a licensing decision.

If a license has already been selected, preserve it.

If the project documents specify a license, implement that license.

If no license has yet been selected, **do not arbitrarily choose one**.

Instead, tell me that a licensing decision remains outstanding and provide the appropriate placeholder approach.

---

# 20. .gitignore

Create or update:

```text
.gitignore
```

Use a sensible Ruby-project configuration.

Do not exclude source files that should be committed.

Do not add highly specific exclusions for tools that the project does not use.

---

# 21. Out of Scope

Do **not** implement the following during Milestone 1:

## Document Model

Do not implement:

```text
Book
Document
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
```

Those belong to Milestone 2.

---

## EEBO Parser

Do not implement:

* Nokogiri extraction logic;
* EEBO source isolation;
* HTML structure detection;
* artifact detection;
* page-marker extraction;
* historical-text extraction.

Those belong to later milestones.

---

## Transformations

Do not implement:

* `∣` removal;
* artifact removal;
* whitespace normalization;
* word-boundary repair;
* spelling modernization;
* Americanization;
* printer-error correction.

---

## Writers

Do not implement:

* RTF output;
* DOCX output;
* Markdown output;
* HTML output;
* text output.

---

## Other Features

Do not implement:

* AI-assisted rewriting;
* grammar modernization;
* web interfaces;
* databases;
* background processing;
* cloud services;
* user accounts;
* unnecessary plugin systems;
* speculative source formats.

---

# 22. Architectural Constraints

Follow the project's architectural principles, especially:

* preservation first;
* explicit behavior;
* minimal dependencies;
* small objects;
* composition over inheritance;
* one responsibility per component;
* deterministic behavior;
* testability;
* readable Ruby;
* stable public APIs;
* configuration as a user interface;
* errors should educate;
* avoid premature abstraction.

The foundation should make later milestones easier without prematurely implementing them.

---

# 23. Do Not Silently Change Architecture

If you encounter a conflict between the repository and the governing documents:

Do not silently resolve it by changing the architecture.

Instead report:

```text
### Architectural Discrepancy

Current repository:
...

Governing documents:
...

Conflict:
...

Possible solutions:
...

Recommended approach:
...
```

If the issue requires a project-level decision, stop and ask me before proceeding.

If a decision is made, identify whether `00b_DECISION_LOG.md` should be updated.

---

# 24. Implementation Output

Once the repository inspection and implementation plan are complete, provide the changes for me to apply manually.

For every new file, use:

```text
### Create: path/to/file
```

followed by the complete file contents.

For every modified file, use:

```text
### Replace: path/to/file
```

followed by the complete resulting file contents whenever practical.

If a complete replacement would be unnecessarily large, provide a precise patch and explain exactly where it applies.

Do not give vague instructions such as:

> “Add a method to the configuration class.”

Give me the exact code.

---

# 25. Test Output

Provide all tests required for the changes.

For example:

```text
### Create: spec/historical_text_converter_spec.rb
```

followed by the complete test file.

Tests should verify actual behavior, not implementation details unnecessarily.

---

# 26. Commands for Me to Run

At the end of the implementation instructions, provide the exact commands I should run.

At minimum, where applicable:

```bash
bundle install
bundle exec rspec
bundle exec rubocop
bundle exec bin/historical-text-converter --help
bundle exec bin/historical-text-converter --version
```

Also provide any useful Git inspection commands, such as:

```bash
git status
git diff
```

Do not claim that these commands succeeded unless you have actually received their output.

---

# 27. Verification

After I apply your changes and run the commands, I will provide the results.

If something fails, diagnose the actual output I provide.

Do not guess at errors when the relevant output is available.

If the implementation needs correction, give me:

1. the exact file path;
2. the reason for the problem;
3. the corrected code;
4. any additional tests;
5. the commands to rerun.

---

# 28. Acceptance Criteria

Milestone 1 is complete when:

### Project Foundation

* [ ] Ruby project structure is established.
* [ ] `HistoricalTextConverter` namespace exists.
* [ ] Version is available.
* [ ] Dependencies are appropriately declared.
* [ ] Configuration foundation exists.
* [ ] CLI foundation exists.
* [ ] Error hierarchy exists.

### CLI

* [ ] `--help` works.
* [ ] `--version` works.
* [ ] Invalid usage is handled sensibly.
* [ ] CLI remains thin.

### Testing

* [ ] RSpec is configured.
* [ ] Initial tests exist.
* [ ] Tests pass.

### Code Quality

* [ ] RuboCop is configured.
* [ ] RuboCop passes.
* [ ] No unnecessary dependencies have been added.
* [ ] No later milestone has been prematurely implemented.

### Documentation

* [ ] README is accurate.
* [ ] CHANGELOG is present and accurate.
* [ ] LICENSE is handled appropriately.
* [ ] `.gitignore` is appropriate.

### Architecture

* [ ] Implementation follows `01_ARCHITECTURE.md`.
* [ ] No architectural changes were made silently.
* [ ] Any necessary decisions have been identified.

---

# 29. Final Report

After providing the implementation, give me a final report in this format:

```text
## Milestone 1 Report

### Repository Assessment
...

### Files to Create
...

### Files to Modify
...

### Functionality Added
...

### Tests Added
...

### Commands to Run
...

### Expected Results
...

### Architectural Decisions
...

### Outstanding Issues
...

### Next Milestone
Milestone 2 — Document Model
```

Do not report tests as passing until I provide the actual results.

---

# 30. Stop

Once the Milestone 1 implementation has been specified and the required tests and verification commands have been provided, **stop**.

Do not begin Milestone 2.

The next milestone is:

**Milestone 2 — Document Model**

It will be handled in a separate development session using its own prompt.
