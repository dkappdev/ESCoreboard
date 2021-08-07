//
//  ActTableViewCell.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 06.08.2021.
//

import UIKit

class ActTableViewCell: UITableViewCell {
    
    @IBOutlet var countryFlagLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var songNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with act: Act) {
        countryFlagLabel.text = act.country.flagEmoji
        artistNameLabel.text = act.artistName
        songNameLabel.text = act.songName
    }

}
