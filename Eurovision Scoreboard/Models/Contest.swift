//
//  Contest.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import Foundation

struct Contest {
    var hostCountry: Country
    var hostCityName: String
    var year: Int
    var acts: [Act]
}

extension Contest {
    static let archiveURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        .first!
        .appendingPathComponent("contests")
        .appendingPathExtension("json")
    
    static func saveToFile(contests: [Contest]) {
        let jsonEncoder = JSONEncoder()
        if let encodedContests = try? jsonEncoder.encode(contests) {
            try? encodedContests.write(to: archiveURL, options: .noFileProtection)
        }
    }
    
    static func loadFromFile() -> [Contest]? {
        let jsonDecoder = JSONDecoder()
        if let retrievedContestsData = try? Data(contentsOf: archiveURL),
           let decodedContests = try? jsonDecoder.decode([Contest].self, from: retrievedContestsData) {
            return decodedContests
        } else {
            return nil
        }
    }
    
    static func defaultContests() -> [Contest] {
        return [
            Contest(hostCountry: .theNetherlands, hostCityName: "Rotterdam", year: 2021, acts: Act.actsFor2021()),
            Contest(hostCountry: .theNetherlands, hostCityName: "Rotterdam", year: 2020, acts: Act.actsFor2020()),
            Contest(hostCountry: .israel, hostCityName: "Tel Aviv", year: 2019, acts: Act.actsFor2019())
        ]
    }
}

extension Contest: Codable { }

extension Contest: Hashable { }
