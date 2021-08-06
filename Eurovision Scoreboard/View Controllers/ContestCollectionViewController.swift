//
//  YearCollectionViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import UIKit

private let reuseIdentifier = "Contest"

class ContestCollectionViewController: UICollectionViewController {
    
    typealias DataSourceType = UICollectionViewDiffableDataSource<Int, Contest>
    
    private static let defaultSectionIdentifier = 0
    
    var contests: [Contest]!
    var dataSource: DataSourceType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contests = Contest.loadFromFile() ?? Contest.defaultContests()
        
        dataSource = createDataSource()
        collectionView.dataSource = dataSource
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
        
        updateCollectionView()
    }
    
    func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Contest>()
        
        snapshot.appendSections([ContestCollectionViewController.defaultSectionIdentifier])
        snapshot.appendItems(contests, toSection: ContestCollectionViewController.defaultSectionIdentifier)
        
        dataSource.apply(snapshot)
    }
    
    func createLayout(isCompact: Bool) -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let elementsInGroup = isCompact ? 2 : 3
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(CGFloat(1.0 / Double(elementsInGroup))))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: elementsInGroup)
        group.interItemSpacing = .fixed(12)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        section.interGroupSpacing = CGFloat(12)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        collectionView.collectionViewLayout = createLayout(isCompact: traitCollection.horizontalSizeClass == .compact)
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
}
