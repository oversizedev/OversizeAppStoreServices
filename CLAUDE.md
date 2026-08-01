# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OversizeAppStoreServices - Swift Package providing actor-based services for App Store Connect API operations and analytics reporting. Two main modules:
- **OversizeAppStoreServices**: Core App Store Connect API wrapper (apps, subscriptions, in-app purchases, versions, reviews)
- **OversizeMetricServices**: Analytics, sales reports, finance reports, and performance metrics

Target platforms: iOS 16+, macOS 13+, tvOS 16+, watchOS 9+

## Build and Test Commands

### Building
```bash
swift build
```

### Running Tests
```bash
# Run all tests
swift test

# Run specific test suite
swift test --filter TerritoryTests

# Run single test
swift test --filter TerritoryTests/initWithValidSchema
```

### Opening in Xcode
```bash
open Package.swift
```

## Package Dependencies Management

The `Package.swift` has **two dependency configurations**:
- `remoteDependencies`: Uses packages from GitHub
- `localDependencies`: Uses local file paths (../OversizeCore, ../OversizeModels, ../OversizeServices)

**Current configuration**: `localDependencies` (line 25)

When switching between local and remote development, modify line 25:
```swift
let dependencies: [PackageDescription.Package.Dependency] = localDependencies  // or remoteDependencies
```

## Architecture

### Actor-Based Service Pattern
All services are Swift 6 `actor` types for thread-safe concurrency:
```swift
public actor AppsService { ... }
public actor SubscriptionsService { ... }
```

### Dependency Injection
Uses **Factory Kit** for service registration and injection:
- Service registration: `Sources/OversizeAppStoreServices/DI/ServiceRegistering.swift`
- Usage pattern:
```swift
@Injected(\.appsService) private var appsService: AppsService
```
There is no DI entry for caching: the cache stack is created by the services themselves (see below).

### Core Services (OversizeAppStoreServices)

12 actor-based services organized by domain:

| Service | Responsibility | Key Operations |
|---------|---------------|----------------|
| AppsService | App metadata management | Fetch apps, patch primary language, manage bundle IDs |
| SubscriptionsService | Subscription lifecycle | Groups, offers, pricing, localizations, promotional offers |
| InAppPurchasesService | In-App Purchase management | V2 API, pricing schedules, CRUD operations |
| VersionsService | App version management | Create, update, submit versions |
| AppInfoService | App information | Age ratings, categories, app info localizations |
| BuildsService | Build management | Fetch builds, build details |
| CustomerReviewService | Customer reviews | Fetch reviews, respond to reviews |
| AppStoreReviewService | App review submission | Review details, attachments, submission notes |
| AppCategoryService | Category browsing | Primary/secondary categories, subcategories |
| CertificateService | Certificate management | Fetch certificates |
| UsersService | User management | Fetch App Store Connect users |
| reviewSubmissionsService | Version submissions | Submission status tracking |

### Metric Services (OversizeMetricServices)

3 services for analytics and reporting:
- **AnalyticsService**: App analytics reports
- **SalesAndFinanceService**: Sales/finance/install reports (CSV/Gzip parsing)
- **PerfPowerMetricsService**: Xcode performance and power metrics

### Authentication System

**EnvAuthenticator** (`Sources/OversizeAppStoreServices/Auth/EnvAuthenticator.swift`):
- Loads credentials from Keychain via SecureStorageService
- Account selection via UserDefaults
- Generates JWT tokens (20-minute expiration)
- Implements `Authenticator` protocol from asc-swift

**NetworkEnvironment**: Loads `.env` file variables with fallback to ProcessInfo

### Caching Layer

Everything is built on Foundation's `URLCache` (`Sources/OversizeAppStoreServices/Cache/`). The whole stack is Darwin-only — on Linux it degrades to no caching, without `#if` at call sites.

**HTTP responses** — `ASCCachingTransport` (an asc-swift `Transport`) stamps GET requests with TTL/force/scope via `URLProtocol.setProperty`, `ASCCachingURLProtocol` serves hits from `ASCResponseCache` and stores misses. Wrap reads in a policy to enable it:
```swift
await ASCCache.cached(ttl: ASCCache.TTL.short, force: force) {
    try await client.send(Resources.v1.apps.id(id).get())
}
```
Unstamped requests are never cached. TTL constants: `short` (1 min), `default` (5 min), `long` (1 h), `veryLong` (24 h), `month` (30 d). Clients are built by `ASCClientFactory.makeClient(authenticator:cacheAccountID:)`, which pins the account at construction time.

**Derived values** — `ASCValueCache` (`load`/`save`/`remove`) for small computed values that are not the body of a single HTTP response, currently only the daily proceeds aggregates in `SalesAndFinanceService`. One `URLCache` pool (2 MB / 64 MB), keys are synthetic `https://asc-value.invalid/<namespace>/<sha256(key)>` URLs. Analytics report data is deliberately NOT cached: segment URLs are single-use, and the merged tables were large enough to make caching them cost more than it saved. Keep this cache for kilobyte-sized values.

**Manual TTL** — App Store Connect sends no `Cache-Control`/`ETag`/`Last-Modified`, so entries are written with a synthesized `Cache-Control: max-age=N` plus an `X-ASC-Cached-At` timestamp that freshness is checked against.

**Scoping and invalidation** (`ASCCacheScope`) — the account ID and a generation counter are part of every key (`__ascScope`), so accounts are isolated structurally and switching accounts needs no flush. Two independent counters: mutating requests (POST/PATCH/PUT/DELETE) bump the response generation only, so 30-day derived values survive writes; `invalidateCurrentAccount()` drops HTTP responses, `invalidateAllCurrentAccount()` drops derived values too.

**Important**: `URLCache.removeCachedResponse`/`removeAllCachedResponses` do NOT evict manually stored entries — invalidation is done by overwriting the entry with an expired timestamp.

### Error Handling

All service methods return `Result<T, Error>`:
- No exceptions thrown
- Graceful degradation when client initialization fails
- Custom error mapping from AppStoreConnect ResponseError
- User-friendly error messages via AppError.message

### Data Flow

HTTP responses:
```
Service Method Call
→ ASCCache.cached sets the TaskLocal policy (ttl, force)
→ ASCCachingTransport stamps the URLRequest with ttl/force/account scope
→ ASCCachingURLProtocol builds the scoped key, checks freshness
→ Hit: replay stored response  |  Miss: network → store on 2xx
→ asc-swift decodes the response (errors and rate limits stay intact)
→ Transform API response to domain models
→ Return Result<T, Error>
```

Derived values:
```
Service Method Call
→ ASCValueCache builds the scoped synthetic key
→ Return decoded value if fresh
→ Otherwise run the fetcher, encode, store with the injected TTL
→ Return Result<T, Error>
```

## Code Organization

```
Sources/
├── OversizeAppStoreServices/
│   ├── Auth/                    # EnvAuthenticator, NetworkEnvironment
│   ├── Cache/                   # URLCache stack: ASCCachePolicy, ASCCacheScope,
│   │                            # ASCResponseCache, ASCCachingURLProtocol,
│   │                            # ASCCachingTransport, ASCClientFactory,
│   │                            # ASCValueCache, ASCCacheInvalidationBox
│   ├── DI/                      # ServiceRegistering.swift (Factory DI registration)
│   ├── Models/                  # 30+ data models
│   │   └── Types/              # Type-safe enums (SubscriptionPeriod, Platform, etc.)
│   └── Services/               # 12 actor-based services
│
├── OversizeMetricServices/
│   ├── Models/                  # FinanceReport, SalesReport, InstallReport
│   └── Services/               # AnalyticsService, SalesAndFinanceService, PerfPowerMetricsService
│
Tests/
└── OversizeAppStoreServicesTests/  # 22 test files using Swift Testing framework
```

## Testing Infrastructure

Uses **Swift Testing** framework (not XCTest):
```swift
@Suite struct TerritoryTests {
    @Test("Test description")
    func testMethod() throws { ... }
}
```

Test coverage focuses on:
- Model initialization from API schemas
- Type enum parsing and mappings
- Territory handling with currencies
- Display name validation
- The cache stack: `ASCResponseCacheTests`, `ASCCachingTransportTests`, `ASCValueCacheTests`

Cache-suite conventions:
- `@Suite(.serialized)` for suites that mutate process-global cache state
- Injection seams: `ASCCachingURLProtocol.cache` / `.innerSession` and `ASCValueCacheStorage.shared`
- Caches point at a fresh temp directory, and every test uses its own UUID account ID so generation counters never collide with other suites
- `StubURLProtocol` (in `ASCCachingTransportTests`) counts network hits

## Key Dependencies

- **asc-swift** (1.7.0+): App Store Connect API client
- **Factory** (3.0.2+): Dependency injection container
- **GzipSwift** (7.0.0+): Gzip decompression for report downloads
- **CodableCSV** (0.6.7+): CSV parsing for finance/sales reports
- **swift-crypto** (4.0.0+): SHA-256 on non-Darwin platforms
- **OversizeCore**: Logging utilities (logError, logData, logNetwork)
- **OversizeServices**: SecureStorageService, AppError

## Common Patterns

### Creating a New Service
1. Define as `public actor ServiceName`
2. Build the client with `ASCClientFactory.makeClient(authenticator:cacheAccountID:)`
3. Use `Result<T, Error>` return types
4. Wrap cacheable reads in `ASCCache.cached(ttl:force:)`; use `ASCValueCache` only for derived values that cannot be keyed by URL
5. Register in `DI/ServiceRegistering.swift`

### Adding New Models
1. Create model in `Sources/OversizeAppStoreServices/Models/`
2. Add custom initializer from AppStoreAPI schema
3. Conform to `Codable` and `Sendable` (Swift 6)
4. Add type enums in `Models/Types/` if needed

### Type Enums
All type enums should provide:
- `RawValue` mapping to API strings
- `displayName` for UI presentation
- `Codable` and `Sendable` conformance
- `CaseIterable` for exhaustive lists

## Swift 6 Concurrency

This codebase uses Swift 6 strict concurrency:
- All services are `actor` types
- Models conform to `Sendable`
- Async/await throughout (no completion handlers)
- No `@unchecked Sendable` unless necessary

## Authentication Setup

Services require App Store Connect API credentials stored in Keychain:
- Key ID
- Issuer ID
- Private Key (P8 file content)

Account selection managed via UserDefaults with key from SecureStorageService.
