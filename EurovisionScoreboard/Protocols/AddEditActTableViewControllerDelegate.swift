//
//  AddEditActTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import Foundation

/// A set of methods to respond to changes made to act list
public protocol AddEditActTableViewControllerDelegate: AnyObject {
    /// Tells the delegate that act list was changed and ask it to dismiss the view controller
    /// - Parameter acts: new act list
    func dismissViewControllerAndSaveActs(_ acts: [Act])
    
    /// Tells the delegate that an act should be removed from act list and asks it to dismiss the view controller
    /// - Parameter indexPath: index path of the act that should be removed
    func dismissViewControllerAndDeleteActAt(_ indexPath: IndexPath)
    
    /// Tells the delegate that an act should be added at the end of act list and asks it to dismiss the view controller
    /// - Parameter act: the act to add
    func dismissViewControllerAndAddAct(_ act: Act)
    
    /// Tells the delegate to change an act in the act list and asks it to dismiss the view controller
    /// - Parameters:
    ///   - act: new act
    ///   - indexPath: position at which to change the act
    func dismissViewControllerAndChangeAct(_ act: Act, at indexPath: IndexPath)
    
    /// Ask delegate to dismiss the view controller without applying any changes
    func dismissViewController()
}
