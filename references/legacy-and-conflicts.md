# Legacy & Brownfield Codebases (Strangler Fig)

Most real work happens on existing code that isn't Clean. Do not treat the main skill as license to demand a rewrite.

## General brownfield rules

1. **Never propose a big-bang rewrite** as the default answer to "this code isn't Clean." Rewrites are high-risk and usually the wrong call; recommend one only if explicitly asked to evaluate that option, and pair it with the risks.
2. **Apply the Strangler Fig pattern:** wrap legacy modules behind a new Port interface, and let new features be built against the port while the legacy implementation is gradually replaced behind it. The rest of the system doesn't need to know it's talking to legacy code.
3. **New code touching old code:** if a new Use Case needs data from a legacy, un-abstracted data layer, introduce a thin adapter/repository implementing a new Port — even if that adapter's internals are messy — so the new business logic doesn't get contaminated with the legacy shape.
4. **Don't retrofit layering onto stable, rarely-touched legacy code** just for architectural purity. Reserve refactoring effort for code that's actively being modified (the "boy scout rule": leave the code you touch better, don't go touch code you don't need to).
5. **Migration order:** extract Entities and business rules first (highest-value, lowest-risk extraction), then Use Cases, then adapters. Don't start with the UI or the database layer.

## When the existing codebase directly contradicts this skill

Distinct from gradual migration: sometimes a person asks for one Clean-Architecture-styled change inside a codebase built entirely on a conflicting style (Active Record, Transaction Script, God Objects).

**Resolution order:**

1. **Don't refuse the task.** Say plainly, once, that the surrounding code doesn't follow these patterns, so the new piece will look inconsistent with its neighbors — then proceed.
2. **Build the requested piece as a "clean island":** the new Use Case/Entity/Port follows the skill internally, and touches the legacy code only through a thin adapter (same mechanism as Strangler Fig), even if that means the adapter is the only "ugly" part.
3. **Don't cascade the refactor** into surrounding legacy code the person didn't ask about, even if it's tempting to "fix while you're in there" — that's scope creep, and the Tier discipline in the main SKILL.md exists precisely to prevent it.
4. **If asked directly "should we refactor the rest to match?"** — give a real answer (cost, risk, incremental path via the rules above), not an automatic yes or no.
