//
//  EditActsTableViewControllerDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import Foundation

protocol EditActsTableViewControllerDelegate: AnyObject {
    func didChangeActs(_ acts: [Act])
}
