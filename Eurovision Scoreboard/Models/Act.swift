//
//  Act.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import Foundation

struct Act {
    var artistName: String
    var songName: String
    var country: Country
}

extension Act: Codable { }

extension Act: Hashable { }
