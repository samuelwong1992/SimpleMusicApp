//
//  MusicPlayerWidget.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import UIKit
import MediaPlayer

class MusicPlayerWidget: UIView {
    @IBOutlet weak var labelContainerView: UIView!
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastForwardButton: UIButton!
    
    @IBOutlet weak var sliderContainer: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var stackView: UIStackView!
    
    var isShuffled = false
    
    let player = MPMusicPlayerController.applicationQueuePlayer
    var queue: MPMediaItemCollection? {
        didSet {
            if let queue = queue {
                player.setQueue(with: queue)
                player.prepareToPlay()
                player.play()
            }
            
            tableView.reloadData()
        }
    }
    var shuffledQueue: MPMediaItemCollection?
    var currentSongAtTimeOfShuffle: MPMediaItem?
    
    func getQueue() -> MPMediaItemCollection? {
        return shuffledQueue != nil ? shuffledQueue : queue
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadViewFromNib()
    }
    
    func loadViewFromNib() {
        super.loadViewFromNib("MusicPlayerWidget", forClass: MusicPlayerWidget.self)
        
        initialize()
    }
}

//MARK: Initialization
extension MusicPlayerWidget {
    func initialize() {
        self.backgroundColor = UIColor.white
        
        self.sliderContainer.isHidden = true
        
        tableView.register(SongTableViewCell.kNib, forCellReuseIdentifier: SongTableViewCell.kReuseIdentifer)
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshView),
                                               name: .MPMusicPlayerControllerPlaybackStateDidChange,
                                               object: player)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didChangeSong),
                                               name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                               object: player)
        
        previousButton.addTarget(self, action: #selector(previousButton_didPress), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButton_didPress), for: .touchUpInside)
        fastForwardButton.addTarget(self, action: #selector(fastForwardButton_didPress), for: .touchUpInside)
        shuffleButton.addTarget(self, action: #selector(shuffleButton_didPress), for: .touchUpInside)
        
        self.timeSlider.addTarget(self, action: #selector(timeSlider_didChange), for: .valueChanged)
        
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { (timer) in
            if self.player.playbackState == .playing {
                let mins = Int(floor(self.player.currentPlaybackTime/60))
                let secs = Int(Double(self.player.currentPlaybackTime).truncatingRemainder(dividingBy: 60))
                self.currentTimeLabel.text = "\(mins):\(secs < 10 ? "0\(secs)" : "\(secs)")"
                
                if let nowPlayingItem = self.player.nowPlayingItem {
                    self.timeSlider.setValue(Float(self.player.currentPlaybackTime/nowPlayingItem.playbackDuration), animated: true)
                }
            }
        }
    }
    
    func didSetSong() {
        self.tableView.reloadData()
        playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        if queue != nil {
            if queue!.items.count > 0 {
                tableView.scrollToRow(at: IndexPath(row: player.indexOfNowPlayingItem, section: 0), at: .top, animated: true)
            }
        }
    }
    
    @objc func didChangeSong() {
        refreshView()

        if shuffledQueue != nil {
            queue = shuffledQueue
            shuffledQueue = nil
            player.skipToNextItem()
        }
    }
    
    @objc func refreshView() {
        if player.playbackState == .playing {
            playButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        } else {
            playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        self.songLabel.text = player.nowPlayingItem?.title
        self.artistLabel.text = player.nowPlayingItem?.artist
        self.albumLabel.text = player.nowPlayingItem?.albumTitle
        
        if let nowPlayingItem = self.player.nowPlayingItem {
            let mins = Int(floor(nowPlayingItem.playbackDuration/60))
            let secs = Int(Double(nowPlayingItem.playbackDuration).truncatingRemainder(dividingBy: 60))
            self.endTimeLabel.text = "\(mins):\(secs < 10 ? "0\(secs)" : "\(secs)")"
        } else {
            self.endTimeLabel.text = "0:00"
        }
    }
}

//MARK: Button Handlers
@objc extension MusicPlayerWidget {
    func previousButton_didPress() {
        player.skipToPreviousItem()
        refreshView()
        didSetSong()
    }
    
    func playButton_didPress() {
        if player.playbackState == .playing {
            player.pause()
        } else {
            player.play()
        }
        refreshView()
        didSetSong()
    }
    
    func fastForwardButton_didPress() {
        player.skipToNextItem()
        refreshView()
        didSetSong()
    }
    
    func timeSlider_didChange() {
        if let nowPlayingItem = self.player.nowPlayingItem {
            player.currentPlaybackTime = Double(min(timeSlider.value, 0.99) ) * nowPlayingItem.playbackDuration
            let mins = Int(floor(self.player.currentPlaybackTime/60))
            let secs = Int(Double(self.player.currentPlaybackTime).truncatingRemainder(dividingBy: 60))
            self.currentTimeLabel.text = "\(mins):\(secs < 10 ? "0\(secs)" : "\(secs)")"
        }
    }
    
    func shuffleButton_didPress() {
        currentSongAtTimeOfShuffle = player.nowPlayingItem
        
        if isShuffled {
            shuffleButton.setImage(UIImage(systemName: "shuffle.circle"), for: .normal)
            if let queue = queue {
                var items = queue.items
                items.sort(by: { $0.title ?? "" < $1.title ?? "" })
                if let currentItem = self.player.nowPlayingItem {
                    let splitItems = items.split(separator: currentItem)
                    
                    var newList = [currentItem]
                    for item in splitItems.reversed() {
                        for subItem in item {
                            newList.append(subItem)
                        }
                    }
                    
                    self.shuffledQueue = MPMediaItemCollection(items: newList)
                } else {
                    self.shuffledQueue = MPMediaItemCollection(items: items)
                }
            }
        } else {
            if let queue = queue {
                var items = queue.items
                items.shuffle()
                if let currentItem = player.nowPlayingItem {
                    items.removeAll(where: { $0 == currentItem })
                    items.insert(currentItem, at: 0)
                }
                self.shuffledQueue = MPMediaItemCollection(items: items)

            }
            shuffleButton.setImage(UIImage(systemName: "shuffle.circle.fill"), for: .normal)
        }
        isShuffled = !isShuffled
        
        didSetSong()
    }
}

//MARK: Table View Delegate and Data Source
extension MusicPlayerWidget: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getQueue() != nil ? getQueue()!.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let queue = getQueue() {
            let cell = tableView.dequeueReusableCell(withIdentifier: SongTableViewCell.kReuseIdentifer) as! SongTableViewCell
            
            cell.song = queue.items[indexPath.row]
            if player.nowPlayingItem == queue.items[indexPath.row] {
                cell.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
            } else {
                cell.backgroundColor = UIColor.white
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queue = getQueue() {
            player.nowPlayingItem = queue.items[indexPath.row]
        }
    }
}
