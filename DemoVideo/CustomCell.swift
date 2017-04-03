//
//  CustomCell.swift
//  DemoVideo
//
//  Created by SOTSYS027 on 9/28/16.
//  Copyright © 2016 SOTSYS027. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class CustomCell: UICollectionViewCell {
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    @IBOutlet weak var imgDone: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var imgVW: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setSelected(selected: Bool, animated: Bool) {
        setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
