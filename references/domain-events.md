# Domain Events & Async Workflows

Real systems rarely do everything synchronously inside one Use Case. When a business event should trigger side effects owned by a *different* part of the system (send email, update a read model, notify another service), model it explicitly:

```typescript
// Domain/Events/OrderSubmitted.ts — a plain data record, Layer 1
export class OrderSubmitted implements DomainEvent {
  constructor(readonly orderId: OrderId, readonly occurredAt: Date) {}
}

// Entity raises the event, doesn't handle it
export class Order {
  private _events: DomainEvent[] = [];
  submit(): void {
    if (this.status !== OrderStatus.Draft) throw new InvalidOrderTransitionError(...);
    this.status = OrderStatus.Submitted;
    this._events.push(new OrderSubmitted(this.id, new Date()));
  }
  pullEvents(): DomainEvent[] { const e = this._events; this._events = []; return e; }
}

// Use Case publishes events after persisting — doesn't know who listens
async execute(request: SubmitOrderRequest): Promise<SubmitOrderResponse> {
  const order = await this.orders.findById(request.orderId);
  order.submit();
  await this.orders.save(order);
  await this.eventBus.publishAll(order.pullEvents());   // IEventBus is a Port
  return { orderId: order.id.value, status: 'submitted' };
}

// Infrastructure (Layer 4) — a separate handler, possibly in a different process/queue consumer
class SendOrderConfirmationEmailHandler {
  async handle(event: OrderSubmitted): Promise<void> { /* ... */ }
}
```

**Rule:** the Use Case that raises an event never directly calls the handler. It publishes to an `IEventBus` port (in-process pub/sub, or a real message queue in production) — keeping "notify the customer" decoupled from "submit the order," so either can change independently.
