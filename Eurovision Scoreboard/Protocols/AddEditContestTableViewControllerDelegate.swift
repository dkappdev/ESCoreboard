//
//  AddEditContestTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 09.08.2021.
//

import Foundation

protocol AddEditContestTableViewControllerDelegate: AnyObject {
    /// Delegate is responsible for dismissing the view controller. Call this function on delegate to dismiss.
    func dismissViewController()
}
