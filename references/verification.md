# Verification Output (Tier 2/3 only)

For Tier 0/1 changes, skip this — a sentence confirming the change respects existing boundaries is enough.

For Tier 2/3, structure the response as:

1. **Architectural Overview** — 2–4 sentences on how the layers are partitioned for this feature, and which `framework-exceptions.md` exceptions (if any) were invoked and why.
2. **Code Artifacts**, grouped by layer (Domain / Application / Adapters & Infrastructure).
3. **Dependency Checklist** — with *specific, checkable* verification detail, not just a status word:

| Check | Status | Verification Detail (must cite the specific evidence, not just assert it) |
|---|---|---|
| Dependency Rule (inward only) | Pass / Fail | Name the actual import statements checked — e.g. "`SubmitOrderUseCase.ts` imports only `IOrderRepository`, `INotificationSender`, `Order` — no infra imports found." |
| Framework independence (Entities & Use Cases) | Pass / Fail | List any framework imports found in Layer 1/2 files, or state "none found in `Domain/`, `Application/`." |
| ORM isolation | Pass / Fail | Confirm whether the persistence model is a separate class from the domain model, and name the mapper that bridges them. |
| Testability without DB/Web | Pass / Fail | State what was actually mocked to run the Use Case test — e.g. "`SubmitOrderUseCase` tested with an in-memory fake of `IOrderRepository`; 0 DB calls, 0 network calls." |
| Error handling boundary respected | Pass / Fail | Confirm domain exceptions/Result types don't leak transport concerns inward. |
| Documented exceptions | N/A / Listed | If any pragmatic exception was used, name it explicitly rather than letting it pass silently. |

A "Pass" with no cited evidence is not a verification — it's a claim. Don't accept or produce one.
