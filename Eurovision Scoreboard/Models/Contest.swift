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

extension Contest: Codable { }

extension Contest: Hashable { }
