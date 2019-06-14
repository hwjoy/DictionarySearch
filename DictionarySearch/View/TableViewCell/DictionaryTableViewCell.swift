//
//  DictionaryTableViewCell.swift
//  DictionarySearch
//
//  Created by hwjoy on 2019/5/25.
//  Copyright © 2019 redant. All rights reserved.
//

import UIKit

class DictionaryTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        subtitleLabel.font = UIFont.systemFont(ofSize: 17)
        
        titleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.lineBreakMode = .byTruncatingTail
    }

//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
    
}
