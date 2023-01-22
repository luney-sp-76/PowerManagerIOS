//
//  Devices.swift
//  powerManager
//
//  Created by Paul Olphert on 22/01/2023.
//

import UIKit

class DevicesCell: UITableViewCell {

    @IBOutlet weak var deviceBubble: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var rightImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
