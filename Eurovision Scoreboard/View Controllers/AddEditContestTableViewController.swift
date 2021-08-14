//
//  AddEditContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 08.08.2021.
//

import UIKit

class AddEditContestTableViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    /// Year when contest took place
    @IBOutlet var yearTextField: UITextField!
    /// Host country
    @IBOutlet var hostCountryTextField: UITextField!
    /// Country flag as an emoji
    @IBOutlet var countryFlagTextField: UITextField!
    /// Host city
    @IBOutlet var hostCityTextField: UITextField!
    
    /// Cell which user can click to delete the current contest. It should be hidden when user is adding a new contest. Because of this, we store the outlet to the cell in addition to its `IndexPath`
    @IBOutlet var deleteContestCell: UITableViewCell!
    
    /// Button which user can click to save changes
    @IBOutlet var saveBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    /// Property representing the current year as an integer. It is calculated during initialization by executing the closure.
    let currentYearAsNumber: Int = {
        let dateFormatter = DateFormatter()
        // Set the date formatter to only display the year
        dateFormatter.dateFormat = "yyyy"
        // Get current year as a string
        let yearString = dateFormatter.string(from: Date())
        // And cast it to `Int`
        // Since date format is "yyyy", the cast is guaranteed to succeed, so we force unwrap the optional
        let yearAsInt = Int(yearString)!
        return yearAsInt
    }()
    
    /// Index path of the 'Acts' cell which user can press to edit act list
    let actsCellIndexPath = IndexPath(row: 0, section: 4)
    /// Index path of the 'Delete Contest' cell which user can press to delete the current contest
    let deleteContestCellIndexPath = IndexPath(row: 0, section: 5)
    
    /// Index of the contest this view controller is displaying. This property represents index of the contest in `contestController`'s `contests` array.
    let contestIndex: Int?
    /// Act list for the current contest. Its default value is `[]`, which is changed later during initialization if the view controller is editing an existing contest instead of adding a new one.
    var acts: [Act] = []
    /// If view controller is editing an existing contest, this property stores the contest's original year.
    ///
    /// Part of input validation is making sure user doesn't input a year that's already used by another contest. It's done by comparing the year entered by user to years of all other contests. If the value is not unique, the 'Save' button is disabled.
    ///
    /// Let's say we have three contests, which were held in years 2019 through 2021. In that case the array of year will be `[2021, 2020, 2019]`. Now let's say we want to edit the second contest (held in 2020). In that case input validation will fail because the array of years already contains value `2020`. To avoid that, during initalization we save the contest's original year. If during input validation we find that the year entered by user is the same as `initialContestYear`, we proceed and don't check whether the value is unique. We already know it is, because it was not changed.
    var initialContestYear: Int?
    
    var contestController: ContestController!
    weak var delegate: AddEditContestTableViewControllerDelegate?
    
    init?(coder: NSCoder, contestIndex: Int?) {
        self.contestIndex = contestIndex
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let contestIndex = contestIndex {
            let contest = contestController.contests[contestIndex]
            yearTextField.text = "\(contest.year)"
            hostCountryTextField.text = contest.hostCountry.name
            countryFlagTextField.text = contest.hostCountry.flagEmoji
            hostCityTextField.text = contest.hostCityName
            acts = contest.acts
            initialContestYear = contest.year
            navigationItem.title = "Edit Contest"
        } else {
            deleteContestCell.isHidden = true
            navigationItem.title = "Add Contest"
        }
        
        yearTextField.delegate = self
        hostCountryTextField.delegate = self
        countryFlagTextField.delegate = self
        hostCityTextField.delegate = self
        
        updateSaveButtonState()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
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
                self.delegate?.dismissViewController()
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
            isValidYear = year >= 1956 && year <= currentYearAsNumber + 1 && (year == initialContestYear || !contestYears.contains(year))
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
    
    @IBAction func saveBarButtonTapped(_ sender: UIBarButtonItem) {
        // if the user was able to press this button, we already know the input is valid
        let country = Country(name: hostCountryTextField.text!, flagEmoji: countryFlagTextField.text!)
        let newContest = Contest(hostCountry: country, hostCityName: hostCityTextField.text!, year: Int(yearTextField.text!)!, acts: acts)
        
        if let contestIndex = contestIndex {
            contestController.contests[contestIndex] = newContest
        } else {
            contestController.contests.append(newContest)
        }
        
        delegate?.dismissViewController()
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
