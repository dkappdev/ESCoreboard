//
//  AddEditActTableViewController.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

class AddEditActTableViewController: UITableViewController {
    
    @IBOutlet var countryNameTextField: UITextField!
    @IBOutlet var countryFlagTextField: UITextField!
    @IBOutlet var songNameTextField: UITextField!
    @IBOutlet var artistNameTextField: UITextField!
    
    @IBOutlet var deleteActCell: UITableViewCell!
    
    @IBOutlet var saveBarButton: UIBarButtonItem!
    
    let deleteActCellIndexPath = IndexPath(row: 0, section: 4)
    
    weak var delegate: AddEditActTableViewControllerDelegate?
    
    var acts: [Act]
    var actIndex: Int?
    
    init?(coder: NSCoder, acts: [Act], actIndex: Int?) {
        self.acts = acts
        self.actIndex = actIndex
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let actIndex = actIndex {
            let act = acts[actIndex]
            countryNameTextField.text = act.country.name
            countryFlagTextField.text = act.country.flagEmoji
            songNameTextField.text = act.songName
            artistNameTextField.text = act.artistName
            navigationItem.title = "Edit Act"
        } else {
            deleteActCell.isHidden = true
            navigationItem.title = "Add Act"
        }
        
        countryNameTextField.delegate = self
        countryFlagTextField.delegate = self
        songNameTextField.delegate = self
        artistNameTextField.delegate = self

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == deleteActCellIndexPath {
            acts.remove(at: indexPath.row)
            delegate?.didChangeActs(acts)
        }
    }
    
    @IBAction func textEditingChanged() {
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        let countryName = countryNameTextField.text ?? ""
        let songName = songNameTextField.text ?? ""
        let artistName = artistNameTextField.text ?? ""
        
        saveBarButton.isEnabled = containsSingleEmoji(countryFlagTextField) && !countryName.isEmpty && !songName.isEmpty && !artistName.isEmpty
    }
    
    func containsSingleEmoji(_ textField: UITextField) -> Bool {
        guard let text = textField.text,
              text.count == 1 else { return false }
        
        return text.unicodeScalars.first?.properties.isEmojiPresentation ?? false
    }
    
    @IBAction func saveBarButtonTapped(_ sender: UIBarButtonItem) {
    // if the user was able to press this button, we already know the input is valid
        let country = Country(name: countryNameTextField.text!, flagEmoji: countryFlagTextField.text!)
        let newAct = Act(artistName: artistNameTextField.text!, songName: songNameTextField.text!, country: country)
        
        if let actIndex = actIndex {
            acts[actIndex] = newAct
        } else {
            acts.append(newAct)
        }
        
        delegate?.didChangeActs(acts)
    }
}

extension AddEditActTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
