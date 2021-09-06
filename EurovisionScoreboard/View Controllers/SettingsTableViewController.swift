//
//  SettingsTableViewController.swift
//  EurovisionScoreboard
//
//  Created by Daniil Kostitsin on 26.08.2021.
//

import UIKit
import UniformTypeIdentifiers

/// Static view controller responsible for changing app settings
public class SettingsTableViewController: UITableViewController {
    
    // MARK: - Properties
    
    /// Index path for 'Export' cell. By clicking the cell user can export contest data as JSON
    public let exportCellIndexPath = IndexPath(row: 0, section: 0)
    /// Index path for 'Import' cell. By clicking the cell user can import contest data from JSON file
    public let importCellIndexPath = IndexPath(row: 1, section: 0)
    /// Index path for 'Reset' cell. By clicking the cell user can completely reset contest data
    public let resetCellIndexPath = IndexPath(row: 2, section: 0)
    
    /// Notification informing that the contest list was changed in the shared instance of `ContestController`
    public static let contestListUpdatedNotification = Notification.Name("SettingsTableViewController.contestListUpdated")
    
    // MARK: - VC Life cycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view delegate

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Calling appropriate methods based on which cell user has clicked
        switch indexPath {
        case exportCellIndexPath:
            exportContests(sender: tableView.cellForRow(at: indexPath)!)
        case importCellIndexPath:
            importContests(sender: tableView.cellForRow(at: indexPath)!)
        case resetCellIndexPath:
            resetContests(sender: tableView.cellForRow(at: indexPath)!)
        default:
            break
        }
    }
    
    // MARK: - Exporting
    
    /// Exports contests as JSON and presents an action sheet
    /// - Parameter sender: table view cell that was tapped
    private func exportContests(sender: UITableViewCell) {
        // Getting the contest
        let contests = ContestController.shared.contests
        
        let jsonData: Data
        
        // Trying to encode JSON data
        do {
            jsonData = try JSONEncoder().encode(contests)
        } catch {
            // If not successful, print error to cancel and present error to user.
            print("Couldn't encode contest data. Reason: \(error.localizedDescription)")
            print(error)
            presentAlertWithExportError(error)
            return
        }
        
        // If everything went ok, try to create a temporary file with JSON data
        let temporaryURL: URL
        
        do {
            // Constructing file URL
            temporaryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: ContestController.archiveURL, create: true).appendingPathComponent("contest_data").appendingPathExtension("json")
        } catch {
            print("Couldn't open temporary directory. Reason: \(error.localizedDescription)")
            print(error)
            presentAlertWithExportError(error)
            return
        }
        
        // Attempting to write JSON data to temporary URL
        do {
            try jsonData.write(to: temporaryURL)
        } catch {
            print("Couldn't write JSON data to file. Reason: \(error.localizedDescription)")
            print(error)
            presentAlertWithExportError(error)
            return
        }
        
        // If none of the previous steps failed, present an activity controller and share the temporary file
        
        // Creating activity view controller
        let activityController = UIActivityViewController(activityItems: [temporaryURL], applicationActivities: nil)
        // Specifying source cell for iPadOS
        activityController.popoverPresentationController?.sourceView = sender
        // Presenting
        present(activityController, animated: true, completion: nil)
    }
    
    /// Presents an alert informing user that export was unsuccessful
    /// - Parameter error: error to present to user
    private func presentAlertWithExportError(_ error: Error?) {
        let title = error != nil ? "Unable to export contest data. Reason: \(error!.localizedDescription)" : "Unable to export contest data."
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Importing
    
    /// Imports contest list from JSON file
    /// - Parameter sender: table view cell that was tapped
    private func importContests(sender: UITableViewCell) {
        // Filtering files by .json extension
        let types = UTType.types(tag: "json", tagClass: .filenameExtension, conformingTo: nil)
        
        // Creating a document picker VC for opening copies of files
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        // Settings `self` as its delegate
        documentPickerController.delegate = self
        
        // Disallowing multiple selections from document picker and showing file extension
        documentPickerController.allowsMultipleSelection = false
        documentPickerController.shouldShowFileExtensions = true
        
        // Presenting
        present(documentPickerController, animated: true, completion: nil)
        
        // Note: next steps are handled by document picker delegate
    }
    
    /// Presents an alert informing user that import was unsuccessful
    /// - Parameter error: error to present to user
    private func presentAlertWithImportError(_ error: Error?) {
        let title = error != nil ? "Unable to import contest data. Reason: \(error!.localizedDescription)" : "Unable to import contest data."
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alertController.addAction(dismissAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Resetting
    
    /// Replaces current contest list with the default one
    /// When user tries to reset, we ask them twice if they are sure they want to reset.
    /// - Parameter sender: the cell that was tapped
    private func resetContests(sender: UITableViewCell) {
        // Presenting both warning as action sheets
        let firstAlertController = UIAlertController(title: "Are you sure you want to reset your contest list? This cannot be undone!", message: nil, preferredStyle: .actionSheet)
        
        let firstCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // The first reset action causes another alert controller to pop up
        let firstResetAction = UIAlertAction(title: "Reset", style: .destructive) { action in
            let secondAlertController = UIAlertController(title: "All your data will be lost! Are you absolutely sure?", message: nil, preferredStyle: .actionSheet)
            
            let secondCancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            // The second reset action actually does the resetting
            let secondResetAction = UIAlertAction(title: "Reset", style: .destructive) { action in
                // Resetting the state
                ContestController.shared.resetContests()
                // Updating the collection view as the contest list was changed
                NotificationCenter.default.post(name: Self.contestListUpdatedNotification, object: nil)
            }
            
            secondAlertController.addAction(secondCancelAction)
            secondAlertController.addAction(secondResetAction)
            // Setting the source bar button item for iPadOS
            secondAlertController.popoverPresentationController?.sourceView = sender
            
            // Presenting the second alert controller
            self.present(secondAlertController, animated: true, completion: nil)
        }
        
        firstAlertController.addAction(firstCancelAction)
        firstAlertController.addAction(firstResetAction)
        // Setting the source bar button item for iPadOS
        firstAlertController.popoverPresentationController?.sourceView = sender
        
        // Presenting the first alert controller
        present(firstAlertController, animated: true, completion: nil)
    }
    
}

// MARK: - Document picker delegate

extension SettingsTableViewController: UIDocumentPickerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Getting the first url
        guard let jsonURL = urls.first else {
            presentAlertWithImportError(nil)
            return
        }
        
        let jsonData: Data
        
        // Attempting to read data from given URL
        do {
            jsonData = try Data(contentsOf: jsonURL)
        } catch {
            print(error.localizedDescription)
            print(error)
            presentAlertWithImportError(error)
            return
        }
        
        let contestList: [Contest]
        
        // Attempting to decode JSON
        do {
            contestList = try JSONDecoder().decode([Contest].self, from: jsonData)
        } catch {
            print(error.localizedDescription)
            print(error)
            presentAlertWithImportError(error)
            return
        }
        
        // If everything was successful, warn user that this will erase their previous contest list
        // If they choose to continue, update the contest list in `ContestController.shared`
        
        let alertController = UIAlertController(title: "This will permanently delete your current contest list and replace it with a new one! Are you sure you want to continue?", message: nil, preferredStyle: .actionSheet)
        let importAction = UIAlertAction(title: "Import", style: .destructive) { _ in
            ContestController.shared.contests = contestList
            
            NotificationCenter.default.post(name: Self.contestListUpdatedNotification, object: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(importAction)
        alertController.addAction(cancelAction)
        
        alertController.popoverPresentationController?.sourceView = tableView.cellForRow(at: importCellIndexPath)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
}
