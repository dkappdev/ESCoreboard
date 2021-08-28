//
//  YearCollectionViewCell.swift
//  Eurovision Scoreboard
//
//  Created by Daniil Kostitsin on 05.08.2021.
//

import UIKit

/// Collection view cell that displays contest information (host country, host city, year) in the contest list collection view
class ContestCollectionViewCell: UICollectionViewCell {
    /// Label displaying country flag emoji
    @IBOutlet var hostCountryFlagLabel: UILabel!
    /// Label displaying the year when a contest took place and the host city
    @IBOutlet var yearAndHostCityLabel: UILabel!
    
    override func awakeFromNib() {
        // Setting the cornet radius
        layer.cornerRadius = 12
    }
    
    func update(with contest: Contest) {
        hostCountryFlagLabel.text = contest.hostCountry.flagEmoji
        yearAndHostCityLabel.text = "\(contest.year) - \(contest.hostCityName)"
    }
    
}
