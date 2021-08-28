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
    
    // Allowing current VC to become first responder in order to detect shake motion
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Private instance of undo manager specific to this view controller
    private let myUndoManager = UndoManager()
    
    override var undoManager: UndoManager? {
        return myUndoManager
    }
    
    /// Act list that we are editing
    var acts: [Act]
    /// Year when contest is taking place
    let contestYear: Int?
    
    /// Delegate responsible for saving changes
    weak var delegate: EditActsTableViewControllerDelegate?
    
    // MARK: - Initializers
    
    /// Custom initializer with act list. Only this initializer must be used
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - acts: act list to edit
    ///   - contestYear: year when contest is taking place
    init?(coder: NSCoder, acts: [Act], contestYear: Int?) {
        self.acts = acts
        self.contestYear = contestYear
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
        
        // Becoming first responder to detect shake motion
        becomeFirstResponder()
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
            confirmDelete(forRowAt: indexPath)
        }
    }
    
    // MARK: - Segues
    
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
            let controller = AddEditActTableViewController(coder: coder, acts: acts, actIndex: actIndex, contestYear: contestYear)
            // And set its delegate to `self`
            controller?.delegate = self
            return controller
        } else if segueIdentifier == Self.addActSegueIdentifier {
            // Otherwise, if segue identifier is `Self.addActSegueIdentifier`, we are creating a new act, and `actIndex` should be `nil`
            
            // Create the view controller
            let controller = AddEditActTableViewController(coder: coder, acts: acts, actIndex: nil, contestYear: contestYear)
            // And set its delegate to `self`
            controller?.delegate = self
            return controller
        } else {
            // If none of the above conditions were satisfied, do not return a view controller
            return nil
        }
    }
    
    // MARK: - Applying changes
    
    /// Asks the user whether or not they want to delete
    func confirmDelete(forRowAt indexPath: IndexPath) {
        // If user attempted to dismiss VC, ask them if they are sure they want to dismiss changes
        // We present an action sheet only for iPhone since there is no reasonable source view for popover presentation controller
        let alert = UIAlertController(title: "Are you sure you want to delete this act from your list?", message: nil, preferredStyle: UIDevice.current.userInterfaceIdiom == .phone ? .actionSheet : .alert)
        
        alert.addAction(UIAlertAction(title: "Delete Act", style: .destructive) { _ in
            // Telling the delegate that an act should be deleted and asking it dismiss the view controller
            self.removeAct(for: indexPath, initiatedByUser: true)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Undo / Redo
    
    /// Removes act from act list, updates table view and creates undo action
    /// - Parameter indexPath: index path for act to remove
    /// - Parameter initiatedByUser: indicates whether this function was called after a user action or by an undo manager. This parameter is used to properly set the action name.
    func removeAct(for indexPath: IndexPath, initiatedByUser: Bool) {
        // If user deleted an act, remove it from the acts array and remember its value
        let removedAct = acts.remove(at: indexPath.row)
        // Telling the delegate that act list was changed
        delegate?.didChangeActs(acts)
        // Deleting the table view row
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        // Setting up undo action
        undoManager?.setActionName(initiatedByUser ? "Remove Act" : "Add Act")
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            targetSelf.addAct(removedAct, at: indexPath, initiatedByUser: !initiatedByUser)
        }
    }
    
    /// Adds act to the specified location, creates undo action, and updates table view
    /// - Parameters:
    ///   - act: act to add
    ///   - indexPath: index to put the act at
    ///   - initiatedByUser: indicates whether this function was called after a user action or by an undo manager. This parameter is used to properly set the action name.
    func addAct(_ act: Act, at indexPath: IndexPath, initiatedByUser: Bool) {
        // Inserting the act to act list and updating table view
        acts.insert(act, at: indexPath.row)
        // Telling the delegate that act list was changed
        delegate?.didChangeActs(acts)
        // Updating table view
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        // Setting up undo action
        undoManager?.setActionName(initiatedByUser ? "Add Act" : "Remove Act")
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            targetSelf.removeAct(for: indexPath, initiatedByUser: !initiatedByUser)
        }
    }
    
    /// Changes act value at the specified location
    /// - Parameters:
    ///   - act: new act value
    ///   - indexPath: act position
    func changeAct(_ act: Act, at indexPath: IndexPath) {
        // Making sure index path is valid
        guard indexPath.row < acts.count else {
            print("Error: Attempting to change act that does not exist")
            return
        }
        
        // Saving the old act
        let oldAct = acts[indexPath.row]
        // Replacing it
        acts[indexPath.row] = act
        // Telling the delegate that act list was changed
        delegate?.didChangeActs(acts)
        // Updating table view
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Setting up undo action
        undoManager?.setActionName("Change Act")
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            targetSelf.changeAct(oldAct, at: indexPath)
        }
    }
    
    // MARK: - Working with motion
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        // If we detect a shake motion, ask user if they want to undo or redo changes
        // If shake to undo is disabled in accessability, don't do anything
        guard motion == .motionShake,
              UIAccessibility.isShakeToUndoEnabled else {
            return
        }
        
        // Getting the alert with possible undo / action actions from `UndoManager` instance and presenting it
        if let alert = undoManager?.getAlertWithAvailableActions() {
            present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - AddEditAct VC Delegate

extension EditActsTableViewController: AddEditActTableViewControllerDelegate {
    /// Called when act list was not changed. Dismissed the view controller that called this method/
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when act list was changed. Saves the new act list that was list provided by `EditActsTableViewController`, tells its own delegate to update the act list, and dismisses the view controller that called this method on its delegate.
    /// - Parameter acts: new act list
    func dismissViewControllerAndSaveActs(_ acts: [Act]) {
        self.acts = acts
        delegate?.didChangeActs(self.acts)
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when an act should be removed from act list. Dismisses the view controller that called this method on its delegate and removes the act at specified index path
    /// - Parameter indexPath: index path of the act that should be deleted
    func dismissViewControllerAndDeleteActAt(_ indexPath: IndexPath) {
        removeAct(for: indexPath, initiatedByUser: true)
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when an act should be added to the end of act list. Dismisses the view controller that called this method on its delegate and adds the act to the act list
    /// - Parameter act: the act to add to the act list
    func dismissViewControllerAndAddAct(_ act: Act) {
        addAct(act, at: IndexPath(row: acts.count, section: 0), initiatedByUser: true)
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when an act should be changed. Dismisses the view controller that called this methods on its delegate and changes the act at specified location
    /// - Parameters:
    ///   - act: new act value
    ///   - indexPath: act location
    func dismissViewControllerAndChangeAct(_ act: Act, at indexPath: IndexPath) {
        changeAct(act, at: indexPath)
        dismiss(animated: true, completion: nil)
    }
}
