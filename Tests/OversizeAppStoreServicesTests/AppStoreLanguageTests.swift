//
// Copyright © 2025 Aleksandr Romanov
// AppStoreLanguageTests.swift, created on 06.02.2025
//  

import Testing
@testable import OversizeAppStoreServices
import AppStoreAPI

@Suite struct AppStoreLanguageTests {
    @Test("Should have correct raw values")
    func testRawValues() throws {
        #expect(AppStoreLanguage.englishUS.rawValue == "en-US")
        #expect(AppStoreLanguage.russian.rawValue == "ru")
        #expect(AppStoreLanguage.japanese.rawValue == "ja")
        #expect(AppStoreLanguage.chineseSimplified.rawValue == "zh-Hans")
        #expect(AppStoreLanguage.spanishMEX.rawValue == "es-MX")
    }
    
    @Test("Should have correct display names")
    func testDisplayNames() throws {
        #expect(AppStoreLanguage.englishUS.displayName == "English (US)")
        #expect(AppStoreLanguage.russian.displayName == "Russian")
        #expect(AppStoreLanguage.japanese.displayName == "Japanese")
        #expect(AppStoreLanguage.chineseSimplified.displayName == "Chinese (Simplified)")
        #expect(AppStoreLanguage.spanishMEX.displayName == "Spanish (Mexico)")
    }
    
    @Test("Should have correct flag emojis")
    func testFlagEmojis() throws {
        #expect(AppStoreLanguage.englishUS.flagEmoji == "🇺🇸")
        #expect(AppStoreLanguage.russian.flagEmoji == "🇷🇺")
        #expect(AppStoreLanguage.japanese.flagEmoji == "🇯🇵")
        #expect(AppStoreLanguage.chineseSimplified.flagEmoji == "🇨🇳")
        #expect(AppStoreLanguage.spanishMEX.flagEmoji == "🇲🇽")
    }
    
    @Test("Should conform to Identifiable correctly")
    func testIdentifiable() throws {
        #expect(AppStoreLanguage.englishUS.id == "en-US")
        #expect(AppStoreLanguage.russian.id == "ru")
        #expect(AppStoreLanguage.japanese.id == "ja")
    }
}
