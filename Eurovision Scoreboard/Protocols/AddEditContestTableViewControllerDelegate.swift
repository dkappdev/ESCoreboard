//
//  AddEditContestTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 09.08.2021.
//

import Foundation

/// Delegate is responsible for dismissing the view controller. Table view controller should use the delegate to dismiss itself.
protocol AddEditContestTableViewControllerDelegate: AnyObject {
    /// Call this function on delegate to dismiss the view controller.
    func dismissViewController()
}
