//
//  EditActTableViewCell.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

/// Table view cell responsible for displaying act information when user is editing contests
public class EditActTableViewCell: UITableViewCell {
    
    /// Label displaying country flag emoji
    @IBOutlet public var countryFlagLabel: UILabel!
    /// Label displaying country name
    @IBOutlet public var countryNameLabel: UILabel!
    /// Label displaying artist name
    @IBOutlet public var artistNameLabel: UILabel!
    /// Label displaying song name
    @IBOutlet public var songNameLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Updates cell labels with act information
    /// - Parameter act: the act which the cell will display
    public func update(with act: Act) {
        countryFlagLabel.text = act.country.flagEmoji
        countryNameLabel.text = act.country.name
        artistNameLabel.text = act.artistName
        songNameLabel.text = act.songName
    }
    
}
