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
    
    /// Participating country text field
    @IBOutlet var countryNameTextField: UITextField!
    /// Country flag emoji text field
    @IBOutlet var countryFlagTextField: UITextField!
    /// Song name text field
    @IBOutlet var songNameTextField: UITextField!
    /// Artist name text field
    @IBOutlet var artistNameTextField: UITextField!
    
    /// Cell which user can click to delete the current act. It should be hidden when user is adding a new act. Because of this, we store the outlet the the cell in addition to its `IndexPath`
    @IBOutlet var deleteActCell: UITableViewCell!
    
    /// Button which user can click to save changes
    @IBOutlet var saveBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    /// Index path of the 'Delete Act' cell which user can press to delete the current act
    let deleteActCellIndexPath = IndexPath(row: 0, section: 4)
    
    /// Act list for the current contest
    var acts: [Act]
    /// Index of the act this view controller is editing. It is used to modify the acts array.
    var actIndex: Int?
    
    /// Delegate responsible for saving changes and dismissing the view controller
    weak var delegate: AddEditActTableViewControllerDelegate?
    
    // MARK: - Initializers
    
    /// Custom initializer with act list and index of the act to edit. Only this initializer must be used
    /// - Parameters:
    ///   - coder: coder provided by Storyboard
    ///   - acts: act list for the current contest
    ///   - actIndex: act to edit (`nil` if we are adding a new one)
    init?(coder: NSCoder, acts: [Act], actIndex: Int?) {
        self.acts = acts
        self.actIndex = actIndex
        super.init(coder: coder)
    }
    
    /// Required initializer that should not be used. It is not implemented
    /// - Parameter coder: coder provided by Storyboard
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let actIndex = actIndex {
            // If `actIndex` is not `nil`, that means we are editing an existing act
            
            // Getting the act
            let act = acts[actIndex]
            
            // Populating text fields
            countryNameTextField.text = act.country.name
            countryFlagTextField.text = act.country.flagEmoji
            songNameTextField.text = act.songName
            artistNameTextField.text = act.artistName
            
            // Setting up navigation item
            navigationItem.title = "Edit Act"
        } else {
            // If `actindex` is `nil`, we are adding a new act
            
            // Hiding the 'Delete' cell
            deleteActCell.isHidden = true
            // Setting up navigation item
            navigationItem.title = "Add Act"
        }
        
        // Setting `self` as the delegate of all text fields
        // We are doing this to later hide the keyboard the keyboard when user presses 'return' key
        countryNameTextField.delegate = self
        countryFlagTextField.delegate = self
        songNameTextField.delegate = self
        artistNameTextField.delegate = self
        
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
    
    /// Called whenever user changed contents of a text field
    @IBAction func textEditingChanged() {
        // Every time user made a change to a text field, we update the state of 'Save' button
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        // Getting text from text fields
        let countryName = countryNameTextField.text ?? ""
        let songName = songNameTextField.text ?? ""
        let artistName = artistNameTextField.text ?? ""
        
        // The save button is enabled only when all text fields are not empty, and the `countryFlagTextField` contains a single emoji
        saveBarButton.isEnabled = containsSingleEmoji(countryFlagTextField) && !countryName.isEmpty && !songName.isEmpty && !artistName.isEmpty
    }
    
    /// Checks if a text field contains a single emoji
    /// - Parameter textField: text field to check
    /// - Returns: `true` if text field contains a single emoji, `false` otherwise
    func containsSingleEmoji(_ textField: UITextField) -> Bool {
        // Making sure text field contains exactly one symbol
        guard let text = textField.text,
              text.count == 1 else { return false }
        
        // And checking whether this symbol is an emoji
        return text.unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }
    
    // MARK: - Configuring buttons
    
    /// Called when user taps the 'Save' button. Saves changes made by user
    /// - Parameter sender: bar button item that was tapped
    @IBAction func saveBarButtonTapped(_ sender: UIBarButtonItem) {
        // If user was able to press the 'Save' button, we already know input is valid, so we force unwrap
        let country = Country(name: countryNameTextField.text!, flagEmoji: countryFlagTextField.text!)
        let newAct = Act(artistName: artistNameTextField.text!, songName: songNameTextField.text!, country: country)
        
        if let actIndex = actIndex {
            // If we are editing an existing act, save changes made to it
            acts[actIndex] = newAct
        } else {
            // Otherwise append the new act to the acts array
            acts.append(newAct)
        }
        
        // Asking delegate to save new act list and dismiss the view controller
        delegate?.dismissViewControllerAndSaveActs(acts)
    }
    
    // MARK: - Segues
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect row on selection
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Making sure user tapped the 'Delete Act' button, since this is the only selection we want to respond to
        if indexPath == deleteActCellIndexPath {
            // Removing the act
            acts.remove(at: indexPath.row)
            // And asking the delegate to save changes and dismiss the view controller
            delegate?.dismissViewControllerAndSaveActs(acts)
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
