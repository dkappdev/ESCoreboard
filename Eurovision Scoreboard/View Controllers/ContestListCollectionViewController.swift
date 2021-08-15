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
    
    /// Reuse identifier for contest cell
    private static let contestCellReuseIdentifier = "Contest"
    /// addContest segue identifier
    private static let addContestSegueIdentifier = "addContest"
    /// editContest segue identifier
    private static let editContestSegueIdentifier = "editContest"
    /// Idenetifier for collection view's only section
    static let defaultSectionIdentifier = 0
    
    /// Model controller object responsible for handling app state. It is initialized in `SceneDelegate` after the view controller's initialized has already been called', which is why it's an implicitly unwrapped optional.
    var contestController: ContestController!
    /// The collection view diffable data source
    var dataSource: DataSourceType!
    
    // MARK: - VC Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting up data source and layout
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
        
        updateCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // Explicitly setting toolbar visibility in case we want to hide it later
        navigationController?.setToolbarHidden(false, animated: true)
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
        let elementsInGroup = isCompact ? 2 : 4
        
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
    func updateCollectionView() {
        // Creating a new snapshot
        var snapshot = DataSourceSnapshotType()
        
        // Sorting the contest list by year to restore the order after adding new contests
        contestController.contests.sort { $0.year > $1.year }
        
        // Adding items to default section
        snapshot.appendSections([Self.defaultSectionIdentifier])
        snapshot.appendItems(contestController.contests, toSection: Self.defaultSectionIdentifier)
        
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
                self.performSegue(withIdentifier: "editContest", sender: collectionView.cellForItem(at: indexPath))
            }
            
            // Returning menu with the configured actions
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [editAction])
        }
    }
    
    // MARK: - Configuring buttons
    
    /// Called when user taps the 'Reset' bar button.
    /// When user tries to reset the app state, we ask them twice if they are sure they want to reset.
    /// - Parameter sender: the button that was tapped
    @IBAction func resetBarButtonTapped(_ sender: UIBarButtonItem) {
        // Presenting both warning as action sheets
        let firstAlertController = UIAlertController(title: "Are you sure you want to reset your contest list? This cannot be undone!", message: nil, preferredStyle: .actionSheet)
        
        let firstCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // The first reset action causes another alert controller to pop up
        let firstResetAction = UIAlertAction(title: "Reset", style: .destructive) { action in
            let secondAlertController = UIAlertController(title: "All your data will be lost! Are you absolutely sure?", message: nil, preferredStyle: .actionSheet)
            
            let secondCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            // The second reset action actually does the resetting
            let secondResetAction = UIAlertAction(title: "Reset", style: .destructive) { action in
                // Resetting the state
                self.contestController.resetState()
                // Updating the collection view as the contest list was changed
                self.updateCollectionView()
            }
            
            secondAlertController.addAction(secondCancelAction)
            secondAlertController.addAction(secondResetAction)
            // Setting the source bar button item for iPadOS
            secondAlertController.popoverPresentationController?.barButtonItem = sender
            
            // Presenting the second alert controller
            self.present(secondAlertController, animated: true, completion: nil)
        }
        
        firstAlertController.addAction(firstCancelAction)
        firstAlertController.addAction(firstResetAction)
        // Setting the source bar button item for iPadOS
        firstAlertController.popoverPresentationController?.barButtonItem = sender
        
        // Presenting the first alert controller
        present(firstAlertController, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If we are editing a contest or adding a new one, set the destination VC as modal in presentation to prevent user from accidentally swiping down and dismissing all changes
        if segue.identifier == Self.addContestSegueIdentifier || segue.identifier == Self.editContestSegueIdentifier {
            segue.destination.isModalInPresentation = true
        }
    }
    
    /// Called when user taps  'Cancel' to dismiss changes. Nothing is done in this method as the contest list was not changed
    /// - Parameter segue: unwind segue
    @IBAction func unwindToContestList(segue: UIStoryboardSegue) {
    }
    
    /// Creates a `ViewContestTableViewController` and sets up its contest controller
    /// - Parameters:
    ///   - coder: coder passed from Storyboard
    ///   - sender: contest collection view cell that initialized the segue
    /// - Returns: new `ViewContestTableViewController` with configured contest controller
    @IBSegueAction func viewContest(_ coder: NSCoder, sender: ContestCollectionViewCell?) -> ViewContestTableViewController? {
        // Making sure `sender` is not `nil` and there is a valid index path for sender
        guard let sender = sender,
              let contestIndex = collectionView.indexPath(for: sender)?.item else { return nil }
        
        // Creating contest view controller with contest index
        let controller = ViewContestTableViewController(contestIndex: contestIndex, coder: coder)
        // Configuring contest controller via dependency injection
        controller?.contestController = contestController
        
        return controller
    }
    
    /// Creates a `AddEditContestTableViewController` and sets up its contest controller and delegate
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
            // Set up its contest controller and delegate
            controller?.contestController = contestController
            controller?.delegate = self
            return controller
        } else if segueIdentifier == Self.addContestSegueIdentifier {
            // If we are adding a new contest, create a new view controller with `contestIndex` set to nil
            let controller = AddEditContestTableViewController(coder: coder, contestIndex: nil)
            // Set up its contest controller and delegate
            controller?.contestController = contestController
            controller?.delegate = self
            return controller
        } else {
            // Return nothing otherwise
            return nil
        }
    }
    
}

// MARK: - AddEditContest VC delegate

extension ContestListCollectionViewController: AddEditContestTableViewControllerDelegate {
    /// Dismisses modally presented view controller and updates collection view
    func dismissViewController() {
        dismiss(animated: true, completion: nil)
        updateCollectionView()
    }
}
