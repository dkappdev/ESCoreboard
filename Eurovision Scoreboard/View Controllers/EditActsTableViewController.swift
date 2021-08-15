//
//  EditActsTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

/// Table view controller responsible for displaying acts in 'edit' mode, where user can add new acts, edit or delete existing ones.
class EditActsTableViewController: UITableViewController {
    
    // MARK: - Properties

    /// Reuse identifier for act cell
    private static let editActCellReuseIdentifier = "EditActCell"
    
    /// addAct segue identifier
    private static let addActSegueIdentifier = "addAct"
    /// editAct segue identifier
    private static let editActSegueIdentifier = "editAct"
    
    /// Act list that we are editing
    var acts: [Act]
    
    /// Delegate responsible for saving changes
    weak var delegate: EditActsTableViewControllerDelegate?
    
    // MARK: - Initializers
    
    /// Custom initializer with act list. Only this initializer must be used
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - acts: act list to edit
    init?(coder: NSCoder, acts: [Act]) {
        self.acts = acts
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
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // There's only one section since we're only displaying an array of acts
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.editActCellReuseIdentifier, for: indexPath) as! EditActTableViewCell
        cell.update(with: acts[indexPath.row])
        return cell
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        // Explicitly setting editing style to `.delete`
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // If user deleted an act
            // Remove it from the acts array
            acts.remove(at: indexPath.row)
            // Tell the delegate that act list has changed
            delegate?.didChangeActs(acts)
            // And delete the table view row
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    // MARK: - Segues
    
    /// Called when user taps 'Cancel' to dismiss changes. Nothing is done in this method as the act list was not changed
    /// - Parameter segue: unwind segue
    @IBAction func unwindToActList(segue: UIStoryboardSegue) {
    }
    
    /// Creates an `AddEditActTableViewController` and sets up its delegate
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - sender: object that initiated the segue
    ///   - segueIdentifier: segue identifier
    /// - Returns: a new `AddEditActTableViewController` with configured delegate
    @IBSegueAction func addEditAct(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> AddEditActTableViewController? {
        if segueIdentifier == Self.editActSegueIdentifier,
           let cell = sender as? EditActTableViewCell,
           let actIndex = tableView.indexPath(for: cell)?.row {
            // If we are editing an existing act,
            // make sure the segue identifier is `Self.editActSegueIdentifier`,
            // sender is a table view cell,
            // and the cell has a valid index path.
            
            // Create the view controller
            let controller = AddEditActTableViewController(coder: coder, acts: acts, actIndex: actIndex)
            // And set its delegate to `self`
            controller?.delegate = self
            return controller
        } else if segueIdentifier == Self.addActSegueIdentifier {
            // Otherwise, if segue identifier is `Self.addActSegueIdentifier`, we are creating a new act, and `actIndex` should be `nil`
            
            // Create the view controller
            let controller = AddEditActTableViewController(coder: coder, acts: acts, actIndex: nil)
            // And set its delegate to `self`
            controller?.delegate = self
            return controller
        } else {
            // If none of the above conditions were satisfied, do not return a view controller
            return nil
        }
    }
}

// MARK: - AddEditAct VC Delegate

extension EditActsTableViewController: AddEditActTableViewControllerDelegate {
    /// Called when act list was changed. Saves the new act list that was list provided by `EditActsTableViewController`, tells its own delegate to update the act list, and dismisses the view controller that called this methods on its delegate.
    /// - Parameter acts: new act list
    func dismissViewControllerAndSaveActs(_ acts: [Act]) {
        self.acts = acts
        delegate?.didChangeActs(self.acts)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
