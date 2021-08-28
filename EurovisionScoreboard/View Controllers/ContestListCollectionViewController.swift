//
//  YearCollectionViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import UIKit

/// Collection view controller responsible for displaying list of contests, adding new contests and resetting the app.
class ContestListCollectionViewController: UICollectionViewController {
    
    // We use Int for section identifier and Contest for item identifier.
    // Here we create a typealias for data source and data source snapshot with <Int, Contest> type parameters
    typealias DataSourceType = UICollectionViewDiffableDataSource<Int, Contest>
    typealias DataSourceSnapshotType = NSDiffableDataSourceSnapshot<Int, Contest>
    
    // MARK: - Properties
    
    /// addContest segue identifier
    private static let addContestSegueIdentifier = "addContest"
    /// editContest segue identifier
    private static let editContestSegueIdentifier = "editContest"
    
    /// Reuse identifier for contest cell
    private static let contestCellReuseIdentifier = "Contest"
    /// Idenetifier for collection view's only section
    static let defaultSectionIdentifier = 0
    
    /// The collection view diffable data source
    var dataSource: DataSourceType!
    
    // Allowing current VC to become first responder in order to detect shake motion
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    /// Private instance of undo manager specific to this view controller
    private let myUndoManager = UndoManager()
    
    override var undoManager: UndoManager? {
        return myUndoManager
    }
    
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up data source and layout
        dataSource = createDataSource()
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
        
        updateCollectionView()
        
        // Subscribing to notification about contest list updates
        NotificationCenter.default.addObserver(self, selector: #selector(updateCollectionView), name: SettingsTableViewController.contestListUpdatedNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Explicitly setting toolbar visibility in case we want to change it later
        navigationController?.setToolbarHidden(true, animated: true)
    }
    
    // MARK: - Responding to trait changes
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // Updating layout if horizontal size class has changed
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass {
            collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
        }
    }
    
    // MARK: - Setting up collection view
    
    /// Creates collection view layout with variable width based on `isCompact` parameter
    /// - Parameter isCompact: If `true`, the layout will adapt for compact horizontal size class
    /// - Returns: New collection view layout
    func createLayout(isCompact: Bool) -> UICollectionViewCompositionalLayout {
        // Creating an item that fills all of the available width and height
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Setting how many items there are in a horizontal group based on `isCompact` parameter
        let elementsInGroup = isCompact ? 2 : 3
        
        // All of our cell are square, so we calculate the height to be a fraction of how many elements there are in a group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(CGFloat(1.0 / Double(elementsInGroup))))
        
        // Creating the horizontal group
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: elementsInGroup)
        
        // Adding spacing between items
        group.interItemSpacing = .fixed(12)
        
        // Creating section
        let section = NSCollectionLayoutSection(group: group)
        
        // Setting the section content insets and inter-group spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        section.interGroupSpacing = CGFloat(12)
        
        // Making sure sections doesn't take up the entire width of the screen
        section.contentInsetsReference = .readableContent
        
        // Creating the final layout
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    /// Creates a collection view diffable data source
    /// - Returns: New diffable data source
    func createDataSource() -> DataSourceType {
        // Creating data source with cell provider closure
        return DataSourceType(collectionView: collectionView) { collectionView, indexPath, contest in
            // Dequeueing the cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.contestCellReuseIdentifier, for: indexPath) as! ContestCollectionViewCell
            
            // Updating it with contest information
            cell.update(with: contest)
            
            // Setting the cornet radius
            cell.layer.cornerRadius = 12
            
            return cell
        }
    }
    
    // MARK: - Updating collection view
    
    /// Pulls new data from `contestController` and updates collection view
    @objc func updateCollectionView() {
        // Creating a new snapshot
        var snapshot = DataSourceSnapshotType()
        
        // Adding items to default section
        snapshot.appendSections([Self.defaultSectionIdentifier])
        snapshot.appendItems(ContestController.shared.contests, toSection: Self.defaultSectionIdentifier)
        
        // Applying the snapshot
        dataSource.apply(snapshot)
    }
    
    // MARK: - Configuring context menus
    
    // On long press (or right click for iPad) the cell should reveal the edit action
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            // Creating the edit action
            let editAction = UIAction(title: "Edit Contest", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { action in
                // If user tapped on the edit button, perform `editContest` segue
                // Set `sender` to be the cell for which the context menu configuration was created
                self.performSegue(withIdentifier: Self.editContestSegueIdentifier, sender: collectionView.cellForItem(at: indexPath))
            }
            
            // Returning menu with the configured actions
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [editAction])
        }
    }
    
    // MARK: - Segues
    
    /// Creates a `ViewContestTableViewController` and sets up its contest controller
    /// - Parameters:
    ///   - coder: coder passed from Storyboard
    ///   - sender: contest collection view cell that initialized the segue
    /// - Returns: new `ViewContestTableViewController` with configured contest controller
    @IBSegueAction func viewContest(_ coder: NSCoder, sender: ContestCollectionViewCell?) -> ViewContestTableViewController? {
        // Making sure `sender` is not `nil` and there is a valid index path for sender
        guard let sender = sender,
              let contestIndex = collectionView.indexPath(for: sender)?.item else { return nil }
        
        // Returning view contest controller with contest index
        return ViewContestTableViewController(contestIndex: contestIndex, coder: coder)
    }
    
    /// Creates an `AddEditContestTableViewController` and sets up its contest controller and delegate
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - sender: contest collection view cell or bar button item that initialized the segue
    ///   - segueIdentifier: segue identifier
    /// - Returns: new `AddEditContestTableViewController` with configured contest controller and delegate
    @IBSegueAction func addEditContest(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> AddEditContestTableViewController? {
        // If we are editing contest, make sure the sender is a `ContestCollectionViewCell` and there is a valid index path for the cell
        if segueIdentifier == Self.editContestSegueIdentifier,
           let cell = sender as? ContestCollectionViewCell,
           let contestIndex = collectionView.indexPath(for: cell)?.item {
            // Create new view controller
            let controller = AddEditContestTableViewController(coder: coder, contestIndex: contestIndex)
            // Set up its delegate
            controller?.delegate = self
            return controller
        } else if segueIdentifier == Self.addContestSegueIdentifier {
            // If we are adding a new contest, create a new view controller with `contestIndex` set to nil
            let controller = AddEditContestTableViewController(coder: coder, contestIndex: nil)
            // Set up its delegate
            controller?.delegate = self
            return controller
        } else {
            // Return nothing otherwise
            return nil
        }
    }
    
    // MARK: - Undo / Redo
    
    /// Removes contest from contest list, updates collection view and creates undo action
    /// - Parameter indexPath: index path for contest to remove
    /// - Parameter initiatedByUser: indicates whether this function was called after a user action or by an undo manager. This parameter is used to properly set the action name.
    func removeContest(for indexPath: IndexPath, initiatedByUser: Bool) {
        // Removing contest from the contest array and remembering its value
        let removedContest = ContestController.shared.contests.remove(at: indexPath.item)
        // Updating collection view
        updateCollectionView()
        
        // Setting up undo action
        undoManager?.setActionName(initiatedByUser ? "Remove Contest" : "Add Contest")
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            targetSelf.addContest(removedContest, at: indexPath, initiatedByUser: !initiatedByUser)
        }
    }
    
    /// Adds contest to the specified location,, creates undo action, and updates collection view
    /// - Parameters:
    ///   - contest: contest to add
    ///   - indexPath: index to put the contest at at
    ///   - initiatedByUser: indicates whether this function was called after a user action or by an undo manager. This parameter is used to properly set the action name.
    func addContest(_ contest: Contest, at indexPath: IndexPath, initiatedByUser: Bool) {
        // Inserting the contest into contest list and updating collection view
        ContestController.shared.contests.insert(contest, at: indexPath.item)
        
        // Sorting the contest list by year to restore the order after adding new contests
        ContestController.shared.contests.sort { $0.year > $1.year }
        
        // Saving the new index after sorting for undo manager
        let newIndex = ContestController.shared.contests.firstIndex(of: contest)!
        
        updateCollectionView()
        
        // Setting up undo action
        undoManager?.setActionName(initiatedByUser ? "Add Contest" : "Remove Contest")
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            targetSelf.removeContest(for: IndexPath(item: newIndex, section: 0), initiatedByUser: !initiatedByUser)
        }
    }
    
    /// Changes contest at the specified location
    /// - Parameters:
    ///   - contest: new contest value
    ///   - indexPath: contest position
    func changeContest(_ contest: Contest, at indexPath: IndexPath) {
        // Making sure index path is valid
        guard indexPath.item < ContestController.shared.contests.count else {
            print("Error: Attempting to change contest that does not exist")
            return
        }
        
        // Saving the old contest
        let oldContest = ContestController.shared.contests[indexPath.item]
        // Replacing it
        ContestController.shared.contests[indexPath.item] = contest
        // Updating collection view
        updateCollectionView()
        
        // Setting up undo action
        undoManager?.setActionName("Change Contest")
        undoManager?.registerUndo(withTarget: self) { targetSelf in
            targetSelf.changeContest(oldContest, at: indexPath)
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

// MARK: - AddEditContest VC delegate

extension ContestListCollectionViewController: AddEditContestTableViewControllerDelegate {

    /// Called when act list was not changed. Dismisses the view controller that called this method and updates the collection view
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when a contest should be removed from contest list. Dismisses the view controller that called this method and removes the contest at specified index path
    /// - Parameter indexPath: index path of the act that should be deleted
    func dismissViewControllerAndDeleteContestAt(_ indexPath: IndexPath) {
        removeContest(for: indexPath, initiatedByUser: true)
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when a contest should be added to the end of contest list. Dismisses the view controller that called this method and adds the act to the act list
    /// - Parameter act: the act to add to the act list
    func dismissViewControllerAndAddContest(_ contest: Contest) {
        addContest(contest, at: IndexPath(item: ContestController.shared.contests.count, section: 0), initiatedByUser: true)
        dismiss(animated: true, completion: nil)
    }
    
    /// Called when a contest should be changed. Dismisses the view controller that called this method and changes the contest at specified location
    /// - Parameters:
    ///   - contest: new contest value
    ///   - indexPath: contest location
    func dismissViewControllerAndChangeContest(_ contest: Contest, at indexPath: IndexPath) {
        changeContest(contest, at: indexPath)
        dismiss(animated: true, completion: nil)
    }
}
