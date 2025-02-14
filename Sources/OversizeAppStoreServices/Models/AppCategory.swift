//
// Copyright © 2024 Alexander Romanov
// AppCategory.swift, created on 02.11.2024
//

import AppStoreAPI

import Foundation
import OversizeCore
import SwiftUI

public struct AppCategory: Identifiable, Sendable {
    public let id: String
    public let platforms: [Platform]

    public let relationships: Relationships?
    public let included: Included?

    init?(schema: AppStoreAPI.AppCategory, included: [AppStoreAPI.AppCategory]? = nil) {
        id = schema.id
        platforms = schema.attributes?.platforms?.compactMap { .init(rawValue: $0.rawValue) } ?? []

        let subcategoryIds: [String]? = schema.relationships?.subcategories?.data?
            .compactMap { $0.id }

        relationships = .init(
            subcategoryIds: subcategoryIds
        )

        guard let included else {
            self.included = nil
            return
        }

        self.included = .init(subCategories: subcategoryIds?.compactMap { subcategoryId in
            if let subcategory = included.first(where: { $0.id == subcategoryId }) {
                .init(schema: subcategory)
            } else {
                nil
            }
        })
    }

    public struct Relationships: Sendable {
        let subcategoryIds: [String]?
    }

    public struct Included: Sendable {
        public let subCategories: [AppCategory]?
    }
}

public extension AppCategory {
    var displayName: String {
        switch id {
        case "STICKERS_EMOJI_AND_EXPRESSIONS": "Emoji & Expressions"
        case "GAMES_ACTION": "Action Games"
        case "BUSINESS": "Business"
        case "SOCIAL_NETWORKING": "Social Networking"
        case "GAMES_STRATEGY": "Strategy Games"
        case "GAMES_SPORTS": "Sports Games"
        case "STICKERS_CELEBRATIONS": "Celebrations"
        case "STICKERS": "Stickers"
        case "GAMES": "Games"
        case "GAMES_CASUAL": "Casual Games"
        case "STICKERS_SPORTS_AND_ACTIVITIES": "Sports & Activities"
        case "GAMES_TRIVIA": "Trivia Games"
        case "STICKERS_EATING_AND_DRINKING": "Eating & Drinking"
        case "STICKERS_CHARACTERS": "Characters"
        case "MEDICAL": "Medical"
        case "GAMES_PUZZLE": "Puzzle Games"
        case "GAMES_CASINO": "Casino Games"
        case "GAMES_FAMILY": "Family Games"
        case "STICKERS_PLACES_AND_OBJECTS": "Places & Objects"
        case "FOOD_AND_DRINK": "Food & Drink"
        case "GAMES_ADVENTURE": "Adventure Games"
        case "GAMES_BOARD": "Board Games"
        case "EDUCATION": "Education"
        case "BOOKS": "Books"
        case "SPORTS": "Sports"
        case "FINANCE": "Finance"
        case "REFERENCE": "Reference"
        case "GAMES_RACING": "Racing Games"
        case "DEVELOPER_TOOLS": "Developer Tools"
        case "GRAPHICS_AND_DESIGN": "Graphics & Design"
        case "HEALTH_AND_FITNESS": "Health & Fitness"
        case "MUSIC": "Music"
        case "ENTERTAINMENT": "Entertainment"
        case "TRAVEL": "Travel"
        case "WEATHER": "Weather"
        case "GAMES_WORD": "Word Games"
        case "STICKERS_CELEBRITIES": "Celebrities"
        case "LIFESTYLE": "Lifestyle"
        case "GAMES_MUSIC": "Music Games"
        case "GAMES_ROLE_PLAYING": "Role Playing Games"
        case "STICKERS_MOVIES_AND_TV": "Movies & TV"
        case "GAMES_CARD": "Card Games"
        case "STICKERS_ANIMALS": "Animals"
        case "MAGAZINES_AND_NEWSPAPERS": "Magazines & Newspapers"
        case "STICKERS_ART": "Art"
        case "STICKERS_FASHION": "Fashion"
        case "UTILITIES": "Utilities"
        case "STICKERS_GAMING": "Gaming"
        case "SHOPPING": "Shopping"
        case "NEWS": "News"
        case "PRODUCTIVITY": "Productivity"
        case "GAMES_SIMULATION": "Simulation Games"
        case "NAVIGATION": "Navigation"
        case "PHOTO_AND_VIDEO": "Photo & Video"
        default: "Other"
        }
    }

    var image: Image {
        switch id {
        case "STICKERS_EMOJI_AND_EXPRESSIONS": Image(systemName: "face.smiling.fill")
        case "GAMES_ACTION": Image(systemName: "gamecontroller.fill")
        case "BUSINESS": Image(systemName: "briefcase.fill")
        case "SOCIAL_NETWORKING": Image(systemName: "person.2.fill")
        case "GAMES_STRATEGY": Image(systemName: "puzzlepiece.fill")
        case "GAMES_SPORTS": Image(systemName: "sportscourt.fill")
        case "STICKERS_CELEBRATIONS": Image(systemName: "party.popper.fill")
        case "STICKERS": Image(systemName: "face.smiling.fill")
        case "GAMES": Image(systemName: "gamecontroller.fill")
        case "GAMES_CASUAL": Image(systemName: "die.face.4.fill")
        case "STICKERS_SPORTS_AND_ACTIVITIES": Image(systemName: "bicycle.circle.fill")
        case "GAMES_TRIVIA": Image(systemName: "questionmark.circle.fill")
        case "STICKERS_EATING_AND_DRINKING": Image(systemName: "fork.knife.circle.fill")
        case "STICKERS_CHARACTERS": Image(systemName: "person.crop.circle.fill")
        case "MEDICAL": Image(systemName: "cross.case.fill")
        case "GAMES_PUZZLE": Image(systemName: "puzzlepiece.extension.fill")
        case "GAMES_CASINO": Image(systemName: "suit.club.fill")
        case "GAMES_FAMILY": Image(systemName: "person.3.fill")
        case "STICKERS_PLACES_AND_OBJECTS": Image(systemName: "location.circle.fill")
        case "FOOD_AND_DRINK": Image(systemName: "fork.knife")
        case "GAMES_ADVENTURE": Image(systemName: "star.circle.fill")
        case "GAMES_BOARD": Image(systemName: "checkerboard.rectangle")
        case "EDUCATION": Image(systemName: "book.fill")
        case "BOOKS": Image(systemName: "books.vertical.fill")
        case "SPORTS": Image(systemName: "sportscourt.fill")
        case "FINANCE": Image(systemName: "banknote.fill")
        case "REFERENCE": Image(systemName: "magnifyingglass.circle.fill")
        case "GAMES_RACING": Image(systemName: "car.fill")
        case "DEVELOPER_TOOLS": Image(systemName: "hammer.fill")
        case "GRAPHICS_AND_DESIGN": Image(systemName: "paintpalette.fill")
        case "HEALTH_AND_FITNESS": Image(systemName: "heart.fill")
        case "MUSIC": Image(systemName: "music.note")
        case "ENTERTAINMENT": Image(systemName: "tv.fill")
        case "TRAVEL": Image(systemName: "airplane")
        case "WEATHER": Image(systemName: "cloud.sun.fill")
        case "GAMES_WORD": Image(systemName: "textformat.abc")
        case "STICKERS_CELEBRITIES": Image(systemName: "person.crop.circle.badge.checkmark")
        case "LIFESTYLE": Image(systemName: "leaf.fill")
        case "GAMES_MUSIC": Image(systemName: "guitars.fill")
        case "GAMES_ROLE_PLAYING": Image(systemName: "shield.fill")
        case "STICKERS_MOVIES_AND_TV": Image(systemName: "film.fill")
        case "GAMES_CARD": Image(systemName: "suit.heart.fill")
        case "STICKERS_ANIMALS": Image(systemName: "pawprint.fill")
        case "MAGAZINES_AND_NEWSPAPERS": Image(systemName: "newspaper.fill")
        case "STICKERS_ART": Image(systemName: "paintbrush.fill")
        case "STICKERS_FASHION": Image(systemName: "tshirt.fill")
        case "UTILITIES": Image(systemName: "gearshape.fill")
        case "STICKERS_GAMING": Image(systemName: "gamecontroller.fill")
        case "SHOPPING": Image(systemName: "cart.fill")
        case "NEWS": Image(systemName: "newspaper.fill")
        case "PRODUCTIVITY": Image(systemName: "calendar")
        case "GAMES_SIMULATION": Image(systemName: "simcard.fill")
        case "NAVIGATION": Image(systemName: "location.north.line.fill")
        case "PHOTO_AND_VIDEO": Image(systemName: "camera.fill")
        default: Image(systemName: "questionmark.circle.fill")
        }
    }
}
