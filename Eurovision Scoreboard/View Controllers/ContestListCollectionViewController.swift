//
//  YearCollectionViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import UIKit

private let reuseIdentifier = "Contest"

class ContestListCollectionViewController: UICollectionViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<Int, Contest>
    
    static let defaultSectionIdentifier = 0
    
    var contestController: ContestController!
    var dataSource: DataSourceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
        
        updateCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Contest>()
        
        snapshot.appendSections([Self.defaultSectionIdentifier])
        snapshot.appendItems(contestController.contests, toSection: Self.defaultSectionIdentifier)
        
        dataSource.apply(snapshot)
    }
    
    func createLayout(isCompact: Bool) -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let elementsInGroup = isCompact ? 2 : 4
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(CGFloat(1.0 / Double(elementsInGroup))))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: elementsInGroup)
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        section.interGroupSpacing = CGFloat(12)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func createDataSource() -> DataSourceType {
        return DataSourceType(collectionView: collectionView) { collectionView, indexPath, contest in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ContestCollectionViewCell
            cell.hostCountryFlagLabel.text = contest.hostCountry.flagEmoji
            cell.yearAndHostCityLabel.text = "\(contest.year) - \(contest.hostCityName)"
            cell.layer.cornerRadius = 12
            
            return cell
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit Contest", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { action in
                self.performSegue(withIdentifier: "editContest", sender: collectionView.cellForItem(at: indexPath))
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [editAction])
        }
    }
    
    @IBSegueAction func viewContest(_ coder: NSCoder, sender: ContestCollectionViewCell?) -> ViewContestTableViewController? {
        guard let sender = sender,
              let contestIndex = collectionView.indexPath(for: sender)?.item else { return nil }
        
        let controller = ViewContestTableViewController(contestIndex: contestIndex, coder: coder)
        controller?.contestController = contestController
        
        return controller
    }
    
    @IBSegueAction func addEditContest(_ coder: NSCoder, sender: Any?, segueIdentifier: String?) -> AddEditContestTableViewController? {
        if segueIdentifier == "editContest",
           let cell = sender as? ContestCollectionViewCell,
           let indexPath = collectionView.indexPath(for: cell) {
            let controller = AddEditContestTableViewController(coder: coder, mode: .editingContest, contestIndex: indexPath.item)
            controller?.contestController = contestController
            controller?.delegate = self
            return controller
        } else if segueIdentifier == "addContest" {
            let controller = AddEditContestTableViewController(coder: coder, mode: .addingContest, contestIndex: nil)
            controller?.contestController = contestController
            controller?.delegate = self
            return controller
        } else {
            return nil
        }
    }
    
    @IBAction func unwindToContestList(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func resetBarButtonTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Are you sure you want to reset your contest list? This cannot be undone!", message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            let secondAlertController = UIAlertController(title: "All your data will be lost! Are you absolutely sure?", message: nil, preferredStyle: .actionSheet)
            
            let secondCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let secondDeleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.contestController.resetState()
                self.updateCollectionView()
            }
            
            secondAlertController.addAction(secondCancelAction)
            secondAlertController.addAction(secondDeleteAction)
            secondAlertController.popoverPresentationController?.barButtonItem = sender
            
            self.present(secondAlertController, animated: true, completion: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        alertController.popoverPresentationController?.barButtonItem = sender
        
        present(alertController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addContest" || segue.identifier == "editContest" {
            segue.destination.isModalInPresentation = true
        }
    }
    
}

extension ContestListCollectionViewController: AddEditContestTableViewControllerDelegate {
    func shouldDismissViewController() {
        dismiss(animated: true, completion: nil)
        updateCollectionView()
    }
}
