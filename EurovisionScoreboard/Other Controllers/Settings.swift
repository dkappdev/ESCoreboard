//
//  Settings.swift
//  EurovisionScoreboard
//
//  Created by Daniil Kostitsin on 26.08.2021.
//

import Foundation

/// Model structure responsible for storing user settings
public struct Settings {
    // MARK: - Nested types
    
    /// Keys for `UserDefaults`
    public enum Setting: String {
        case gridWidth = "gridWidth"
    }
    
    // MARK: - Properties
    
    /// Shared instance of settings
    public static var shared = Settings()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Initializers
    
    /// Explicit private initializer to prevent multiple instances from being created
    private init() { }
    
    // MARK: Utility methods
    
    /// Utility method for saving values as JSON strings in `UserDefaults`
    /// - Parameters:
    ///   - key: key to use for `UserDefaults`
    ///   - value: value to archive
    private func archiveJSON<T: Encodable>(key: String, value: T) {
        let data: Data
        
        // Trying to encode JSON data
        do {
            // If successful, store the encoded data
            data = try JSONEncoder().encode(value)
        } catch {
            // Otherwise print error message and exit function
            print("Unable to create JSON data from \(value). Reason: \(error.localizedDescription)")
            print(error)
            return
        }
        
        // Converting JSON data to a string
        let string = String(data: data, encoding: .utf8)
        
        // Check if we were able to convert JSON data to JSON string
        guard let string = string else {
            // If not, print error message and exit function
            print("Unable to initialize string from JSON data")
            return
        }
        
        // If everything was successful, save the JSON string in `UserDefaults`
        defaults.set(string, forKey: key)
    }
    
    /// Utility method for getting values from JSON data stored in `UserDefaults`
    /// - Parameter key: key to use for `UserDefaults`
    /// - Returns: the decoded value
    func unarchiveJSON<T: Decodable>(key: String) -> T? {
        // Getting JSON string from `UserDefault`s and attempting to convert it to data with UTF-8 encoding
        guard let string = defaults.string(forKey: key),
              let data = string.data(using: .utf8) else {
            return nil
        }
        
        // Trying to decoded JSON data
        do {
            // If successful, return the decoded instance
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            // Otherwise print error message and return nil
            print("Unable to decode JSON data. Reason: \(error.localizedDescription)")
            print(error)
            return nil
        }
    }
    
}
