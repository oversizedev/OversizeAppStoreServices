//
// Copyright © 2024 Alexander Romanov
// AppCategory.swift, created on 02.11.2024
//

import AppStoreAPI
import AppStoreConnect
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
            if let subcategory = included.first { $0.id == subcategoryId } {
                return .init(schema: subcategory)
            } else {
                return nil
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
        case "STICKERS_EMOJI_AND_EXPRESSIONS": return "Emoji & Expressions"
        case "GAMES_ACTION": return "Action Games"
        case "BUSINESS": return "Business"
        case "SOCIAL_NETWORKING": return "Social Networking"
        case "GAMES_STRATEGY": return "Strategy Games"
        case "GAMES_SPORTS": return "Sports Games"
        case "STICKERS_CELEBRATIONS": return "Celebrations"
        case "STICKERS": return "Stickers"
        case "GAMES": return "Games"
        case "GAMES_CASUAL": return "Casual Games"
        case "STICKERS_SPORTS_AND_ACTIVITIES": return "Sports & Activities"
        case "GAMES_TRIVIA": return "Trivia Games"
        case "STICKERS_EATING_AND_DRINKING": return "Eating & Drinking"
        case "STICKERS_CHARACTERS": return "Characters"
        case "MEDICAL": return "Medical"
        case "GAMES_PUZZLE": return "Puzzle Games"
        case "GAMES_CASINO": return "Casino Games"
        case "GAMES_FAMILY": return "Family Games"
        case "STICKERS_PLACES_AND_OBJECTS": return "Places & Objects"
        case "FOOD_AND_DRINK": return "Food & Drink"
        case "GAMES_ADVENTURE": return "Adventure Games"
        case "GAMES_BOARD": return "Board Games"
        case "EDUCATION": return "Education"
        case "BOOKS": return "Books"
        case "SPORTS": return "Sports"
        case "FINANCE": return "Finance"
        case "REFERENCE": return "Reference"
        case "GAMES_RACING": return "Racing Games"
        case "DEVELOPER_TOOLS": return "Developer Tools"
        case "GRAPHICS_AND_DESIGN": return "Graphics & Design"
        case "HEALTH_AND_FITNESS": return "Health & Fitness"
        case "MUSIC": return "Music"
        case "ENTERTAINMENT": return "Entertainment"
        case "TRAVEL": return "Travel"
        case "WEATHER": return "Weather"
        case "GAMES_WORD": return "Word Games"
        case "STICKERS_CELEBRITIES": return "Celebrities"
        case "LIFESTYLE": return "Lifestyle"
        case "GAMES_MUSIC": return "Music Games"
        case "GAMES_ROLE_PLAYING": return "Role Playing Games"
        case "STICKERS_MOVIES_AND_TV": return "Movies & TV"
        case "GAMES_CARD": return "Card Games"
        case "STICKERS_ANIMALS": return "Animals"
        case "MAGAZINES_AND_NEWSPAPERS": return "Magazines & Newspapers"
        case "STICKERS_ART": return "Art"
        case "STICKERS_FASHION": return "Fashion"
        case "UTILITIES": return "Utilities"
        case "STICKERS_GAMING": return "Gaming"
        case "SHOPPING": return "Shopping"
        case "NEWS": return "News"
        case "PRODUCTIVITY": return "Productivity"
        case "GAMES_SIMULATION": return "Simulation Games"
        case "NAVIGATION": return "Navigation"
        case "PHOTO_AND_VIDEO": return "Photo & Video"
        default: return "Other"
        }
    }

    var image: Image {
        switch id {
        case "STICKERS_EMOJI_AND_EXPRESSIONS": return Image(systemName: "face.smiling.fill")
        case "GAMES_ACTION": return Image(systemName: "gamecontroller.fill")
        case "BUSINESS": return Image(systemName: "briefcase.fill")
        case "SOCIAL_NETWORKING": return Image(systemName: "person.2.fill")
        case "GAMES_STRATEGY": return Image(systemName: "puzzlepiece.fill")
        case "GAMES_SPORTS": return Image(systemName: "sportscourt.fill")
        case "STICKERS_CELEBRATIONS": return Image(systemName: "party.popper.fill")
        case "STICKERS": return Image(systemName: "face.smiling.fill")
        case "GAMES": return Image(systemName: "gamecontroller.fill")
        case "GAMES_CASUAL": return Image(systemName: "die.face.4.fill")
        case "STICKERS_SPORTS_AND_ACTIVITIES": return Image(systemName: "bicycle.circle.fill")
        case "GAMES_TRIVIA": return Image(systemName: "questionmark.circle.fill")
        case "STICKERS_EATING_AND_DRINKING": return Image(systemName: "fork.knife.circle.fill")
        case "STICKERS_CHARACTERS": return Image(systemName: "person.crop.circle.fill")
        case "MEDICAL": return Image(systemName: "cross.case.fill")
        case "GAMES_PUZZLE": return Image(systemName: "puzzlepiece.extension.fill")
        case "GAMES_CASINO": return Image(systemName: "suit.club.fill")
        case "GAMES_FAMILY": return Image(systemName: "person.3.fill")
        case "STICKERS_PLACES_AND_OBJECTS": return Image(systemName: "location.circle.fill")
        case "FOOD_AND_DRINK": return Image(systemName: "fork.knife")
        case "GAMES_ADVENTURE": return Image(systemName: "star.circle.fill")
        case "GAMES_BOARD": return Image(systemName: "checkerboard.rectangle")
        case "EDUCATION": return Image(systemName: "book.fill")
        case "BOOKS": return Image(systemName: "books.vertical.fill")
        case "SPORTS": return Image(systemName: "sportscourt.fill")
        case "FINANCE": return Image(systemName: "banknote.fill")
        case "REFERENCE": return Image(systemName: "magnifyingglass.circle.fill")
        case "GAMES_RACING": return Image(systemName: "car.fill")
        case "DEVELOPER_TOOLS": return Image(systemName: "hammer.fill")
        case "GRAPHICS_AND_DESIGN": return Image(systemName: "paintpalette.fill")
        case "HEALTH_AND_FITNESS": return Image(systemName: "heart.fill")
        case "MUSIC": return Image(systemName: "music.note")
        case "ENTERTAINMENT": return Image(systemName: "tv.fill")
        case "TRAVEL": return Image(systemName: "airplane")
        case "WEATHER": return Image(systemName: "cloud.sun.fill")
        case "GAMES_WORD": return Image(systemName: "textformat.abc")
        case "STICKERS_CELEBRITIES": return Image(systemName: "person.crop.circle.badge.checkmark")
        case "LIFESTYLE": return Image(systemName: "leaf.fill")
        case "GAMES_MUSIC": return Image(systemName: "guitars.fill")
        case "GAMES_ROLE_PLAYING": return Image(systemName: "shield.fill")
        case "STICKERS_MOVIES_AND_TV": return Image(systemName: "film.fill")
        case "GAMES_CARD": return Image(systemName: "suit.heart.fill")
        case "STICKERS_ANIMALS": return Image(systemName: "pawprint.fill")
        case "MAGAZINES_AND_NEWSPAPERS": return Image(systemName: "newspaper.fill")
        case "STICKERS_ART": return Image(systemName: "paintbrush.fill")
        case "STICKERS_FASHION": return Image(systemName: "tshirt.fill")
        case "UTILITIES": return Image(systemName: "gearshape.fill")
        case "STICKERS_GAMING": return Image(systemName: "gamecontroller.fill")
        case "SHOPPING": return Image(systemName: "cart.fill")
        case "NEWS": return Image(systemName: "newspaper.fill")
        case "PRODUCTIVITY": return Image(systemName: "calendar")
        case "GAMES_SIMULATION": return Image(systemName: "simcard.fill")
        case "NAVIGATION": return Image(systemName: "location.north.line.fill")
        case "PHOTO_AND_VIDEO": return Image(systemName: "camera.fill")
        default: return Image(systemName: "questionmark.circle.fill")
        }
    }
}
