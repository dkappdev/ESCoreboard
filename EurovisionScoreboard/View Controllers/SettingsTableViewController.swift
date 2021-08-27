//
//  SettingsTableViewController.swift
//  EurovisionScoreboard
//
//  Created by Daniil Kostitsin on 26.08.2021.
//

import UIKit

/// Static view controller responsible for changing app settings
class SettingsTableViewController: UITableViewController {
    
    /// Index path for 'Export' cell. By clicking the cell user can export contest data as JSON
    let exportCellIndexPath = IndexPath(row: 0, section: 0)
    /// Index path for 'Import' cell. By clicking the cell user can import contest data from JSON file
    let importCellIndexPath = IndexPath(row: 1, section: 0)
    /// Index path for 'Reset' cell. By clicking the cell user can completely reset contest data
    let resetCellIndexPath = IndexPath(row: 2, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
