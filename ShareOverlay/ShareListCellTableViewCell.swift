//
//  ShareListCellTableViewCell.swift
//  Project105
//
//  Created by Wes Johnston on 10/16/14.
//  Copyright (c) 2014 Wes Johnston. All rights reserved.
//

import UIKit

class ShareListCellTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var shareImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
