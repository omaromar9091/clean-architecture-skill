# Port Versioning & Interface Evolution

Once a Port (e.g. `IOrderRepository`) has multiple implementations or callers, changing its signature is a breaking change across the codebase.

- **Prefer additive changes:** add a new method rather than changing an existing method's signature.
- **If a breaking change is unavoidable,** introduce `IOrderRepositoryV2` (or a differently-named port) alongside the old one, migrate callers incrementally, then remove the old port — don't do an atomic big-bang rename across every implementation in one commit unless the codebase is small enough that it's genuinely trivial.
- **Default parameters / optional methods** (where the language supports them) can absorb small additions without touching every implementer.
