//
//  Country.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import Foundation

/// Model structure representing a competing country
struct Country {
    /// Country name
    var name: String
    /// Country flag as an emoji
    var flagEmoji: String
    
    /// Pretty country name string, e.g. 'Italy 🇮🇹', 'Sweden 🇸🇪'
    var prettyNameString: String {
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
    static let albania = Country(name: "Albania", flagEmoji: "🇦🇱")
    static let andorra = Country(name: "Andorra", flagEmoji: "🇦🇩")
    static let armenia = Country(name: "Armenia", flagEmoji: "🇦🇲")
    static let australia = Country(name: "Australia", flagEmoji: "🇦🇺")
    static let austria = Country(name: "Austria", flagEmoji: "🇦🇹")
    static let azerbaijan = Country(name: "Azerbaijan", flagEmoji: "🇦🇿")
    static let belarus = Country(name: "Belarus", flagEmoji: "🇧🇾")
    static let belgium = Country(name: "Belgium", flagEmoji: "🇧🇪")
    static let bosniaAndHerzegovina = Country(name: "Bosnia And Herzegovina", flagEmoji: "🇧🇦")
    static let bulgaria = Country(name: "Bulgaria", flagEmoji: "🇧🇬")
    static let croatia = Country(name: "Croatia", flagEmoji: "🇭🇷")
    static let cyprus = Country(name: "Cyprus", flagEmoji: "🇨🇾")
    static let czechRepublic = Country(name: "Czech Republic", flagEmoji: "🇨🇿")
    static let denmark = Country(name: "Denmark", flagEmoji: "🇩🇰")
    static let estonia = Country(name: "Estonia", flagEmoji: "🇪🇪")
    static let finland = Country(name: "Finland", flagEmoji: "🇫🇮")
    static let france = Country(name: "France", flagEmoji: "🇫🇷")
    static let georgia = Country(name: "Georgia", flagEmoji: "🇬🇪")
    static let germany = Country(name: "Germany", flagEmoji: "🇩🇪")
    static let greece = Country(name: "Greece", flagEmoji: "🇬🇷")
    static let hungary = Country(name: "Hungary", flagEmoji: "🇭🇺")
    static let iceland = Country(name: "Iceland", flagEmoji: "🇮🇸")
    static let ireland = Country(name: "Ireland", flagEmoji: "🇮🇪")
    static let israel = Country(name: "Israel", flagEmoji: "🇮🇱")
    static let italy = Country(name: "Italy", flagEmoji: "🇮🇹")
    static let latvia = Country(name: "Latvia", flagEmoji: "🇱🇻")
    static let lithuania = Country(name: "Lithuania", flagEmoji: "🇱🇹")
    static let luxembourg = Country(name: "Luxembourg", flagEmoji: "🇱🇺")
    static let malta = Country(name: "Malta", flagEmoji: "🇲🇹")
    static let moldova = Country(name: "Moldova", flagEmoji: "🇲🇩")
    static let monaco = Country(name: "Monaco", flagEmoji: "🇲🇨")
    static let montenegro = Country(name: "Montenegro", flagEmoji: "🇲🇪")
    static let morocco = Country(name: "Morocco", flagEmoji: "🇲🇦")
    static let northMacedonia = Country(name: "North Macedonia", flagEmoji: "🇲🇰")
    static let norway = Country(name: "Norway", flagEmoji: "🇳🇴")
    static let poland = Country(name: "Poland", flagEmoji: "🇵🇱")
    static let portugal = Country(name: "Portugal", flagEmoji: "🇵🇹")
    static let romania = Country(name: "Romania", flagEmoji: "🇷🇴")
    static let russia = Country(name: "Russia", flagEmoji: "🇷🇺")
    static let sanMarino = Country(name: "San Marino", flagEmoji: "🇸🇲")
    static let serbia = Country(name: "Serbia", flagEmoji: "🇷🇸")
    static let serbiaAndMontenegro = Country(name: "Serbia and Montenegro", flagEmoji: "🇪🇺")
    static let slovakia = Country(name: "Slovakia", flagEmoji: "🇸🇰")
    static let slovenia = Country(name: "Slovenia", flagEmoji: "🇸🇮")
    static let spain = Country(name: "Spain", flagEmoji: "🇪🇸")
    static let sweden = Country(name: "Sweden", flagEmoji: "🇸🇪")
    static let switzerland = Country(name: "Switzerland", flagEmoji: "🇨🇭")
    static let turkey = Country(name: "Turkey", flagEmoji: "🇹🇷")
    static let theNetherlands = Country(name: "The Netherlands", flagEmoji: "🇳🇱")
    static let ukraine = Country(name: "Ukraine", flagEmoji: "🇺🇦")
    static let unitedKingdom = Country(name: "United Kingdom", flagEmoji: "🇬🇧")
    static let yugoslavia = Country(name: "Yugoslavia", flagEmoji: "🇪🇺")
}

// Country list as array for picker view
extension Country {
    /// Modern country list (2006 and later)
    static let modernCountryList: [Country] = [
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
    static let fullCountryList: [Country] = (modernCountryList + [.serbiaAndMontenegro, .yugoslavia]).sorted { $0.name < $1.name }
}
