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
        deviceBubble.layer.cornerRadius = deviceBubble.frame.size.height / 10
        rightImageView.makeRounded()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//MARK: - UiImageView makeRounded Extension
extension UIImageView {
    
    func makeRounded() {
        layer.borderWidth = 1
        layer.masksToBounds = false
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = self.frame.size.height / 15
        clipsToBounds = true
    }
}
