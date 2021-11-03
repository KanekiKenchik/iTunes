//
//  AlbumTableViewCell.swift
//  iTunesTest
//
//  Created by Афанасьев Александр Иванович on 02.11.2021.
//

import UIKit

class AlbumTableViewCell: UITableViewCell {

    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var albumName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
