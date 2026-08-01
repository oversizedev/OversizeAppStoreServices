//
// Copyright © 2026 Alexander Romanov
// ASCCacheScope.swift, created on 30.07.2026
//

import Foundation

public enum ASCCacheScope {
    private static let accountDefaultsKey = "AppStore.Account"
    private static let generationPrefix = "ASCCache.generation."
    private static let valueGenerationPrefix = "ASCCache.valueGeneration."
    private static let generationLock = NSLock()

    static var accountID: String {
        normalized(UserDefaults.standard.string(forKey: accountDefaultsKey) ?? "none")
    }

    static var current: String {
        scope(for: accountID)
    }

    static func normalized(_ account: String) -> String {
        UUID(uuidString: account)?.uuidString ?? account
    }

    static func scope(for account: String) -> String {
        let account = normalized(account)
        return "\(account).\(generation(for: account))"
    }

    static func generation(for account: String) -> Int {
        UserDefaults.standard.integer(forKey: generationPrefix + normalized(account))
    }

    static func bumpGeneration(for account: String) {
        bump(prefix: generationPrefix, account: account)
    }

    // MARK: - Derived value scope

    static func valueScope(for account: String) -> String {
        let account = normalized(account)
        return "\(account).v\(valueGeneration(for: account))"
    }

    static func valueGeneration(for account: String) -> Int {
        UserDefaults.standard.integer(forKey: valueGenerationPrefix + normalized(account))
    }

    static func bumpValueGeneration(for account: String) {
        bump(prefix: valueGenerationPrefix, account: account)
    }

    // MARK: - Invalidation

    public static func invalidateCurrentAccount() {
        invalidate(accountID: accountID)
    }

    public static func invalidateAllCurrentAccount() {
        purge(accountID: accountID)
    }

    public static func invalidate(accountID: String) {
        bumpGeneration(for: accountID)
    }

    /// Makes every cached response and derived value of the account unreachable.
    /// The bytes themselves are reclaimed by the cache's own LRU eviction.
    public static func purge(accountID: String) {
        bumpGeneration(for: accountID)
        bumpValueGeneration(for: accountID)
    }

    private static func bump(prefix: String, account: String) {
        let key = prefix + normalized(account)
        generationLock.lock()
        defer { generationLock.unlock() }
        let next = UserDefaults.standard.integer(forKey: key) &+ 1
        UserDefaults.standard.set(next, forKey: key)
    }
}
