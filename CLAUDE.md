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
- Service registration: `Sources/OversizeAppStoreServices/ServiceRegistering.swift`
- Usage pattern:
```swift
@Injected(\.appsService) private var appsService: AppsService
@Injected(\.cacheService) private var cacheService: CacheService
```

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

**CacheService** (`Sources/OversizeAppStoreServices/Cache/СacheService.swift`):
- File-based persistence using FileManager
- Default TTL: 5 minutes (configurable)
- Generic `fetchWithCache()` method pattern
- Automatic invalidation by file modification date
- Force refresh support

### Error Handling

All service methods return `Result<T, Error>`:
- No exceptions thrown
- Graceful degradation when client initialization fails
- Custom error mapping from AppStoreConnect ResponseError
- User-friendly error messages via AppError.message

### Data Flow

```
Service Method Call
→ Check Cache (unless force: true)
→ Return cached Result if valid
→ Fetch from AppStoreConnectClient if needed
→ Transform API response to domain models
→ Save to cache
→ Return Result<T, Error>
```

## Code Organization

```
Sources/
├── OversizeAppStoreServices/
│   ├── Auth/                    # EnvAuthenticator, NetworkEnvironment
│   ├── Cache/                   # CacheService (file-based)
│   ├── Models/                  # 30+ data models
│   │   └── Types/              # Type-safe enums (SubscriptionPeriod, Platform, etc.)
│   ├── Services/               # 12 actor-based services
│   └── ServiceRegistering.swift # Factory DI registration
│
├── OversizeMetricServices/
│   ├── Models/                  # FinanceReport, SalesReport, InstallReport
│   └── Services/               # AnalyticsService, SalesAndFinanceService, PerfPowerMetricsService
│
Tests/
└── OversizeAppStoreServicesTests/  # 18 test files using Swift Testing framework
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

## Key Dependencies

- **asc-swift** (1.0.1+): App Store Connect API client
- **Factory** (2.1.3+): Dependency injection container
- **GzipSwift** (6.1.0+): Gzip decompression for report downloads
- **CodableCSV** (0.6.7+): CSV parsing for finance/sales reports
- **OversizeCore**: Logging utilities (logError, logData, logNetwork)
- **OversizeServices**: SecureStorageService, AppError
- **OversizeModels**: Domain models (App, InAppPurchase, etc.)

## Common Patterns

### Creating a New Service
1. Define as `public actor ServiceName`
2. Initialize `AppStoreConnectClient` with `EnvAuthenticator()`
3. Use `Result<T, Error>` return types
4. Implement caching with `@Injected(\.cacheService)`
5. Register in `ServiceRegistering.swift`

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
