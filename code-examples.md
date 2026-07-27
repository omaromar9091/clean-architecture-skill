# Code Examples — All Four Layers

Read this when you need concrete code, not just the conceptual rule.

## Layer 1: Entities

### TypeScript
```typescript
// Domain/Order.ts — NO imports from outside the domain layer
export class Order {
  private constructor(
    private readonly id: OrderId,
    private items: OrderLine[],
    private status: OrderStatus
  ) {}

  static create(id: OrderId, items: OrderLine[]): Order {
    if (items.length === 0) {
      throw new EmptyOrderError(id);
    }
    return new Order(id, items, OrderStatus.Draft);
  }

  totalAmount(): Money {
    return this.items.reduce(
      (sum, line) => sum.add(line.subtotal()),
      Money.zero()
    );
  }

  submit(): void {
    if (this.status !== OrderStatus.Draft) {
      throw new InvalidOrderTransitionError(this.status, OrderStatus.Submitted);
    }
    this.status = OrderStatus.Submitted;
  }
}
```

### C#
```csharp
// Domain/Order.cs — no [Table], no [Key], no EF/ORM attributes
public class Order
{
    private readonly List<OrderLine> _items = new();
    public OrderId Id { get; }
    public OrderStatus Status { get; private set; }
    public IReadOnlyList<OrderLine> Items => _items.AsReadOnly();

    private Order(OrderId id) { Id = id; Status = OrderStatus.Draft; }

    public static Order Create(OrderId id, IEnumerable<OrderLine> items)
    {
        var order = new Order(id);
        order._items.AddRange(items);
        if (!order._items.Any())
            throw new EmptyOrderException(id);
        return order;
    }

    public Money TotalAmount() =>
        _items.Aggregate(Money.Zero, (sum, line) => sum + line.Subtotal());

    public void Submit()
    {
        if (Status != OrderStatus.Draft)
            throw new InvalidOrderTransitionException(Status, OrderStatus.Submitted);
        Status = OrderStatus.Submitted;
    }
}
```

### Python
```python
# domain/order.py — plain dataclass/class, no ORM base class
from dataclasses import dataclass

@dataclass
class Order:
    id: OrderId
    items: list[OrderLine]
    status: OrderStatus = OrderStatus.DRAFT

    def __post_init__(self):
        if not self.items:
            raise EmptyOrderError(self.id)

    def total_amount(self) -> Money:
        return sum((line.subtotal() for line in self.items), Money.zero())

    def submit(self) -> None:
        if self.status != OrderStatus.DRAFT:
            raise InvalidOrderTransitionError(self.status, OrderStatus.SUBMITTED)
        self.status = OrderStatus.SUBMITTED
```

---

## Layer 2: Use Cases (Ports + Interactor)

### TypeScript
```typescript
// Application/Ports/IOrderRepository.ts
export interface IOrderRepository {
  save(order: Order): Promise<void>;
  findById(id: OrderId): Promise<Order | null>;
}

// Application/Ports/INotificationSender.ts
export interface INotificationSender {
  notifyOrderSubmitted(order: Order): Promise<void>;
}

// Application/UseCases/SubmitOrderUseCase.ts
export class SubmitOrderUseCase {
  constructor(
    private readonly orders: IOrderRepository,       // abstraction, not SqlOrderRepository
    private readonly notifier: INotificationSender    // abstraction, not EmailService
  ) {}

  async execute(request: SubmitOrderRequest): Promise<SubmitOrderResponse> {
    const order = await this.orders.findById(request.orderId);
    if (!order) throw new OrderNotFoundError(request.orderId);

    order.submit();               // business rule lives in the Entity
    await this.orders.save(order);
    await this.notifier.notifyOrderSubmitted(order);

    return { orderId: order.id.value, status: 'submitted' };
  }
}
```

### C#
```csharp
public interface IOrderRepository
{
    Task SaveAsync(Order order);
    Task<Order?> FindByIdAsync(OrderId id);
}

public class SubmitOrderUseCase
{
    private readonly IOrderRepository _orders;
    private readonly INotificationSender _notifier;

    public SubmitOrderUseCase(IOrderRepository orders, INotificationSender notifier)
    {
        _orders = orders;
        _notifier = notifier;
    }

    public async Task<SubmitOrderResponse> ExecuteAsync(SubmitOrderRequest request)
    {
        var order = await _orders.FindByIdAsync(request.OrderId)
            ?? throw new OrderNotFoundException(request.OrderId);

        order.Submit();
        await _orders.SaveAsync(order);
        await _notifier.NotifyOrderSubmittedAsync(order);

        return new SubmitOrderResponse(order.Id.Value, "submitted");
    }
}
```

---

## Layer 3: Interface Adapters

### TypeScript
```typescript
// Presentation/OrderController.ts
export class OrderController {
  constructor(private readonly submitOrder: SubmitOrderUseCase) {}

  async handleSubmit(req: Request, res: Response): Promise<void> {
    // HTTP parsing happens HERE, not in the Use Case
    const request: SubmitOrderRequest = { orderId: OrderId.from(req.params.id) };
    const result = await this.submitOrder.execute(request);
    res.status(200).json(result);  // res never reaches the Use Case
  }
}

// Infrastructure/Persistence/SqlOrderRepository.ts
export class SqlOrderRepository implements IOrderRepository {
  constructor(private readonly db: DatabaseClient) {}

  async save(order: Order): Promise<void> {
    const row = OrderMapper.toRow(order);   // domain -> persistence shape
    await this.db.table('orders').upsert(row);
  }

  async findById(id: OrderId): Promise<Order | null> {
    const row = await this.db.table('orders').where({ id: id.value }).first();
    return row ? OrderMapper.toDomain(row) : null;  // persistence -> domain shape
  }
}
```

---

## Anti-pattern fix: Smart Controller (before / after)

```typescript
// ❌ BEFORE — business logic in the controller
app.post('/orders/:id/submit', async (req, res) => {
  const order = await db.orders.findById(req.params.id);
  if (order.status !== 'draft') {                 // business rule, wrong layer
    return res.status(400).json({ error: 'Cannot submit' });
  }
  order.status = 'submitted';
  await db.orders.update(order);
  await emailService.send(order.customerEmail, 'Order submitted');  // concrete dependency
  res.json({ status: 'submitted' });
});

// ✅ AFTER — controller only translates HTTP <-> Use Case
app.post('/orders/:id/submit', (req, res) =>
  orderController.handleSubmit(req, res)
);
// business rule now lives in Order.submit() (Entity)
// orchestration now lives in SubmitOrderUseCase (Use Case)
```

---

## Executable unit test example (Jest)

```typescript
describe('SubmitOrderUseCase', () => {
  it('submits a draft order and notifies the customer', async () => {
    // Arrange — fakes implementing the Ports, not real infrastructure
    const fakeOrder = Order.create(OrderId.from('o1'), [aLine()]);
    const repo: IOrderRepository = {
      findById: jest.fn().mockResolvedValue(fakeOrder),
      save: jest.fn().mockResolvedValue(undefined),
    };
    const notifier: INotificationSender = {
      notifyOrderSubmitted: jest.fn().mockResolvedValue(undefined),
    };
    const useCase = new SubmitOrderUseCase(repo, notifier);

    // Act
    const result = await useCase.execute({ orderId: 'o1' });

    // Assert — behavior, not implementation
    expect(result.status).toBe('submitted');
    expect(repo.save).toHaveBeenCalledWith(
      expect.objectContaining({ status: OrderStatus.Submitted })
    );
    expect(notifier.notifyOrderSubmitted).toHaveBeenCalledTimes(1);
  });

  it('throws when the order does not exist', async () => {
    const repo: IOrderRepository = {
      findById: jest.fn().mockResolvedValue(null),
      save: jest.fn(),
    };
    const useCase = new SubmitOrderUseCase(repo, fakeNotifier());

    await expect(useCase.execute({ orderId: 'missing' }))
      .rejects.toThrow(OrderNotFoundError);
  });
});
```

Zero DB calls, zero HTTP calls, runs in milliseconds — this is the concrete bar "testable without DB/Web" must meet.
