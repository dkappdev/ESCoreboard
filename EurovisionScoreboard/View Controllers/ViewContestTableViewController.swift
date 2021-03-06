//
//  ContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import UIKit

/// Table view responsible for displaying acts in 'view' mode, where user can rearrange acts to create their storyboard and share it.
public class ViewContestTableViewController: UITableViewController {
    
    /// Reuse identifier for act cell
    public static let viewActCellReuseIdentifier = "ViewActCell"
    
    // MARK: - Properties
    
    /// Index of the contest this view controller is displaying. This property represents index of the contest in `contestController`'s `contests` array.
    private let contestIndex: Int
    
    // MARK: - Initializers
    
    /// Custom initializer with contest index parameter. Only this initializer must be used.
    /// - Parameters:
    ///   - contestIndex: index of the contest this view controller is displaying.
    ///   - coder: coder provided by Storyboard
    public init?(contestIndex: Int, coder: NSCoder) {
        self.contestIndex = contestIndex
        super.init(coder: coder)
    }
    
    /// Required initializer that should never be used. It is not implemented.
    /// - Parameter coder: coder provided by Storyboard
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Life Cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up navigation item
        let contest = ContestController.shared.contests[contestIndex]
        navigationItem.title = "\(contest.hostCountry.flagEmoji) \(contest.year) - \(contest.hostCityName)"
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Explicitly setting toolbar visibility in case we want to change it later
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - Table View Data Source
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        // There's only one section since we're only displaying an array of acts
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContestController.shared.contests[contestIndex].acts.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.viewActCellReuseIdentifier, for: indexPath) as! ViewActTableViewCell
        
        cell.update(with: ContestController.shared.contests[contestIndex].acts[indexPath.row], position: indexPath.row + 1)
        // Users create their scoreboard by reordering acts
        cell.showsReorderControl = true
        
        return cell
    }
    
    // MARK: - Table View Delegate
    
    public override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Making row moveable
        return true
    }
    
    public override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Changing act positions
        let movedAct = ContestController.shared.contests[contestIndex].acts.remove(at: sourceIndexPath.row)
        ContestController.shared.contests[contestIndex].acts.insert(movedAct, at: destinationIndexPath.row)
        
        // And updating table view
        // `UITableView.reloadData()` interrupts animations. Because of that reloading is scheduled to start after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.tableView.reloadData()
        }
    }
    
    public override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
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
        let contest = ContestController.shared.contests[contestIndex]
        
        // Creating the header
        var textToShare = "My Eurovision \(contest.year) Top-\(contest.acts.count):\n"
        // Adding the acts
        for index in 0..<contest.acts.count {
            textToShare += "\(index + 1). \(contest.acts[index].country.name) \(contest.acts[index].country.flagEmoji)\n"
        }
        
        // Creating activity view controller
        let activityController = UIActivityViewController(activityItems: [textToShare], applicationActivities: nil)
        // Specifying source bar button item for iPadOS
        activityController.popoverPresentationController?.barButtonItem = sender
        // Presenting
        present(activityController, animated: true, completion: nil)
    }
    
}
