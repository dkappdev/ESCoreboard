//
//  ContestController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import Foundation

/// Model controller that handles the app's contest list
class ContestController {
    // MARK: - Properties
    
    /// Array of contests the user has saved. Any changes are automatically written to disk
    var contests: [Contest] {
        didSet {
            // Saving the new contest list to file
            Self.saveToFile(contests: contests)
        }
    }
    
    // MARK: - Initializers
    
    /// Default initializer that attempts to load contests from file. If unable to do so, it load the default contest list.
    init() {
        contests = Self.loadFromFile() ?? Self.defaultContests()
    }
    
    // MARK: - Resetting the state
    
    /// Replaces the contest list with default contests
    func resetContests() {
        contests = Self.defaultContests()
    }
}

// MARK: - Saving data to file

extension ContestController {
    /// URL of the file where contests are stored
    private static let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("contests")
        .appendingPathExtension("json")
    
    /// Saves contest list to `archiveURL`
    /// - Parameter contests: contest list to save
    private static func saveToFile(contests: [Contest]) {
        // Getting a JSON encoder
        let jsonEncoder = JSONEncoder()
        if let encodedContests = try? jsonEncoder.encode(contests) {
            // If we successfully encoded the contest list
            
            // Attempt to write data to file
            try? encodedContests.write(to: Self.archiveURL, options: .noFileProtection)
        }
    }
    
    /// Attempts to read contest list from `archiveURL`
    /// - Returns: `nil` if unable to read contest list, otherwise contest saved at `archiveURL`
    private static func loadFromFile() -> [Contest]? {
        // Getting a JSON decoder
        let jsonDecoder = JSONDecoder()
        
        if let retrievedContestsData = try? Data(contentsOf: archiveURL),
           let decodedContests = try? jsonDecoder.decode([Contest].self, from: retrievedContestsData) {
            // If we successfuly read data from file,
            // and were able to decode the JSON data,
            
            // return the decoded contest list
            return decodedContests
        } else {
            // Otherwise return `nil`
            return nil
        }
    }
    
    /// List of default contests
    /// - Returns: default contest list
    private static func defaultContests() -> [Contest] {
        return [
            Contest(hostCountry: .theNetherlands, hostCityName: "Rotterdam", year: 2021, acts: [
                Act(artistName: "Anxhela Peristeri", songName: "Karma", country: .albania),
                Act(artistName: "Montaigne", songName: "Technicolour", country: .australia),
                Act(artistName: "Vincent Bueno", songName: "Amen", country: .austria),
                Act(artistName: "Efendi", songName: "Mata Hari", country: .azerbaijan),
                Act(artistName: "Hooverphonic", songName: "The Wrong Place", country: .belgium),
                Act(artistName: "VICTORIA", songName: "Growing Up Is Getting Old", country: .bulgaria),
                Act(artistName: "Albina", songName: "Tick-Tock", country: .croatia),
                Act(artistName: "Elena Tsagrinou", songName: "El Diablo", country: .cyprus),
                Act(artistName: "Benny Cristo", songName: "Omaga", country: .czechRepublic),
                Act(artistName: "Fyr og Flamme", songName: "Øve os på hinanden", country: .denmark),
                Act(artistName: "Uku Suviste", songName: "The Lucky One", country: .estonia),
                Act(artistName: "Blind Channel", songName: "Dark Side", country: .finland),
                Act(artistName: "Barbara Pravi", songName: "Voilà", country: .france),
                Act(artistName: "Tornike Kipiani", songName: "You", country: .georgia),
                Act(artistName: "Jendrik", songName: "I Don't Feel Hate", country: .germany),
                Act(artistName: "Stefania", songName: "Last Dance", country: .greece),
                Act(artistName: "Daði og Gagnamagnið", songName: "10 Years", country: .iceland),
                Act(artistName: "Lesley Roy", songName: "Maps", country: .ireland),
                Act(artistName: "Eden Alene", songName: "Set Me Free", country: .israel),
                Act(artistName: "Måneskin", songName: "Zitti e buoni", country: .italy),
                Act(artistName: "Samanta Tīna", songName: "The Moon Is Rising", country: .latvia),
                Act(artistName: "THE ROOP", songName: "Discoteque", country: .lithuania),
                Act(artistName: "Destiny", songName: "Je Me Casse", country: .malta),
                Act(artistName: "Natalia Gordienko", songName: "Sugar", country: .moldova),
                Act(artistName: "Jeangu Macrooy", songName: "Birth of a New Age", country: .theNetherlands),
                Act(artistName: "Vasil", songName: "Here I Stand", country: .northMacedonia),
                Act(artistName: "TIX", songName: "Fallen Angel", country: .norway),
                Act(artistName: "Rafał", songName: "The Ride", country: .poland),
                Act(artistName: "The Black Mamba", songName: "Love Is on My Side", country: .portugal),
                Act(artistName: "Roxen", songName: "Amnesia", country: .romania),
                Act(artistName: "Manizha", songName: "Russian Woman", country: .russia),
                Act(artistName: "Senhit", songName: "Adrenalina", country: .sanMarino),
                Act(artistName: "Hurricane", songName: "Loco Loco", country: .serbia),
                Act(artistName: "Ana Soklič", songName: "Amen", country: .slovenia),
                Act(artistName: "Blas Cantó", songName: "Voy a quedarme", country: .spain),
                Act(artistName: "Tusse", songName: "Voices", country: .sweden),
                Act(artistName: "Gjon’s Tears", songName: "Tout l’univers", country: .switzerland),
                Act(artistName: "Go_A", songName: "SHUM", country: .ukraine),
                Act(artistName: "James Newman", songName: "Embers", country: .unitedKingdom)
            ]),
            Contest(hostCountry: .theNetherlands, hostCityName: "Rotterdam", year: 2020, acts: [
                Act(artistName: "Arilena Ara", songName: "Fall from the Sky", country: .albania),
                Act(artistName: "Athena Manoukian", songName: "Chains on You", country: .armenia),
                Act(artistName: "Montaigne", songName: "Don't Break Me", country: .australia),
                Act(artistName: "Vincent Bueno", songName: "Alive", country: .austria),
                Act(artistName: "Efendi", songName: "Cleopatra", country: .azerbaijan),
                Act(artistName: "VAL", songName: "Da vidna", country: .belarus),
                Act(artistName: "Hooverphonic", songName: "Release Me", country: .belgium),
                Act(artistName: "VICTORIA", songName: "Tears Getting Sober", country: .bulgaria),
                Act(artistName: "Damir Kedžo", songName: "Divlji vjetre", country: .croatia),
                Act(artistName: "Sandro", songName: "Running", country: .cyprus),
                Act(artistName: "Benny Cristo", songName: "Kemama", country: .czechRepublic),
                Act(artistName: "Ben & Tan", songName: "Yes", country: .denmark),
                Act(artistName: "Uku Suviste", songName: "What Love Is", country: .estonia),
                Act(artistName: "Aksel Kankaanranta", songName: "Looking Back", country: .finland),
                Act(artistName: "Tom Leeb", songName: "The Best in Me", country: .france),
                Act(artistName: "Tornike Kipiani", songName: "Take Me As I Am", country: .georgia),
                Act(artistName: "Ben Dolic", songName: "Violent Thing", country: .germany),
                Act(artistName: "Stefania", songName: "SUPERGIRL", country: .greece),
                Act(artistName: "Daði & Gagnamagnið", songName: "Gagnamagnið (Think About Things)", country: .iceland),
                Act(artistName: "Lesley Roy", songName: "Story of My Life", country: .ireland),
                Act(artistName: "Eden Alene", songName: "Feker libi", country: .israel),
                Act(artistName: "Diodato", songName: "Fai rumore", country: .italy),
                Act(artistName: "Samanta Tina", songName: "Still Breathing", country: .latvia),
                Act(artistName: "THE ROOP", songName: "On Fire", country: .lithuania),
                Act(artistName: "Destiny Chukunyere", songName: "All My Love", country: .malta),
                Act(artistName: "Natalia Gordienko", songName: "Prison", country: .moldova),
                Act(artistName: "Jeangu Macrooy", songName: "Grow", country: .theNetherlands),
                Act(artistName: "Vasil", songName: "YOU", country: .northMacedonia),
                Act(artistName: "Ulrikke", songName: "Attention", country: .norway),
                Act(artistName: "Alicja", songName: "Empires", country: .poland),
                Act(artistName: "Elisa", songName: "Medo de sentir", country: .portugal),
                Act(artistName: "Roxen", songName: "Alcohol You", country: .romania),
                Act(artistName: "Little Big", songName: "UNO", country: .russia),
                Act(artistName: "Senhit", songName: "Freaky!", country: .sanMarino),
                Act(artistName: "Hurricane", songName: "Hasta la vista", country: .serbia),
                Act(artistName: "Ana Soklič", songName: "Voda", country: .slovenia),
                Act(artistName: "Blas Cantó", songName: "Universo", country: .spain),
                Act(artistName: "The Mamas", songName: "Move", country: .sweden),
                Act(artistName: "Gjon’s Tears", songName: "Répondez-moi", country: .switzerland),
                Act(artistName: "Go_A", songName: "Solovey", country: .ukraine),
                Act(artistName: "James Newman", songName: "My Last Breath", country: .unitedKingdom)
            ]),
            Contest(hostCountry: .israel, hostCityName: "Tel Aviv", year: 2019, acts: [
                Act(artistName: "Srbuk", songName: "Walking Out", country: .armenia),
                Act(artistName: "Kate Miller-Heidke", songName: "Zero Gravity", country: .australia),
                Act(artistName: "Paenda", songName: "Limits", country: .austria),
                Act(artistName: "Chingiz", songName: "Truth", country: .azerbaijan),
                Act(artistName: "Zena", songName: "Like It", country: .belarus),
                Act(artistName: "Eliot", songName: "Wake Up", country: .belgium),
                Act(artistName: "Roko", songName: "The Dream", country: .croatia),
                Act(artistName: "Tamta", songName: "Replay", country: .cyprus),
                Act(artistName: "Lake Malawi", songName: "Friend of a Friend", country: .czechRepublic),
                Act(artistName: "Leonora", songName: "Love Is Forever", country: .denmark),
                Act(artistName: "Victor Crone", songName: "Storm", country: .estonia),
                Act(artistName: "Darude feat. Sebastian Rejman", songName: "Look Away", country: .finland),
                Act(artistName: "Bilal Hassani", songName: "Roi", country: .france),
                Act(artistName: "Oto Nemsadze", songName: "Sul tsin iare", country: .georgia),
                Act(artistName: "S!sters", songName: "Sister", country: .germany),
                Act(artistName: "Katerine Duska", songName: "Better Love", country: .greece),
                Act(artistName: "Joci Pápai", songName: "Az én apám", country: .hungary),
                Act(artistName: "Hatari", songName: "Hatrið mun sigra", country: .iceland),
                Act(artistName: "Sarah McTernan", songName: "22", country: .ireland),
                Act(artistName: "Mahmood", songName: "Soldi", country: .italy),
                Act(artistName: "Carousel", songName: "That Night", country: .latvia),
                Act(artistName: "Jurij Veklenko", songName: "Run with the Lions", country: .lithuania),
                Act(artistName: "Michela Pace", songName: "Chameleon", country: .malta),
                Act(artistName: "Anna Odobescu", songName: "Stay", country: .moldova),
                Act(artistName: "D mol", songName: "Heaven", country: .montenegro),
                Act(artistName: "Duncan Laurence", songName: "Arcade", country: .theNetherlands),
                Act(artistName: "Tamara Todevska", songName: "Proud", country: .northMacedonia),
                Act(artistName: "KEiiNO", songName: "Spirit in the Sky", country: .norway),
                Act(artistName: "Tulia", songName: "Fire of Love (Pali się)", country: .poland),
                Act(artistName: "Conan Osíris", songName: "Telemóveis", country: .portugal),
                Act(artistName: "Ester Peony", songName: "On a Sunday", country: .romania),
                Act(artistName: "Sergey Lazarev", songName: "Scream", country: .russia),
                Act(artistName: "Serhat", songName: "Say Na Na Na", country: .sanMarino),
                Act(artistName: "Nevena Božović", songName: "Kruna", country: .serbia),
                Act(artistName: "Zala Kralj & Gašper Šantl", songName: "Sebi", country: .slovenia),
                Act(artistName: "Miki", songName: "La venda", country: .spain),
                Act(artistName: "John Lundvik", songName: "Too Late For Love", country: .sweden),
                Act(artistName: "Luca Hänni", songName: "She Got Me", country: .switzerland),
                Act(artistName: "Michael Rice", songName: "Bigger Than Us", country: .unitedKingdom)
            ])
        ]
    }
}
