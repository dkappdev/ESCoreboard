//
//  ContestTableViewDiffableDataSourceDelegate.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 07.08.2021.
//

import Foundation

protocol ContestTableViewDiffableDataSourceDelegate: AnyObject {
    func dataSource(_ dataSource: ContestTableViewDiffableDataSource, didChangeActList acts: [Act])
}
