---
name: clean-architecture
description: Apply Robert C. Martin's Clean Architecture, SOLID, and component-decoupling principles when designing, reviewing, or refactoring code — scaled correctly to the size of the task so trivial changes don't get over-engineered. Use this whenever the user asks to design a new feature/service, review code for architectural soundness, refactor toward better layering/testability, decide where a piece of logic belongs (domain vs. use case vs. controller vs. infrastructure), untangle a legacy/brownfield codebase, or explicitly mentions "clean architecture", "hexagonal architecture", "ports and adapters", "onion architecture", "SOLID principles", "dependency inversion", or "separation of concerns". Also trigger when the user is unsure whether a design decision belongs in one layer or another, or asks "is this a violation of X principle".
---

# Clean Architecture Engine

A practical, calibrated skill for applying Clean Architecture — scaled to task size, grounded in real code, honest about framework compromises, and explicit about error handling, cross-cutting concerns, legacy code, and when *not* to apply any of this.

**Read `references/` files as needed — don't load all of them up front.** Each is pointed to below with a note on when it's relevant.

---

## 0. Classify the task first (always do this before anything else)

| Task Size | Example | What to apply |
|---|---|---|
| **Tier 0 — Trivial** | Typo, log message, constant change, off-by-one fix | Just fix it. No layers, no ceremony. |
| **Tier 1 — Small change** | Add a field to an existing DTO, new endpoint reusing an existing Use Case, bug fix inside one layer | Respect existing boundaries. No new layers/folders, no 5-step workflow. |
| **Tier 2 — New feature/module** | New CRUD feature, new integration, new workflow | Full layer separation (Section 2) + workflow (Section 5), scaled file granularity — see `references/file-granularity.md`. |
| **Tier 3 — New system/service** | Greenfield service, major subsystem, long-lived architectural decision | Everything: full layering, SOLID review, verification table (`references/verification.md`), trade-off discussion. |

**Before applying anything else, also check Section 6 ("When NOT to apply this")** — a one-off script, a throwaway prototype, or a single-maintainer tool with no growth plan may not need any of this. Say so plainly if that's the case; don't silently over-architect.

If unsure which tier applies, default one tier lower than your first instinct and let the person ask for more rigor.

**The failure mode this exists to prevent:** Tier 3 ceremony on a Tier 0 fix. A process that makes small changes expensive violates Clean Architecture's own stated goal — minimizing the cost of change over time.

---

## 1. Core philosophy

* **Primary objective:** minimize the human cost of building and maintaining the system over time — not maximize adherence to a diagram.
* **Primary value:** architecture over behavior. Behavior changes easily if the architecture stays flexible ("soft").
* **Deferral of details:** high-level policy (business rules) must not depend on low-level detail (frameworks, databases, web servers, UI, message brokers).
* **Pragmatism over purity:** every rule below has documented exceptions (`references/framework-exceptions.md`). A rule with no acknowledged exceptions usually hasn't met a real framework yet.

---

## 2. The four layers

```
+-----------------------------------------------------------------------+
|  4. Frameworks & Drivers Layer (Web, DB, UI, External APIs, Devices) |
|   +---------------------------------------------------------------+   |
|   |  3. Interface Adapters Layer (Controllers, Gateways, Mappers) |   |
|   |   +-------------------------------------------------------+   |   |
|   |   |  2. Application Business Rules (Use Cases & Ports)   |   |   |
|   |   |   +-----------------------------------------------+   |   |   |
|   |   |   |  1. Enterprise Business Rules (Entities)      |   |   |   |
|   |   |   +-----------------------------------------------+   |   |   |
|   |   +-------------------------------------------------------+   |   |
|   +---------------------------------------------------------------+   |
+-----------------------------------------------------------------------+
```

### ⭕ The Dependency Rule
> **Source code dependencies must point ONLY inward.** Nothing in an inner circle may know anything about an outer circle — no classes, functions, variables, data formats, or framework imports.

**Layer 1 — Entities:** core business concepts, invariants that hold regardless of which application uses them. No framework imports, no DB/HTTP dependencies, no references to outer layers.

**Layer 2 — Use Cases:** orchestrates data flow to/from Entities for an application-specific goal. Interactors, input/output ports (interfaces), request/response DTOs. No ORM/DB framework references, no web/HTTP objects (`req`, `res`, `HttpContext`), no concrete outer-layer implementations.

**Layer 3 — Interface Adapters:** translates between Use Case/Entity shapes and external agency shapes. Controllers, presenters, view models, repository implementations, mappers.

**Layer 4 — Frameworks & Drivers:** the glue — routing, ORM config, DB drivers, UI libraries. Kept at the outer edge; frameworks are details, not the architecture.

**For full multi-language code examples (TypeScript, C#, Python) of every layer, plus a before/after fix of the "Smart Controller" anti-pattern → read `references/code-examples.md`.**

---

## 3. SOLID & component principles

1. **SRP** — one module answers to one actor/stakeholder.
2. **OCP** — extend via interfaces/polymorphism; don't edit core code for new behavior.
3. **LSP** — subtypes substitutable for base types; throwing `NotImplementedException` in an override is a violation.
4. **ISP** — small, focused interfaces over large monolithic ones.
5. **DIP** — high-level modules depend on abstractions, not low-level modules.

**Component coupling:** ADP (no dependency cycles), SDP (depend toward stability), SAP (abstractness matches stability).

---

## 4. Prohibitions — flag and reject

1. ❌ **Boundary leak** — e.g. `UseCase` importing `SqlUserRepository` instead of `IUserRepository`.
2. ❌ **Leaky ORM entities** used as domain models.
3. ❌ **Smart controllers / fat views** — business logic in a controller or UI event handler.
4. ❌ **HTTP context pollution** — `req`/`res`/`HttpContext` passed into Use Cases or Entities.
5. ❌ **Primitive obsession across boundaries** — raw JSON/strings instead of typed DTOs/Value Objects.
6. ❌ **Circular dependencies.**

---

## 5. Execution workflow (Tier 2/3 only)

1. Define Entities & Value Objects (Layer 1).
2. Define Application Ports & DTOs (Layer 2).
3. Implement Use Case Interactors (Layer 2), relying only on Layer 1/2 abstractions.
4. Implement Interface Adapters & Infrastructure (Layers 3 & 4).
5. Wire dependencies at the Composition Root.

Tier 1: skip straight to the layer the change belongs in — don't re-run all five steps for a one-field addition.

**Directory structure should announce what the system does, not its framework** (Screaming Architecture) — e.g. `src/Ordering/{Domain,Application,Infrastructure,Presentation}/`, not `src/{Models,Views,Controllers,Services}/`. Never restructure an existing module's folders for a Tier 0/1 fix.

---

## 6. When NOT to apply this skill

Clean Architecture has a real cost: more files, more indirection, more upfront design. Skip most/all of it for:
- One-off scripts, data migrations run once, throwaway prototypes.
- A true MVP/spike explicitly built to validate an idea before a scale-or-rewrite decision.
- Small internal tools with a single maintainer, low change frequency, no growth plan.

If a person asks to "apply Clean Architecture" to something in these categories, say plainly that the overhead likely isn't worth it, offer a lighter-weight alternative (a single well-organized module, clear function boundaries, no ports/DI), and let them decide.

---

## 7. Legacy code, conflicts, and topics needing more depth

Several situations need more than this file's core rules — **read the relevant reference before acting**:

- **Working inside an existing legacy/brownfield codebase**, or a codebase whose existing style directly contradicts Clean Architecture → `references/legacy-and-conflicts.md` (Strangler Fig pattern, "clean island" approach, anti-scope-creep rules).
- **Error handling across layers** (exceptions vs. Result/Either types, where transport-specific errors get translated) → `references/error-handling.md`.
- **Cross-cutting concerns** — transactions/Unit of Work, logging, caching, authorization — where do they belong? → `references/cross-cutting-concerns.md`.
- **Domain Events / async workflows** (e.g. "when an order is submitted, notify a different part of the system") → `references/domain-events.md`.
- **Evolving a Port's interface without breaking every implementer** → `references/port-versioning.md`.
- **Avoiding duplicated validation logic across multiple Use Cases** → `references/shared-validation.md`.
- **How many files a small feature actually needs** (don't over-fragment a 15-line feature into 6 files) → `references/file-granularity.md`.
- **What to do when you (the AI agent) spot a violation** — flag vs. silently fix vs. escalate → `references/authority-model.md`.
- **Structuring a full Tier 2/3 response with a real verification table** (cited evidence, not bare Pass/Fail) → `references/verification.md`.

## Appendix — noted but out of scope

Deliberately excluded to keep this skill usable by any programmer rather than DDD specialists: architectural maturity metrics (coupling/instability numbers with thresholds), Aggregate boundary sizing at the full DDD level, and multi-service/microservice Bounded Context boundary-drawing. These are real, deeper questions — but one level above general Clean Architecture.
