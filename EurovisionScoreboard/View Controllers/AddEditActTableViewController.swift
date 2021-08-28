//
//  AddEditActTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

/// Static table view controller responsible for editing individual acts
class AddEditActTableViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet var songNameTextField: UITextField!
    /// Artist name text field
    @IBOutlet var artistNameTextField: UITextField!
    
    /// Label that displays currently picked country
    @IBOutlet var countryLabel: UILabel!
    /// Country picked view
    @IBOutlet var countryPickerView: UIPickerView!
    
    /// Cell which user can click to delete the current act. It should be hidden when user is adding a new act. Because of this, we store the outlet the the cell in addition to its `IndexPath`
    @IBOutlet var deleteActCell: UITableViewCell!
    
    /// Button which user can click to save changes
    @IBOutlet var saveBarButton: UIBarButtonItem!
    
    /// Button which user can click to discard changes
    @IBOutlet var cancelBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    /// Index path of the 'Delete Act' cell which user can press to delete the current act
    let deleteActCellIndexPath = IndexPath(row: 0, section: 3)
    
    /// Country that user has picked using the picker view, by default it's set to `Country.fullCountryList.first!` or `Country.moderCountryList.first!`, depending on contest year
    var pickedCountry: Country!
    
    var countryList: [Country]!
    
    /// Act list for the current contest
    var acts: [Act]
    /// Index of the act this view controller is editing. It is used to modify the acts array.
    var actIndex: Int?
    /// Year when contest is taking place
    let contestYear: Int?
    
    /// Delegate responsible for saving changes and dismissing the view controller
    weak var delegate: AddEditActTableViewControllerDelegate?
    
    // MARK: - Initializers
    
    /// Custom initializer with act list and index of the act to edit. Only this initializer must be used
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - acts: act list for the current contest
    ///   - actIndex: act to edit (`nil` if we are adding a new one)
    ///   - contestYear: year when contest is taking place
    init?(coder: NSCoder, acts: [Act], actIndex: Int?, contestYear: Int?) {
        self.acts = acts
        self.actIndex = actIndex
        self.contestYear = contestYear
        super.init(coder: coder)
    }
    
    /// Required initializer that should not be used. It is not implemented
    /// - Parameter coder: coder provided by Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    /// Choose between modern and full country list
    func setupCountryList() {
        // If contest year exists and is >= 2006, use the modern country list without Yugoslavia and 'Serbia and Montenegro', otherwise use the full country list
        if let contestYear = contestYear {
            countryList = contestYear >= 2006 ? Country.modernCountryList : Country.fullCountryList
        } else {
            countryList = Country.fullCountryList
        }
        
        if let actIndex = actIndex {
            // Getting the act
            let act = acts[actIndex]
            
            // If the country list does not contain the country user has previously picked, that means user has selected a country from full list (e.g. Yugoslavia) and then changed the contest year to >= 2006. In that case we should show full contest list instead of the modern one to avoid crashing
            if countryList.firstIndex(of: act.country) == nil {
                countryList = Country.fullCountryList
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCountryList()
        
        // Setting this VC as modal in presentation to prevent user from accidentally swiping down and dismissing all changes
        isModalInPresentation = true
        
        // Setting `self` as the presentation controller delegate to respond to swipe down gesture
        navigationController?.presentationController?.delegate = self
        
        // Setting `self` as the delegate and data source for picker view
        countryPickerView.dataSource = self
        countryPickerView.delegate = self
  
        // Setting `self` as the delegate of all text fields
        // We are doing this to later hide the keyboard the keyboard when user presses 'return' key
        songNameTextField.delegate = self
        artistNameTextField.delegate = self
        
        if let actIndex = actIndex {
            // If `actIndex` is not `nil`, we are editing an existing act
            
            // Getting the act
            let act = acts[actIndex]
            
            // Initializing the `pickedCountry` property
            pickedCountry = act.country
            
            // Populating text fields, labels, and country picker with act information
            songNameTextField.text = act.songName
            artistNameTextField.text = act.artistName
            countryLabel.text = act.country.prettyNameString
             
            countryPickerView.selectRow(countryList.firstIndex(of: act.country)!, inComponent: 0, animated: false)
            
            // Setting up navigation item
            navigationItem.title = "Edit Act"
        } else {
            // If `actindex` is `nil`, we are adding a new act
            
            // Picking first country by default
            // Country list is never empty, so we can use force unwrapping
            pickedCountry = countryList.first!

            // Updating the country label
            countryLabel.text = pickedCountry.prettyNameString
            // Hiding the 'Delete' cell
            deleteActCell.isHidden = true
            // Setting up navigation item
            navigationItem.title = "Add Act"
        }
        
        // Updating save button state
        // If we are adding a new act, this will disable the 'Save' button
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
    
    func updateSaveButtonState() {
        // Getting text from text fields
        let songName = songNameTextField.text ?? ""
        let artistName = artistNameTextField.text ?? ""
        
        // The save button is enabled only when all text fields are not empty
        saveBarButton.isEnabled = !songName.isEmpty && !artistName.isEmpty
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
        let newAct = Act(artistName: artistNameTextField.text!, songName: songNameTextField.text!, country: country)
        
        if let actIndex = actIndex {
            // If we are editing an existing act, tell the delegate to change the act and ask it to dismiss this view controller
            delegate?.dismissViewControllerAndChangeAct(newAct, at: IndexPath(row: actIndex, section: 0))
        } else {
            // Otherwise tell the delegate to add an act and ask it to dismiss this view controller
            delegate?.dismissViewControllerAndAddAct(newAct)
        }
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
        
        // Making sure user tapped the 'Delete Act' button, since this is the only selection we want to respond to
        if indexPath == deleteActCellIndexPath {
            // Telling the delegate that an act should be deleted and asking it dismiss the view controller
            // 'Delete' button is only visible when there is a non-nil act index, so we can force-unwrap
            delegate?.dismissViewControllerAndDeleteActAt(IndexPath(row: actIndex!, section: 0))
        }
    }
}

// MARK: - Text field delegate

// Adopting `UITextFieldDelegate` to respond to 'return' key press
extension AddEditActTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Resigning first responder when user presses 'return'
        textField.resignFirstResponder()
        return false
    }
}

extension AddEditActTableViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // There's only one component since we are only choosing a country
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
}

extension AddEditActTableViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Returning pretty string for country as the title for picker view row
        return countryList[row].prettyNameString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Setting the `pickedCountry` property for use later
        pickedCountry = countryList[row]
        // Updating the country label
        countryLabel.text = pickedCountry.prettyNameString
    }
}

// MARK: - Modal delegate

extension AddEditActTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        confirmCancel()
    }
}
