//
//  AddEditContestTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 09.08.2021.
//

import Foundation

/// A set of methods for dismissing the  view controller. `AddEditContestTableViewController` should use the delegate to dismiss itself.
protocol AddEditContestTableViewControllerDelegate: AnyObject {
    /// Asks the delegate to dismiss the view controller.
    func dismissViewController()
}
