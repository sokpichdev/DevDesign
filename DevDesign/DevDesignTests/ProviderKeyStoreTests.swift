//
//  ProviderKeyStoreTests.swift
//  DevDesign
//

import XCTest
@testable import DevDesign

/// These tests touch the real Keychain, so every provider slot is cleared before and after
/// each case to keep them order-independent and to avoid leaking test keys onto the device.
final class ProviderKeyStoreTests: XCTestCase {

    private let legacyUDKeys = [
        "devdesign_anthropic_api_key",
        "devdesign_gemini_api_key",
        "devdesign_openrouter_api_key"
    ]

    override func setUp() {
        super.setUp()
        clearAll()
    }

    override func tearDown() {
        clearAll()
        super.tearDown()
    }

    private func clearAll() {
        for provider in AIProvider.allCases {
            ProviderKeyStore.clearKey(for: provider)
        }
        for key in legacyUDKeys {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    // MARK: - Round trip

    func test_saveThenLoad_returnsKey() {
        ProviderKeyStore.saveKey("sk-ant-test-1234", for: .anthropic)
        XCTAssertEqual(ProviderKeyStore.loadKey(for: .anthropic), "sk-ant-test-1234")
    }

    func test_save_overwritesExistingKey() {
        ProviderKeyStore.saveKey("sk-ant-first", for: .anthropic)
        ProviderKeyStore.saveKey("sk-ant-second", for: .anthropic)
        XCTAssertEqual(ProviderKeyStore.loadKey(for: .anthropic), "sk-ant-second",
                       "Saving twice must update in place, not add a duplicate item")
    }

    func test_clear_removesKey() {
        ProviderKeyStore.saveKey("sk-ant-test", for: .anthropic)
        ProviderKeyStore.clearKey(for: .anthropic)
        XCTAssertNil(ProviderKeyStore.loadKey(for: .anthropic))
    }

    func test_loadMissingKey_returnsNil() {
        XCTAssertNil(ProviderKeyStore.loadKey(for: .gemini))
    }

    func test_providersAreIsolated() {
        ProviderKeyStore.saveKey("anthropic-key", for: .anthropic)
        ProviderKeyStore.saveKey("gemini-key", for: .gemini)

        XCTAssertEqual(ProviderKeyStore.loadKey(for: .anthropic), "anthropic-key")
        XCTAssertEqual(ProviderKeyStore.loadKey(for: .gemini), "gemini-key")
        XCTAssertNil(ProviderKeyStore.loadKey(for: .openrouter))

        ProviderKeyStore.clearKey(for: .anthropic)
        XCTAssertNil(ProviderKeyStore.loadKey(for: .anthropic))
        XCTAssertEqual(ProviderKeyStore.loadKey(for: .gemini), "gemini-key",
                       "Clearing one provider must not affect another")
    }

    // MARK: - Keys must not be in UserDefaults

    func test_saveKey_doesNotWriteToUserDefaults() {
        ProviderKeyStore.saveKey("sk-ant-secret", for: .anthropic)

        for key in legacyUDKeys {
            XCTAssertNil(UserDefaults.standard.string(forKey: key),
                         "API keys must never be written to UserDefaults in plaintext")
        }
    }

    // MARK: - Legacy migration

    func test_migration_movesLegacyKeyIntoKeychain() {
        UserDefaults.standard.set("sk-ant-legacy", forKey: "devdesign_anthropic_api_key")

        APIKeyStore.migrateToProviderStore()

        XCTAssertEqual(ProviderKeyStore.loadKey(for: .anthropic), "sk-ant-legacy")
        XCTAssertNil(UserDefaults.standard.string(forKey: "devdesign_anthropic_api_key"),
                     "The plaintext copy must be removed after migrating")
    }

    func test_migration_isIdempotent() {
        UserDefaults.standard.set("sk-ant-legacy", forKey: "devdesign_anthropic_api_key")

        APIKeyStore.migrateToProviderStore()
        APIKeyStore.migrateToProviderStore()   // second run must be a no-op

        XCTAssertEqual(ProviderKeyStore.loadKey(for: .anthropic), "sk-ant-legacy")
    }

    func test_migration_doesNotOverwriteExistingKeychainKey() {
        ProviderKeyStore.saveKey("sk-ant-current", for: .anthropic)
        UserDefaults.standard.set("sk-ant-stale", forKey: "devdesign_anthropic_api_key")

        APIKeyStore.migrateToProviderStore()

        XCTAssertEqual(ProviderKeyStore.loadKey(for: .anthropic), "sk-ant-current",
                       "A stale UserDefaults value must not clobber the Keychain entry")
        XCTAssertNil(UserDefaults.standard.string(forKey: "devdesign_anthropic_api_key"),
                     "The stale plaintext copy should still be cleaned up")
    }

    func test_migration_ignoresWhitespaceOnlyLegacyValue() {
        UserDefaults.standard.set("   ", forKey: "devdesign_gemini_api_key")

        APIKeyStore.migrateToProviderStore()

        XCTAssertNil(ProviderKeyStore.loadKey(for: .gemini),
                     "A blank legacy value should not become a stored key")
        XCTAssertNil(UserDefaults.standard.string(forKey: "devdesign_gemini_api_key"))
    }

    func test_migration_withNothingToMigrate_doesNothing() {
        APIKeyStore.migrateToProviderStore()

        for provider in AIProvider.allCases {
            XCTAssertNil(ProviderKeyStore.loadKey(for: provider))
        }
    }

    // MARK: - Selected provider

    func test_selectedProvider_roundTrips() {
        ProviderKeyStore.saveSelectedProvider(.gemini)
        XCTAssertEqual(ProviderKeyStore.loadSelectedProvider(), .gemini)
    }

    func test_selectedProvider_defaultsToOpenRouter() {
        UserDefaults.standard.removeObject(forKey: "devdesign_selected_provider")
        XCTAssertEqual(ProviderKeyStore.loadSelectedProvider(), .openrouter)
    }
}
