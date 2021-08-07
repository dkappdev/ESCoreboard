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
    
    func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Contest>()
        
        snapshot.appendSections([ContestListCollectionViewController.defaultSectionIdentifier])
        snapshot.appendItems(contestController.contests, toSection: ContestListCollectionViewController.defaultSectionIdentifier)
        
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
            cell.contentView.layer.cornerRadius = 12
            
            return cell
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
    }
    
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Edit Contest", image: UIImage(systemName: "pencil"), identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off) { action in
                
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [editAction])
        }
    }
    
    @IBSegueAction func viewContest(_ coder: NSCoder, sender: ContestCollectionViewCell?) -> ContestTableViewController? {
        guard let sender = sender,
              let contestIndex = collectionView.indexPath(for: sender)?.item else { return nil }
        
        let controller = ContestTableViewController(contestIndex: contestIndex, coder: coder)
        controller?.contestController = contestController
        
        return controller
    }
    
    
}
