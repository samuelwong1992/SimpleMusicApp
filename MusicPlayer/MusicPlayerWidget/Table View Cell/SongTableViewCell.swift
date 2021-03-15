//
//  SongTableViewCell.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 10/3/21.
//

import UIKit
import MediaPlayer

class SongTableViewCell: UITableViewCell {
    
    static let kNib = UINib(nibName: "SongTableViewCell", bundle: nil)
    static let kReuseIdentifer = "SongTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    var song: MPMediaItem! {
        didSet {
            titleLabel.text = song.title
            detailLabel.text = song.artist
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
