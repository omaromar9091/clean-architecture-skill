# File Granularity (Don't Over-Fragment Small Features)

The layer diagram describes *responsibilities*, not a mandatory file count. Scale file count to feature size:

- **Small feature (Tier 2, low complexity):** one file per layer is fine — e.g. `CreateTagUseCase.ts` can contain the Use Case *and* its Port interface *and* its DTOs if each is a handful of lines. Splitting a 15-line feature into 6 files is not rigor, it's noise.
- **Medium/large feature:** split when a single file would mix concerns a reader needs to scan past — separate Ports from DTOs from the interactor once each grows past roughly a screenful.
- **Never merge across layers** to save files — a Controller and a Use Case never belong in the same file, regardless of size, because that's a layer violation, not a file-count concern. Merging *within* a layer is fine; merging *across* layers is the boundary leak this skill exists to prevent.
