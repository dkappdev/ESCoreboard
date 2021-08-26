//
//  Act.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import Foundation

/// Model structure representing act information – artist name, song name, and competing country
struct Act {
    /// Artist name
    var artistName: String
    /// Song name
    var songName: String
    /// Country which sent the act
    var country: Country
}

// Adopting Codable to be able to save data to disk
extension Act: Codable { }

// Adopting Hashable for UICollectionViewDiffableDataSource
extension Act: Hashable { }
