//
//  Act.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import Foundation

/// Model structure representing act information – artist name, song name, and competing country
public struct Act {
    /// Artist name
    public var artistName: String
    /// Song name
    public var songName: String
    /// Country which sent the act
    public var country: Country
}

// Adopting Codable to be able to save data to disk
extension Act: Codable { }

// Adopting Hashable for UICollectionViewDiffableDataSource
extension Act: Hashable { }
