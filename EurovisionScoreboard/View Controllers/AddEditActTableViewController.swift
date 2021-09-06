//
//  AddEditActTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

/// Static table view controller responsible for editing individual acts
public class AddEditActTableViewController: UITableViewController {
    
    // MARK: - IB Outlets
    
    @IBOutlet public var songNameTextField: UITextField!
    /// Artist name text field
    @IBOutlet public var artistNameTextField: UITextField!
    
    /// Label that displays currently picked country
    @IBOutlet public var countryLabel: UILabel!
    /// Country picked view
    @IBOutlet public var countryPickerView: UIPickerView!
    
    /// Cell which user can click to delete the current act. It should be hidden when user is adding a new act. Because of this, we store the outlet the the cell in addition to its `IndexPath`
    @IBOutlet public var deleteActCell: UITableViewCell!
    
    /// Button which user can click to save changes
    @IBOutlet public var saveBarButton: UIBarButtonItem!
    
    /// Button which user can click to discard changes
    @IBOutlet public var cancelBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    /// Index path of the 'Delete Act' cell which user can press to delete the current act
    public let deleteActCellIndexPath = IndexPath(row: 0, section: 3)
    
    /// Indicates whether or not user has made any changes
    private var hasChanges = false
    
    /// Country that user has picked using the picker view, by default it's set to `Country.fullCountryList.first!` or `Country.moderCountryList.first!`, depending on contest year
    private var pickedCountry: Country!
    
    /// Country list for picker view
    private var countryList: [Country]!
    
    /// Act list for the current contest
    private var acts: [Act]
    /// Index of the act this view controller is editing. It is used to modify the acts array.
    private var actIndex: Int?
    /// Year when contest is taking place
    private let contestYear: Int?
    
    /// Delegate responsible for saving changes and dismissing the view controller
    public weak var delegate: AddEditActTableViewControllerDelegate?
    
    // MARK: - Initializers
    
    /// Custom initializer with act list and index of the act to edit. Only this initializer must be used
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - acts: act list for the current contest
    ///   - actIndex: act to edit (`nil` if we are adding a new one)
    ///   - contestYear: year when contest is taking place
    public init?(coder: NSCoder, acts: [Act], actIndex: Int?, contestYear: Int?) {
        self.acts = acts
        self.actIndex = actIndex
        self.contestYear = contestYear
        super.init(coder: coder)
    }
    
    /// Required initializer that should not be used. It is not implemented
    /// - Parameter coder: coder provided by Storyboard
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    /// Choose between modern and full country list
    private func setupCountryList() {
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
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCountryList()
        
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
             
            if let countryIndex = countryList.firstIndex(of: act.country) {
                countryPickerView.selectRow(countryIndex, inComponent: 0, animated: false)
            }
                        
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
        // If we are adding a new act, this will disabl e the 'Save' button
        updateSaveButtonState()
        
        // Adding a tap gesture recognizer to hide keyboard whenever user taps outside text fields
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Dismissing keyboard
    
    /// Dismisses keyboard
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Input validation
    
    private func updateSaveButtonState() {
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
        // Remember that user made changes to act
        hasChanges = true
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
        if hasChanges {
            // If user has made changes to current act, ask for confirmation before discarding those changes
            confirmCancel()
        } else {
            // Otherwise just dismiss the view controller
            delegate?.dismissViewController()
        }
    }
    
    // MARK: - Applying changes
    
    /// Ask the user whether or not they want to discard changes and potentially dismisses the view controller
    private func confirmCancel() {
        // If user attempted to dismiss VC, ask them if they are sure they want to dismiss changes
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Discard Changes", style: .destructive) { _ in
            self.delegate?.dismissViewController()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.popoverPresentationController?.barButtonItem = cancelBarButton
        
        present(alert, animated: true, completion: nil)
    }
    
    /// Asks the user whether or not they want to delete an item and potentially dismisses the view controller
    private func confirmDelete(forRowAt indexPath: IndexPath) {
        // If user attempted to dismiss VC, ask them if they are sure they want to dismiss changes
        let alert = UIAlertController(title: "Are you sure you want to delete this act from your list?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Delete Act", style: .destructive) { _ in
            // Telling the delegate that an act should be deleted and asking it dismiss the view controller
            self.delegate?.dismissViewControllerAndDeleteActAt(indexPath)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.popoverPresentationController?.sourceView = deleteActCell
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Segues
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row on selection
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Making sure user tapped the 'Delete Act' button, since this is the only selection we want to respond to
        if indexPath == deleteActCellIndexPath {
            // 'Delete' button is only visible when there is a non-nil act index, so we can force-unwrap
            confirmDelete(forRowAt: IndexPath(row: actIndex!, section: 0))
        }
    }
}

// MARK: - Text field delegate

// Adopting `UITextFieldDelegate` to respond to 'return' key press
extension AddEditActTableViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Resigning first responder when user presses 'return'
        textField.resignFirstResponder()
        return false
    }
}

extension AddEditActTableViewController: UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        // There's only one component since we are only choosing a country
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return countryList.count
    }
}

extension AddEditActTableViewController: UIPickerViewDelegate {
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Returning pretty string for country as the title for picker view row
        return countryList[row].prettyNameString
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Setting the `pickedCountry` property for use later
        pickedCountry = countryList[row]
        // Updating the country label
        countryLabel.text = pickedCountry.prettyNameString
        // Remember that user made changes to act
        hasChanges = true
    }
}

// MARK: - Modal delegate

extension AddEditActTableViewController: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        // User will be able to swipe down only if no changes were made.
        // If `hasChanges` is true, the user-initiated attempt to dismiss VC will be prevented and this delegate method will be called
        confirmCancel()
    }
    
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        // Only allow user to dismiss if there aren't any unsaved changes
        return !hasChanges
    }
}
