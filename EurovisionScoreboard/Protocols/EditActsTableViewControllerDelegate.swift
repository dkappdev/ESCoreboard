//
//  EditActsTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import Foundation

/// A set of methods to respond to changes made to act list
public protocol EditActsTableViewControllerDelegate: AnyObject {
    /// Tells the delegate that act list was changed
    /// - Parameter acts: new act list
    func didChangeActs(_ acts: [Act])
}
