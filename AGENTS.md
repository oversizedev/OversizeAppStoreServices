# Repository Guidelines

## Project Structure & Module Organization
- `Package.swift` defines a Swift Package with three main modules.
- `Sources/OversizeAppStoreServices/` contains actor-based App Store Connect services, auth, cache, and related models.
- `Sources/OversizeMetricServices/` contains analytics and reporting services and their models.
- `Sources/OversizeAppStoreModels/` holds shared models, types, and extensions.
- `Tests/OversizeAppStoreServicesTests/` contains Swift Testing suites for enums, models, and API mappings.

## Build, Test, and Development Commands
- `swift build` builds the package targets.
- `swift test` runs all Swift Testing suites.
- `swift test --filter TerritoryTests` runs a single test suite.
- `open Package.swift` opens the package in Xcode.

## Coding Style & Naming Conventions
- Swift 6 with strict concurrency; prefer async/await and `actor` for services.
- Indentation: 4 spaces; format with `swiftformat .` (see `.swiftformat`).
- Types use `UpperCamelCase`; methods and properties use `lowerCamelCase`.
- Return `Result<T, AppError>` from service APIs; avoid throwing where patterns already exist.
- Keep code comments minimal; use `// MARK:` for sectioning when needed.

## Testing Guidelines
- Framework: Swift Testing (`@Suite`, `@Test`), not XCTest.
- Test files end with `Tests.swift`; suites are named after the type under test (e.g., `TerritoryTests`).
- Focus on model initializers, enum parsing, and API schema mapping behavior.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and capitalized (e.g., `Fix cache path`, `Add AppMediaAssetState`).
- Issue references may appear in parentheses (e.g., `Fix auth (#14)`).
- Pull requests should include: concise summary, linked issue (if any), and test output (`swift test`).

## Configuration & Dependencies
- Dependencies can be toggled between local and remote in `Package.swift` (`localDependencies` vs `remoteDependencies`).
- Auth uses `EnvAuthenticator` and reads credentials from Keychain or `.env` via `NetworkEnvironment`.
