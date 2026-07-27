# Cross-Cutting Concerns

These cut across layers and cause the most "where does this go?" confusion in practice.

- **Transactions (Unit of Work):** the transaction boundary belongs at the **Use Case** level, not inside the Repository. A Use Case may call multiple repository methods that must commit atomically — inject an `IUnitOfWork` port into the Use Case, and let the concrete implementation (Layer 4) manage the actual DB transaction.

- **Logging:** never put logging calls inside Entities (it's an infrastructure concern touching pure business logic). Log at Layer 3/4 boundaries — Controllers log incoming requests/outcomes, Repositories log query failures. If a Use Case needs to emit a domain-relevant log/audit trail as part of its behavior, model it explicitly as a Domain Event (see `domain-events.md`) rather than a raw `logger.info()` call buried in business logic.

- **Caching:** belongs behind the Port, inside the concrete Repository/Gateway implementation (Layer 3/4) — the Use Case asks `IOrderRepository.findById()` and has no idea whether that hit a cache or the DB. Never cache inside a Use Case by hand-rolling a static dictionary; that's an infrastructure concern leaking inward.

- **Authorization/permissions:** business-rule authorization ("only the order's owner can submit it") belongs in the Use Case or Entity. Transport-level authorization ("is this JWT valid") belongs in Layer 3/4 middleware, before the Controller even constructs the request DTO.
