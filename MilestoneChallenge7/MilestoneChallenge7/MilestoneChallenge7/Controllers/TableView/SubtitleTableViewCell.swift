//
//  SubtitleTableViewCell.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
