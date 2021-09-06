//
//  Country.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import Foundation

/// Model structure representing a competing country
public struct Country {
    /// Country name
    public var name: String
    /// Country flag as an emoji
    public var flagEmoji: String
    
    /// Pretty country name string, e.g. 'Italy 🇮🇹', 'Sweden 🇸🇪'
    public var prettyNameString: String {
        return "\(name) \(flagEmoji)"
    }
}

// Adopting Codable to be able to save data to disk
extension Country: Codable { }

// Adopting Hashable for UICollectionViewDiffableDataSource
extension Country: Hashable { }

// List of constants for countries that have ever participated in the contest
// Yugoslavia and 'Serbia and Montenegro' are represented by the EU flag since there are no emojis for these countries
// These should be excluded from the country list for contests that took place in 2006 and later
extension Country {
    public static let albania = Country(name: "Albania", flagEmoji: "🇦🇱")
    public static let andorra = Country(name: "Andorra", flagEmoji: "🇦🇩")
    public static let armenia = Country(name: "Armenia", flagEmoji: "🇦🇲")
    public static let australia = Country(name: "Australia", flagEmoji: "🇦🇺")
    public static let austria = Country(name: "Austria", flagEmoji: "🇦🇹")
    public static let azerbaijan = Country(name: "Azerbaijan", flagEmoji: "🇦🇿")
    public static let belarus = Country(name: "Belarus", flagEmoji: "🇧🇾")
    public static let belgium = Country(name: "Belgium", flagEmoji: "🇧🇪")
    public static let bosniaAndHerzegovina = Country(name: "Bosnia And Herzegovina", flagEmoji: "🇧🇦")
    public static let bulgaria = Country(name: "Bulgaria", flagEmoji: "🇧🇬")
    public static let croatia = Country(name: "Croatia", flagEmoji: "🇭🇷")
    public static let cyprus = Country(name: "Cyprus", flagEmoji: "🇨🇾")
    public static let czechRepublic = Country(name: "Czech Republic", flagEmoji: "🇨🇿")
    public static let denmark = Country(name: "Denmark", flagEmoji: "🇩🇰")
    public static let estonia = Country(name: "Estonia", flagEmoji: "🇪🇪")
    public static let finland = Country(name: "Finland", flagEmoji: "🇫🇮")
    public static let france = Country(name: "France", flagEmoji: "🇫🇷")
    public static let georgia = Country(name: "Georgia", flagEmoji: "🇬🇪")
    public static let germany = Country(name: "Germany", flagEmoji: "🇩🇪")
    public static let greece = Country(name: "Greece", flagEmoji: "🇬🇷")
    public static let hungary = Country(name: "Hungary", flagEmoji: "🇭🇺")
    public static let iceland = Country(name: "Iceland", flagEmoji: "🇮🇸")
    public static let ireland = Country(name: "Ireland", flagEmoji: "🇮🇪")
    public static let israel = Country(name: "Israel", flagEmoji: "🇮🇱")
    public static let italy = Country(name: "Italy", flagEmoji: "🇮🇹")
    public static let latvia = Country(name: "Latvia", flagEmoji: "🇱🇻")
    public static let lithuania = Country(name: "Lithuania", flagEmoji: "🇱🇹")
    public static let luxembourg = Country(name: "Luxembourg", flagEmoji: "🇱🇺")
    public static let malta = Country(name: "Malta", flagEmoji: "🇲🇹")
    public static let moldova = Country(name: "Moldova", flagEmoji: "🇲🇩")
    public static let monaco = Country(name: "Monaco", flagEmoji: "🇲🇨")
    public static let montenegro = Country(name: "Montenegro", flagEmoji: "🇲🇪")
    public static let morocco = Country(name: "Morocco", flagEmoji: "🇲🇦")
    public static let northMacedonia = Country(name: "North Macedonia", flagEmoji: "🇲🇰")
    public static let norway = Country(name: "Norway", flagEmoji: "🇳🇴")
    public static let poland = Country(name: "Poland", flagEmoji: "🇵🇱")
    public static let portugal = Country(name: "Portugal", flagEmoji: "🇵🇹")
    public static let romania = Country(name: "Romania", flagEmoji: "🇷🇴")
    public static let russia = Country(name: "Russia", flagEmoji: "🇷🇺")
    public static let sanMarino = Country(name: "San Marino", flagEmoji: "🇸🇲")
    public static let serbia = Country(name: "Serbia", flagEmoji: "🇷🇸")
    public static let serbiaAndMontenegro = Country(name: "Serbia and Montenegro", flagEmoji: "🇪🇺")
    public static let slovakia = Country(name: "Slovakia", flagEmoji: "🇸🇰")
    public static let slovenia = Country(name: "Slovenia", flagEmoji: "🇸🇮")
    public static let spain = Country(name: "Spain", flagEmoji: "🇪🇸")
    public static let sweden = Country(name: "Sweden", flagEmoji: "🇸🇪")
    public static let switzerland = Country(name: "Switzerland", flagEmoji: "🇨🇭")
    public static let turkey = Country(name: "Turkey", flagEmoji: "🇹🇷")
    public static let theNetherlands = Country(name: "The Netherlands", flagEmoji: "🇳🇱")
    public static let ukraine = Country(name: "Ukraine", flagEmoji: "🇺🇦")
    public static let unitedKingdom = Country(name: "United Kingdom", flagEmoji: "🇬🇧")
    public static let yugoslavia = Country(name: "Yugoslavia", flagEmoji: "🇪🇺")
}

// Country list as array for picker view
extension Country {
    /// Modern country list (2006 and later)
    public static let modernCountryList: [Country] = [
        .albania,
        .andorra,
        .armenia,
        .australia,
        .austria,
        .azerbaijan,
        .belarus,
        .belgium,
        .bosniaAndHerzegovina,
        .bulgaria,
        .croatia,
        .cyprus,
        .czechRepublic,
        .denmark,
        .estonia,
        .finland,
        .france,
        .georgia,
        .germany,
        .greece,
        .hungary,
        .iceland,
        .ireland,
        .israel,
        .italy,
        .latvia,
        .lithuania,
        .luxembourg,
        .malta,
        .moldova,
        .monaco,
        .montenegro,
        .morocco,
        .northMacedonia,
        .norway,
        .poland,
        .portugal,
        .romania,
        .russia,
        .sanMarino,
        .serbia,
        .slovakia,
        .slovenia,
        .spain,
        .sweden,
        .switzerland,
        .turkey,
        .theNetherlands,
        .ukraine,
        .unitedKingdom
    ].sorted { $0.name < $1.name}
    
    /// Full country list which includes countries that no longer exists
    public static let fullCountryList: [Country] = (modernCountryList + [.serbiaAndMontenegro, .yugoslavia]).sorted { $0.name < $1.name }
}
