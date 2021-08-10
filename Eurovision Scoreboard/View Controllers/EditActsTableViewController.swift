//
//  EditActsTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

private var reuseIdentifier = "EditActCell"

class EditActsTableViewController: UITableViewController {

    var acts: [Act]
    weak var delegate: EditActsTableViewControllerDelegate?
    
    init?(coder: NSCoder, acts: [Act]) {
        self.acts = acts
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }
}
