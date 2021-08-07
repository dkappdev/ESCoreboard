//
//  ContestTableViewDiffableDataSource.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 07.08.2021.
//

import UIKit

class ContestTableViewDiffableDataSource: UITableViewDiffableDataSource<Int, Act> {
    weak var delegate: ContestTableViewDiffableDataSourceDelegate?
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        
        var snapshot = snapshot()
        
        guard let sourceID = itemIdentifier(for: sourceIndexPath) else { return }
        
        if let destinationID = itemIdentifier(for: destinationIndexPath) {
            guard sourceID != destinationID else { return }
            
            if sourceIndexPath.row > destinationIndexPath.row {
                snapshot.moveItem(sourceID, beforeItem: destinationID)
            } else {
                snapshot.moveItem(sourceID, afterItem: destinationID)
            }
        } else {
            snapshot.deleteItems([sourceID])
            snapshot.appendItems([sourceID], toSection: ContestTableViewController.defaultSectionIdentifier)
        }
        
        apply(snapshot)
        
        delegate?.dataSource(self, didChangeActList: snapshot.itemIdentifiers)
    }
}
