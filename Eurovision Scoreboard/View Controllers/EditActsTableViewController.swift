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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! EditActTableViewCell
        
        cell.update(with: acts[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            acts.remove(at: indexPath.row)
            delegate?.didChangeActs(acts)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
}
