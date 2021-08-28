//
//  UndoManager+Alert.swift
//  EurovisionScoreboard
//
//  Created by Daniil Kostitsin on 28.08.2021.
//

import UIKit

extension UndoManager {
    /// Creates a `UIAlertController` with action to undo or redo changes
    /// - Returns: `UIAlertController` with available undo / redo actions
    func getAlertWithAvailableActions() -> UIAlertController? {
        var alert: UIAlertController? = nil
        
        // Creating alert controllers based on possible actions
        if canUndo && canRedo {
            alert = UIAlertController(title: "Undo \(undoActionName)", message: nil, preferredStyle: .alert)
            let undoAction = UIAlertAction(title: "Undo", style: .default) { _ in
                self.undo()
            }
            let redoAction = UIAlertAction(title: "Redo \(redoActionName)", style: .default) { _IOFBF in
                self.redo()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert?.addAction(undoAction)
            alert?.addAction(redoAction)
            alert?.addAction(cancelAction)
            
        } else if canUndo {
            alert = UIAlertController(title: "Undo \(undoActionName)", message: nil, preferredStyle: .alert)
            let undoAction = UIAlertAction(title: "Undo", style: .default) { _ in
                self.undo()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert?.addAction(undoAction)
            alert?.addAction(cancelAction)
            
        } else if canRedo {
            alert = UIAlertController(title: "Redo \(redoActionName)", message: nil, preferredStyle: .alert)
            let redoAction = UIAlertAction(title: "Redo", style: .default) { _ in
                self.redo()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert?.addAction(redoAction)
            alert?.addAction(cancelAction)
        }
        
        return alert
    }
}
