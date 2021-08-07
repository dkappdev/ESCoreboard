//
//  ContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import UIKit

private let reuseIdentifier = "Act"

class ContestTableViewController: UITableViewController {

    private static let defaultSectionIdentifier = 0
    typealias DataSourceType = UITableViewDiffableDataSource<Int, Act>
    var dataSource: DataSourceType!

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

        dataSource = createDataSource()
        tableView.dataSource = dataSource

        let contest = contestController.contests[contestIndex]
        
        navigationItem.title = "\(contest.hostCountry.flagEmoji) \(contest.year) - \(contest.hostCityName)"
        
        updateTableView(animated: false)
    }

    func updateTableView(animated: Bool) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Act>()
        
        snapshot.appendSections([Self.defaultSectionIdentifier])
        snapshot.appendItems(contestController.contests[contestIndex].acts, toSection: Self.defaultSectionIdentifier)
        
        dataSource.apply(snapshot, animatingDifferences: animated, completion: nil)
    }

    func createDataSource() -> DataSourceType {
        return DataSourceType(tableView: tableView) { tableView, indexPath, act in
            let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ActTableViewCell

            cell.update(with: act)

            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
