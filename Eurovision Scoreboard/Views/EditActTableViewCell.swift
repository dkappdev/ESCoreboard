//
//  EditActTableViewCell.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 10.08.2021.
//

import UIKit

class EditActTableViewCell: UITableViewCell {
    
    @IBOutlet var countryFlagLabel: UILabel!
    @IBOutlet var countryNameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var songNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func update(with act: Act) {
        countryFlagLabel.text = act.country.flagEmoji
        countryNameLabel.text = act.country.name
        artistNameLabel.text = act.artistName
        songNameLabel.text = act.songName
    }

}
