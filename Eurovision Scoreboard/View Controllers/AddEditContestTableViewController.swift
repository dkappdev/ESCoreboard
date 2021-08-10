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
    @IBOutlet var saveBarButton: UIBarButtonItem!
    
    let currentYear: Int = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let yearString = dateFormatter.string(from: Date())
        let yearAsInt = Int(yearString)! // guaranteed to succeed, so we use force unwrapping
        return yearAsInt
    }()
    
    let actsCellIndexPath = IndexPath(row: 0, section: 4)
    let deleteContestCellIndexPath = IndexPath(row: 0, section: 5)
    
    var acts: [Act] = []
    var initialContestYear: Int?
    
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
            acts = contest.acts
            initialContestYear = contest.year
        } else if mode == .addingContest {
            deleteContestCell.isHidden = true
        }
        
        yearTextField.delegate = self
        hostCountryTextField.delegate = self
        countryFlagTextField.delegate = self
        hostCityTextField.delegate = self
        
        updateSaveButtonState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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
    
    @IBAction func textEditingChanged() {
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        let yearText = yearTextField.text ?? ""
        var isValidYear = false
        let contestYears = contestController.contests.map { $0.year }
        if let year = Int(yearText) {
            isValidYear = year >= 1956 && year <= currentYear + 1 && (!contestYears.contains(year) || year == initialContestYear)
        }
        
        let hostCountryText = hostCountryTextField.text ?? ""
        let hostCityText = hostCityTextField.text ?? ""
        
        saveBarButton.isEnabled = isValidYear && !hostCountryText.isEmpty && !hostCityText.isEmpty && containsSingleEmoji(countryFlagTextField)
    }
    
    func containsSingleEmoji(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
              text.count == 1 else { return false }
        
        return text.unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }
    
    @IBAction func doneBarButtonTapped(_ sender: UIBarButtonItem) {
        
    }
}

extension AddEditContestTableViewController: EditActsTableViewControllerDelegate {
    func didChangeActs(_ acts: [Act]) {
        self.acts = acts
    }
}

extension AddEditContestTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
