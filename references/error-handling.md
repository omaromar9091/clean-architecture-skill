# Error Handling Across Boundaries

Two valid strategies — pick one per codebase and stay consistent; don't mix silently.

## Strategy A — Exceptions (simpler, common in C#/Java/Python)

- Entities/Use Cases throw domain-specific exceptions (`OrderNotFoundError`, `InvalidOrderTransitionError`), never generic `Exception`.
- The Controller (Layer 3) is the *only* place that catches domain exceptions and maps them to transport-specific responses (HTTP status codes, gRPC codes).
- The Use Case never knows what an HTTP 404 is; it only knows `OrderNotFoundError` exists.

```typescript
// Layer 3 — Controller is where domain exceptions become HTTP
async handleSubmit(req: Request, res: Response): Promise<void> {
  try {
    const result = await this.submitOrder.execute({ orderId: req.params.id });
    res.status(200).json(result);
  } catch (err) {
    if (err instanceof OrderNotFoundError) return res.status(404).json({ error: err.message });
    if (err instanceof InvalidOrderTransitionError) return res.status(409).json({ error: err.message });
    throw err; // unexpected — let it bubble to global error middleware
  }
}
```

## Strategy B — Result/Either type (safer for large teams, common in TS/Rust/functional-leaning codebases)

- Use Cases return `Result<SubmitOrderResponse, OrderError>` instead of throwing.
- Forces the Controller to explicitly handle both branches — nothing can "forget" to catch an error.

```typescript
async execute(request: SubmitOrderRequest): Promise<Result<SubmitOrderResponse, OrderError>> {
  const order = await this.orders.findById(request.orderId);
  if (!order) return Result.fail(new OrderNotFoundError(request.orderId));
  order.submit();
  await this.orders.save(order);
  return Result.ok({ orderId: order.id.value, status: 'submitted' });
}
```

## Rule either way

The Entity/Use Case layer never imports a transport-layer error type (no `HttpException`, no `res.status`). Translation happens once, at the Controller.
