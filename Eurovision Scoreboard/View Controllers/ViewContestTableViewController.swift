//
//  ContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import UIKit

/// Table view responsible for displaying acts in 'view' mode, where user can rearrange acts to create their storyboard and share it.
class ViewContestTableViewController: UITableViewController {
    
    /// Reuse identifier for act cell
    private static let viewActCellReuseIdentifier = "ViewActCell"
    
    // MARK: - Properties
    
    /// Model controller object responsible for handling app state. It is initialized via dependency injection
    var contestController: ContestController!
    /// Index of the contest this view controller is displaying. This property represents index of the actual contest in `contestController`'s `contests` array.
    let contestIndex: Int
    
    // MARK: - Initializers
    
    /// Custom initializer with contest index parameter. Only this initializer must be used.
    /// - Parameters:
    ///   - contestIndex: index of the contest this view controller is displaying.
    ///   - coder: coder provided by Storyboard
    init?(contestIndex: Int, coder: NSCoder) {
        self.contestIndex = contestIndex
        super.init(coder: coder)
    }
    
    /// Required initializer that should never be used. It is not implemented.
    /// - Parameter coder: coder provided by Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up navigation item
        let contest = contestController.contests[contestIndex]
        navigationItem.title = "\(contest.hostCountry.flagEmoji) \(contest.year) - \(contest.hostCityName)"
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Explicitly setting toolbar visibility in case we want to hide it later
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // There's only one section since we're only displaying an array of acts
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contestController.contests[contestIndex].acts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.viewActCellReuseIdentifier, for: indexPath) as! ViewActTableViewCell
        
        cell.update(with: contestController.contests[contestIndex].acts[indexPath.row], position: indexPath.row + 1)
        // Users create their scoreboard by reordering acts
        cell.showsReorderControl = true
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Making row moveable
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Changing act positions
        let movedAct = contestController.contests[contestIndex].acts.remove(at: sourceIndexPath.row)
        contestController.contests[contestIndex].acts.insert(movedAct, at: destinationIndexPath.row)
        
        // And updating table view
        // `UITableView.reloadData()` interrupts animations. Because of that reloading is scheduled to start after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // User should not be able to remove acts in 'view' mode
        // Overriding editing style since default is `.delete`
        return .none
    }
    
    // MARK: - Configuring buttons
    
    /// Called when user taps the action bar button.
    /// The contest scoreboard is shared as a numbered list of acts.
    /// - Parameter sender: the button that was tapped
    @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
        // Getting the current contest
        let contest = contestController.contests[contestIndex]
        
        // Creating the header
        var textToShare = "My Eurovision \(contest.year) Top-\(contest.acts.count):\n"
        // Adding the acts
        for index in 0..<contest.acts.count {
            textToShare += "\(index + 1). \(contest.acts[index].country.name) \(contest.acts[index].country.flagEmoji)\n"
        }
        
        // Creating activity view controlling
        let activityController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        // Specifying source bar button item for iPadOS
        activityController.popoverPresentationController?.barButtonItem = sender
        // Presenting
        present(activityController, animated: true, completion: nil)
    }
    
}
