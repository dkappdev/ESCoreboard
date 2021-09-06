//
//  ActTableViewCell.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import UIKit

/// Table view cell responsible for displaying act information in the when user is viewing contests
public class ViewActTableViewCell: UITableViewCell {
    
    /// Label displaying country flag emoji
    @IBOutlet public var countryFlagLabel: UILabel!
    /// Label displaying country name
    @IBOutlet public var countryNameLabel: UILabel!
    /// Label displaying artist name
    @IBOutlet public var artistNameLabel: UILabel!
    /// Label displaying song name
    @IBOutlet public var songNameLabel: UILabel!
    /// Label displaying the current place in the scoreboard for a contest
    @IBOutlet public var currentPlaceLabel: UILabel!
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        // Manually setting font for `currentPlaceLabel` to adopt dynamic type
        let currentPlaceStaticFont = UIFont.systemFont(ofSize: 34, weight: .bold)
        let currentPlaceDynamicFont = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: currentPlaceStaticFont)
        currentPlaceLabel.font = currentPlaceDynamicFont
        currentPlaceLabel.adjustsFontForContentSizeCategory = true
        
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// Updates cell label with act information and the current position in the scoreboard
    /// - Parameters:
    ///   - act: the act which the cell will display
    ///   - position: current position in the scoreboard
    public func update(with act: Act, position: Int) {
        countryFlagLabel.text = act.country.flagEmoji
        countryNameLabel.text = act.country.name
        artistNameLabel.text = act.artistName
        songNameLabel.text = act.songName
        currentPlaceLabel.text = "\(position)"
    }
    
}
