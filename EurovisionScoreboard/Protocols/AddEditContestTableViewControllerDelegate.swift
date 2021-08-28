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
    
    /// Tells the delegate that a contest should be removed from contest list and asks it to dismiss the view controller
    /// - Parameter indexPath: index path of the contest that should be removed
    func dismissViewControllerAndDeleteContestAt(_ indexPath: IndexPath)
    
    /// Tells the delegate that a contest should be added at the end of contest list and asks it to dismiss the view controller
    /// - Parameter contest: the contest to add
    func dismissViewControllerAndAddContest(_ contest: Contest)
    
    /// Tells the delegate to change a contest in the contest list and asks it to dismiss the view controller
    /// - Parameters:
    ///   - contest: new contest value
    ///   - indexPath: position at which to change the act
    func dismissViewControllerAndChangeContest(_ contest: Contest, at indexPath: IndexPath)
}
