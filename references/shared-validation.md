# Shared Validation Logic (Avoiding Duplication Across Use Cases)

When multiple Use Cases need the same rule (e.g. "email must be well-formed"), the fix is almost never "extract a shared validator function called from each Use Case" — that's procedural thinking leaking into an OO/domain model. Instead:

- **Push it into a Value Object.** An `Email` Value Object validates its own shape in its constructor/factory method; any Use Case that needs an email just constructs `Email.create(raw)` and gets the validation for free, with no duplication and no shared utility function to keep in sync.
- **Reserve shared validator utilities** for pure input-shape checks that don't represent a domain concept (e.g. "is this a valid ISO date string") — those can live as small stateless helpers in the Application or Adapter layer, not the Domain layer.
