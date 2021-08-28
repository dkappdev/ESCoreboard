//
//  AddEditContestTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 08.08.2021.
//

import UIKit

/// Static table view responsible for editing contests
class AddEditContestTableViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    /// Contest year text field
    @IBOutlet var yearTextField: UITextField!
    /// Host city text field
    @IBOutlet var hostCityTextField: UITextField!
    
    /// Label that displays currently picked country
    @IBOutlet var hostCountryLabel: UILabel!
    /// Host country picker view
    @IBOutlet var hostCountryPickerView: UIPickerView!
    
    /// Cell which user can click to delete the current contest. It should be hidden when user is adding a new contest. Because of this, we store the outlet to the cell in addition to its `IndexPath`
    @IBOutlet var deleteContestCell: UITableViewCell!
    
    /// Button which user can click to save changes
    @IBOutlet var saveBarButton: UIBarButtonItem!
    
    /// Button which user can click to discard changes
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    
    
    // MARK: - Properties
    
    /// Index path of the 'Acts' cell which user can press to edit act list
    let actsCellIndexPath = IndexPath(row: 0, section: 3)
    /// Index path of the 'Delete Contest' cell which user can press to delete the current contest
    let deleteContestCellIndexPath = IndexPath(row: 0, section: 4)
    
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
    
    /// editActList segue identifier
    private static let editActListSegueIdentifier = "editActList"
    
    /// Country that user has picked using the picker view, by default it's set to `Country.fullCountryList.first!`
    var pickedCountry: Country!
    /// Index of the contest this view controller is displaying. This property represents index of the contest in `contestController`'s `contests` array.
    let contestIndex: Int?
    /// Act list for the current contest. Its default value is `[]`, which is changed later during initialization if the view controller is editing an existing contest instead of adding a new one.
    /// Acts are not stored directly in the contest instance, since changes should only be saved after user taps the 'Save' button.
    var acts: [Act] = []
    /// If view controller is editing an existing contest, this property stores the contest's original year.
    ///
    /// Part of input validation is making sure user doesn't input a year that's already used by another contest. It's done by comparing the year entered by user to years of all other contests. If the value is not unique, the 'Save' button is disabled.
    ///
    /// Let's say we have three contests, which were held in years 2019 through 2021. In that case the array of year will be `[2021, 2020, 2019]`. Now let's say we want to edit the second contest (held in 2020). In that case input validation will fail because the array of years already contains value `2020`. To avoid that, during initalization we save the contest's original year. If during input validation we find that the year entered by user is the same as `initialContestYear`, we proceed and don't check whether the value is unique. We already know it is, because it was not changed.
    var originalContestYear: Int?
    
    /// Delegate responsible for dismissing the view controller.
    weak var delegate: AddEditContestTableViewControllerDelegate?
    
    // MARK: - Initializers
    
    /// Custom initializer with contest index parameter. Only this initializer must be used.
    /// - Parameters:
    ///   - contestIndex: index of the contest this view controller is editing (`nil` if we are creating a new contest)
    ///   - coder: coder provided by Storyboard
    init?(coder: NSCoder, contestIndex: Int?) {
        self.contestIndex = contestIndex
        super.init(coder: coder)
    }
    
    /// Required initializer that should never be used. It is not implemented.
    /// - Parameter coder: coder provided by Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setting this VC as modal in presentation to prevent user from accidentally swiping down and dismissing all changes
        isModalInPresentation = true
        
        // Setting `self` as the presentation controller delegate to respond to swipe down gesture
        navigationController?.presentationController?.delegate = self
        
        // Setting `self` as the delegate and data source for picker view
        hostCountryPickerView.dataSource = self
        hostCountryPickerView.delegate = self
        
        // Setting `self` as the delegate of all text fields
        // We are doing this to later hide the keyboard the keyboard when user presses 'return' key
        yearTextField.delegate = self
        hostCityTextField.delegate = self
        
        if let contestIndex = contestIndex {
            // If `contestIndex` is not `nil`, we are editing an existing contest
            
            // Getting the contest from contest controller
            let contest = ContestController.shared.contests[contestIndex]
            
            // Initializing act list and the original contest year
            acts = contest.acts
            originalContestYear = contest.year
            pickedCountry = contest.hostCountry
            
            // Populating text fields, labels, and country picker with contest information
            yearTextField.text = "\(contest.year)"
            hostCountryLabel.text = pickedCountry.prettyNameString
            hostCountryPickerView.selectRow(Country.fullCountryList.firstIndex(of: contest.hostCountry)!, inComponent: 0, animated: false)
            hostCityTextField.text = contest.hostCityName
            
            // Setting up navigation item
            navigationItem.title = "Edit Contest"
        } else {
            // If `contestIndex` is `nil`, we are adding a new contest
            
            // Picking first country by default
            // Country list is never empty, so we can use force unwrapping
            pickedCountry = Country.fullCountryList.first!
            
            // Updating the country label
            hostCountryLabel.text = pickedCountry.prettyNameString
            
            // Hiding the 'Delete' cell
            deleteContestCell.isHidden = true
            // Setting up navigation item
            navigationItem.title = "Add Contest"
        }
        
        // Updating save button state
        // If we are adding a new contest, this will disable the 'Save' button
        updateSaveButtonState()
        
        // Adding a tap gesture recognizer to hide keyboard whenever user taps outside text fields
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Dismissing keyboard
    
    /// Dismisses keyboard
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Input validation
    
    func textFieldContainsValidYear(_ textField: UITextField) -> Bool {
        // Stores whether user has submitted a valid year
        var isValidYear: Bool
        // Getting text from text field
        let yearString = textField.text ?? ""
        // Getting years from all contests
        let contestYears = ContestController.shared.contests.map { $0.year }
        
        if let year = Int(yearString) {
            // If the text can be converted to an integer, continue checking.
            // Make sure the year is greater than or equal to 1956 (the year first contest was held),
            // And is no greater than the next year,
            // And if the year was changed by user, make sure it is unique.
            // See `originalContestYear` documentation for more details.
            isValidYear = year >= 1956 && year <= currentYearAsNumber + 1 && (year == originalContestYear || !contestYears.contains(year))
        } else {
            // Otherwise, if text from year text field is not a number, the year is not valid
            isValidYear = false
        }
        
        return isValidYear
    }
    
    /// Performs input validation and enables the 'Save' button only when input is valid
    func updateSaveButtonState() {
        // Getting text from other text fields
        let hostCityText = hostCityTextField.text ?? ""
        
        // The save button is enabled only when user has entered a valid year and entered a host city
        saveBarButton.isEnabled = textFieldContainsValidYear(yearTextField) && !hostCityText.isEmpty
    }
    
    // MARK: - Responding to changes
    
    /// Called whenever user changed contents of a text field
    @IBAction func textEditingChanged() {
        // Every time user made a change to a text field, we update the state of 'Save' button
        updateSaveButtonState()
    }
    
    // MARK: - Configuring buttons
    
    /// Called when user taps the 'Save' button. Saves changes made by user
    /// - Parameter sender: bar button item that was tapped
    @IBAction func saveBarButtonTapped(_ sender: UIBarButtonItem) {
        // If user was able to press the 'Save' button, we already know input is valid, so we force unwrap
        let country = pickedCountry!
        let newContest = Contest(hostCountry: country, hostCityName: hostCityTextField.text!, year: Int(yearTextField.text!)!, acts: acts)
        
        if let contestIndex = contestIndex {
            // If we are editing an existing contest, save changes made to it
            delegate?.dismissViewControllerAndChangeContest(newContest, at: IndexPath(item: contestIndex, section: 0))
        } else {
            // Otherwise append the new contest to the contests array
            delegate?.dismissViewControllerAndAddContest(newContest)
        }
        
        // Asking delegate to dismiss the view controller
        delegate?.dismissViewController()
    }
    
    /// Called when user taps the  'Cancel' button. Ask the user for confirmation
    /// - Parameter sender: bar button item that was tapped
    @IBAction func cancelBarButtonTapped(_ sender: UIBarButtonItem) {
        confirmCancel()
    }
    
    // MARK: - Applying changes
    
    /// Ask the user whether or not they want to discard changes and potentially dismisses the view controller
    func confirmCancel() {
        // If user attempted to dismiss VC, ask them if they are sure they want to dismiss changes
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.delegate?.dismissViewController()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.popoverPresentationController?.barButtonItem = cancelBarButton
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row on selection
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath == actsCellIndexPath {
            // If user tapped the 'Acts' cell, push the table view controller that displays acts
            performSegue(withIdentifier: Self.editActListSegueIdentifier, sender: nil)
        } else if indexPath == deleteContestCellIndexPath {
            // If user tapped the 'Delete Contest' cell, make sure there is a valid contest index
            guard let contestIndex = contestIndex else { return }
            
            // And ask user for confirmation with an action sheet
            let alertController = UIAlertController(title: "Are you sure you want to delete this contest from your list?", message: nil, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
                // If user confirms their intention do delete contest, ask delegate to update the contests array in contest controller
                self.delegate?.dismissViewControllerAndDeleteContestAt(IndexPath(item: contestIndex, section: 0))
            }
            
            // Setting up actions
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            alertController.popoverPresentationController?.sourceView = tableView.cellForRow(at: indexPath)
            
            // And presenting the alert controller
            present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Creates an `EditActsTableViewController` and sets up its delegate
    /// - Parameter coder: coder provided by storyboard
    /// - Returns: new `EditActsTableViewController` with configured delegate
    @IBSegueAction func editActs(_ coder: NSCoder) -> EditActsTableViewController? {
        // If year is valid, we convert text field text to `Int`, otherwise we set `contestYear` to nil
        let contestYear = textFieldContainsValidYear(yearTextField) ? Int(yearTextField.text!)! : nil
        // Creating `EditActsTableViewController` with act list and contest year
        let controller = EditActsTableViewController(coder: coder, acts: acts, contestYear: contestYear)
        // And setting up its delegate
        controller?.delegate = self
        return controller
    }
    
}

// MARK: - Text field delegate

// Adopting `UITextFieldDelegate` to respond to 'return' key press
extension AddEditContestTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Resigning first responder when user presses 'return'
        textField.resignFirstResponder()
        return false
    }
}

// MARK: - Edit Acts VC delegate

extension AddEditContestTableViewController: EditActsTableViewControllerDelegate {
    /// Called when act list was changed. Saves the new act that was list provided by `EditActsTableViewController`
    /// - Parameter acts: new act list
    func didChangeActs(_ acts: [Act]) {
        self.acts = acts
    }
}

// MARK: - UIPickerView data source

extension AddEditContestTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // There's only one component since we are only choosing a country
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Country.fullCountryList.count
    }
}

// MARK: - AddEdit delegate

extension AddEditContestTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Returning pretty string for country as the title for picker view row
        return Country.fullCountryList[row].prettyNameString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Setting the `pickedCountry` property for use later
        pickedCountry = Country.fullCountryList[row]
        // Updating the country label
        hostCountryLabel.text = pickedCountry.prettyNameString
        
    }
}

// MARK: - Modal delegate

extension AddEditContestTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmCancel()
    }
}
