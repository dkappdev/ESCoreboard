//
//  AddEditContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 08.08.2021.
//

import UIKit

class AddEditContestTableViewController: UITableViewController {
    
    enum Mode {
        case addingContest
        case editingContest
    }
    
    @IBOutlet var yearTextField: UITextField!
    @IBOutlet var hostCountryTextField: UITextField!
    @IBOutlet var countryFlagTextField: UITextField!
    @IBOutlet var hostCityTextField: UITextField!
    @IBOutlet var deleteContestCell: UITableViewCell!
    
    let actsCellIndexPath = IndexPath(row: 0, section: 4)
    let deleteContestCellIndexPath = IndexPath(row: 0, section: 5)
    
    var acts: [Act] = []
    
    var contestController: ContestController!
    let mode: Mode
    let contestIndex: Int?
    weak var delegate: AddEditContestTableViewControllerDelegate?
    
    init?(coder: NSCoder, mode: Mode, contestIndex: Int?) {
        self.contestIndex = contestIndex
        self.mode = mode
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if mode == .editingContest,
           let contestIndex = contestIndex {
            let contest = contestController.contests[contestIndex]
            yearTextField.text = "\(contest.year)"
            hostCountryTextField.text = contest.hostCountry.name
            countryFlagTextField.text = contest.hostCountry.flagEmoji
            hostCityTextField.text = contest.hostCityName
        } else if mode == .addingContest {
            deleteContestCell.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath == actsCellIndexPath {
            performSegue(withIdentifier: "editActList", sender: tableView.cellForRow(at: indexPath))
        } else if indexPath == deleteContestCellIndexPath {
            guard let contestIndex = contestIndex else { return }
            
            let alertController = UIAlertController(title: "Are you sure you want to delete this contest from your list? This cannot be undone!", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                self.contestController.contests.remove(at: contestIndex)
                self.delegate?.shouldDismissViewController()
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            alertController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
            
            present(alertController, animated: true, completion: nil)
        }
    }

    @IBSegueAction func editActs(_ coder: NSCoder) -> EditActsTableViewController? {
        let controller = EditActsTableViewController(coder: coder, acts: acts)
        controller?.delegate = self
        return controller
    }
}

extension AddEditContestTableViewController: EditActsTableViewControllerDelegate {
    func didChangeActs(_ acts: [Act]) {
        self.acts = acts
    }
}
