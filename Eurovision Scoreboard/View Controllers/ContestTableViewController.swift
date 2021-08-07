//
//  ContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import UIKit

private let reuseIdentifier = "Act"

class ContestTableViewController: UITableViewController {

    static let defaultSectionIdentifier = 0

    var contestController: ContestController!
    var contestIndex: Int
    
    init?(contestIndex: Int, coder: NSCoder) {
        self.contestIndex = contestIndex
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem

        let contest = contestController.contests[contestIndex]
        navigationItem.title = "\(contest.hostCountry.flagEmoji) \(contest.year) - \(contest.hostCityName)"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contestController.contests[contestIndex].acts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ActTableViewCell
        
        cell.update(with: contestController.contests[contestIndex].acts[indexPath.row], position: indexPath.row + 1)
        cell.showsReorderControl = true
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedAct = contestController.contests[contestIndex].acts.remove(at: sourceIndexPath.row)
        contestController.contests[contestIndex].acts.insert(movedAct, at: destinationIndexPath.row)
        contestController.saveStateToFile()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        let contest = contestController.contests[contestIndex]
        
        var textToShare = "My Eurovision \(contest.year) Top-\(contest.acts.count):\n"
        for index in 0..<contest.acts.count {
            textToShare += "\(index + 1). \(contest.acts[index].country.name) \(contest.acts[index].country.flagEmoji)\n"
        }
        
        let activityController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        
        present(activityController, animated: true, completion: nil)
    }
    
}
