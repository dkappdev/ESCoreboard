//
//  AddEditActTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import Foundation

/// A set of methods to respond to changes made to act list
protocol AddEditActTableViewControllerDelegate: AnyObject {
    /// Tells the delegate that act list was changed and ask the delegate to dismiss the view controller
    /// - Parameter acts: new act list
    func dismissViewControllerAndSaveActs(_ acts: [Act])
}
