# Clean Architecture Skill for Claude

A production-ready [Claude Skill](https://docs.claude.com) that teaches Claude to apply Robert C. Martin's **Clean Architecture**, **SOLID principles**, and **component-decoupling** rules — correctly calibrated to the size of the task, backed by real multi-language code, and honest about the compromises real-world frameworks force.

Drop it into your skills directory and Claude will automatically reach for it whenever you're designing a feature, reviewing code for architectural soundness, deciding which layer a piece of logic belongs in, or untangling a legacy codebase.

---

## Quick install (one command)

Run this from the root of any project. It downloads the skill and places it at `.claude/skills/clean-architecture/`, where Claude Code and other Claude-based agents pick up skills automatically — no manual copying needed.

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/omaromar9091/clean-architecture-skill/main/install.sh | bash
```

**Windows (PowerShell):**
```powershell
iwr -useb https://raw.githubusercontent.com/omaromar9091/clean-architecture-skill/main/install.ps1 | iex
```

Prefer to inspect a script before running it? Open [`install.sh`](install.sh) or [`install.ps1`](install.ps1) first — both just download `SKILL.md` and the `references/` files into your project, nothing else.

For manual installation (copying the folder yourself, or using this with a non-Claude tool), see [Installation](#installation) below.

---

## Why this exists

Most "Clean Architecture" prompts and cheat sheets have the same problem: they describe the *theory* well but fall apart in practice. They tell an AI agent to enforce four concentric layers on every single request — including a one-line bug fix — which produces exactly the kind of bureaucratic over-engineering Clean Architecture was invented to prevent. They also tend to skip the parts that actually come up in real projects: how do errors cross layer boundaries? Where does a database transaction belong? What do you do when the existing codebase is a mess and someone just wants one clean feature added to it?

This skill was built specifically to close those gaps. It went through several rounds of deliberate stress-testing — asking "what's still missing?" repeatedly — before being converted into this final, structured form.

---

## What makes this different

- **🎚️ Won't over-engineer trivial changes.** A built-in task-tiering system stops a typo fix or a one-field DTO change from triggering a full four-layer restructure. Ceremony is applied only when the task actually warrants it.
- **🚫 Knows when *not* to apply itself.** Scripts, prototypes, and single-maintainer tools with no growth plan are explicitly called out as cases where the overhead isn't worth paying — and the skill says so out loud instead of silently over-architecting.
- **💻 Ships real code, not just diagrams.** Every layer has working examples in **TypeScript, C#, and Python**, plus a fully executable Jest unit test — so "testable without a database" isn't just a claim, it's demonstrated.
- **🛠️ Documents framework compromises honestly.** ORMs, DI containers, validation decorators, and serverless entry points all push back on pure layering in the real world. Instead of pretending otherwise, this skill has a dedicated reference table of pragmatic, deliberate exceptions — with a clear test for telling a real leak from an acceptable one.
- **🏚️ Built for legacy code, not just greenfield.** Includes the Strangler Fig migration pattern and a "clean island" approach for adding one well-architected feature inside a codebase that doesn't follow these principles at all — without triggering a rewrite or cascading an unwanted refactor.
- **🧩 Covers the practical gaps most guides skip:** error-handling strategy (exceptions vs. Result/Either types), cross-cutting concerns (transactions, logging, caching, authorization), Domain Events for async workflows, safe Port/interface versioning, avoiding duplicated validation logic, and how many files a small feature actually needs.
- **⚖️ Defines a clear authority model.** The skill tells the AI agent exactly what to do when it spots a violation: flag it, don't silently "fix" unrelated code, don't silently comply with a request that introduces a new violation without saying so — and always defer to the person's explicit final call after the trade-off has been surfaced honestly.

---

## How it's organized

Skills use progressive disclosure: a lightweight core file that's always loaded when the skill triggers, plus deeper reference material that's only pulled in when a specific situation calls for it. That keeps everyday use fast while still having real depth on tap.

```
clean-architecture/
├── SKILL.md                       ← Core rules. ~136 lines. Read first, every time.
└── references/
    ├── code-examples.md           ← Full TS / C# / Python examples for every layer,
    │                                 a before/after fix of the "Smart Controller"
    │                                 anti-pattern, and an executable unit test.
    ├── framework-exceptions.md    ← When an ORM attribute, a DI constructor
    │                                 requirement, or a CQRS-style folder layout is a
    │                                 legitimate exception vs. a real boundary leak.
    ├── legacy-and-conflicts.md    ← Strangler Fig pattern for gradual migration, and
    │                                 the "clean island" approach for adding one
    │                                 well-architected piece inside an inconsistent
    │                                 codebase without cascading a refactor.
    ├── error-handling.md          ← Exceptions vs. Result/Either — where domain
    │                                 errors get translated into transport-specific
    │                                 responses, and why that translation happens
    │                                 exactly once, at the Controller.
    ├── cross-cutting-concerns.md  ← Where transactions (Unit of Work), logging,
    │                                 caching, and authorization actually belong.
    ├── domain-events.md           ← Modeling async side effects (e.g. "notify the
    │                                 customer when an order ships") without coupling
    │                                 the triggering Use Case to the handler.
    ├── port-versioning.md         ← Evolving a repository/gateway interface without
    │                                 breaking every existing implementation.
    ├── shared-validation.md       ← Why duplicated validation across Use Cases
    │                                 usually means you're missing a Value Object.
    ├── file-granularity.md        ← Scaling file count to feature size — a 15-line
    │                                 feature doesn't need six files.
    ├── authority-model.md         ← What the AI agent does when it spots a
    │                                 violation: flag vs. silently fix vs. escalate.
    └── verification.md            ← The output template for larger tasks — a
                                      dependency checklist that requires cited,
                                      checkable evidence instead of a bare Pass/Fail.
```

---

## Installation

### Option A — Claude.ai or Claude Code (recommended)

1. Copy the entire `clean-architecture/` folder — `SKILL.md` and the `references/` directory together — into your Claude skills directory.
2. That's it. Claude will consult it automatically whenever a request matches its trigger conditions (architecture design, code review, refactoring, SOLID/DIP questions, "where should this logic live", legacy-code untangling, and so on — see the `description` field in `SKILL.md`'s frontmatter for the exact list).

### Option B — Any other LLM or manual use

1. Paste the contents of `SKILL.md` into your system prompt or project/custom instructions.
2. Keep the `references/*.md` files nearby and pull individual ones into context as the situation calls for them — each is scoped to one topic so you only pay context budget for what's actually relevant to the task at hand.

---

## Example: how it behaves

Given a request like *"add a feature to cancel an order"* in a codebase that already has an `Order` entity and a `SubmitOrderUseCase`, the skill:

1. **Classifies the task** as a new business capability (Tier 2) rather than a trivial change — because it introduces a real business rule ("only a submitted, not-yet-shipped order can be cancelled"), not just a field addition.
2. **Puts the business rule where it belongs** — inside `Order.cancel()`, not the controller or the use case — which is the single most common real-world violation this skill exists to prevent.
3. **Reuses existing abstractions** instead of inventing new ones — no new repository port gets created just because a new feature showed up.
4. **Follows the codebase's existing error-handling convention** instead of introducing a second, competing style.
5. **Produces a verification table with cited evidence** ("`CancelOrderUseCase.ts` imports only `IOrderRepository`, `IEventBus`, `Order` — no infra imports found") rather than an unverifiable "Pass."

---

## Attribution

This skill is an independent instructional summary and extension, built for AI-agent use, of ideas from Robert C. Martin's *Clean Architecture: A Craftsman's Guide to Software Structure and Design* (2017) and the broader SOLID literature. It does not reproduce the book's text.

## License

Free to use, modify, and redistribute. Attribution appreciated but not required.

## Contributing

Issues and pull requests are welcome — especially real-world edge cases the skill doesn't handle well yet, additional language examples, or reports of it under- or over-triggering.
