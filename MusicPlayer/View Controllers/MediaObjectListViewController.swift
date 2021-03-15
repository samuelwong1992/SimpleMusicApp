//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import UIKit
import MediaPlayer

class MediaObjectListViewController: UIViewController {
    
    var letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    enum ListType {
        case artist
        case album
        case song
        case playlist
    }
    
    static var viewController: MediaObjectListViewController? {
        return UIStoryboard(name: StoryboardConstants.Storyboard.Main.rawValue, bundle: nil).instantiateViewController(identifier: "MediaObjectListViewController") as? MediaObjectListViewController
    }
    
    var listType: ListType = .artist
    var data: [MediaObject] = []
    var initialData: [MPMediaItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var alphabetScrollView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        for subview in alphabetScrollView.subviews {
            subview.removeFromSuperview()
        }
        
        for i in 0 ..< letters.count {
            let letter = letters[i]
            let label = UILabel(frame: CGRect(x: 0, y: CGFloat(i)*(alphabetScrollView.frame.size.height/CGFloat(letters.count)), width: alphabetScrollView.frame.size.width, height: (alphabetScrollView.frame.size.height/CGFloat(letters.count))))
            label.text = letter
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            alphabetScrollView.addSubview(label)
        }
    }
}

//MARK: Initialization
extension MediaObjectListViewController {
    func initialize() {
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        self.alphabetScrollView.setNeedsLayout()
        self.alphabetScrollView.layoutIfNeeded()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        for i in 0 ..< letters.count {
            let letter = letters[i]
            let label = UILabel(frame: CGRect(x: 0, y: CGFloat(i)*(alphabetScrollView.frame.size.height/CGFloat(letters.count)), width: alphabetScrollView.frame.size.width, height: (alphabetScrollView.frame.size.height/CGFloat(letters.count))))
            label.text = letter
            label.adjustsFontSizeToFitWidth = true
            alphabetScrollView.addSubview(label)
        }
        
        switch listType {
        case .artist:
            initialData.sort(by: { $0.artist ?? "" < $1.artist ?? ""})
            for song in initialData {
                if(!self.data.contains(where: {$0.id == song.artistPersistentID})) {
                    self.data.append(MediaObject(id: song.artistPersistentID, title: String.isNilOrEmpty(string: song.artist) ? "Unknown Artist" : song.artist!))
                }
            }
            
        case .album :
            self.data.append(MediaObject(id: nil, title: "All Albums"))
            for song in initialData {
                
                if(!self.data.contains(where: {$0.id == song.albumPersistentID})) {
                    self.data.append(MediaObject(id: song.albumPersistentID, title: String.isNilOrEmpty(string: song.albumTitle) ? "Unknown Album" : song.albumTitle!))
                }
            }
            
        case .song :
            initialData.sort(by: { $0.title ?? "" < $1.title ?? ""})
            for song in initialData {
                self.data.append(MediaObject(id: song.persistentID, title: String.isNilOrEmpty(string: song.title) ? "No Title" : song.title!))
            }
            
        default:
            print()
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

//MARK: Table View Delegate and Data Source
extension MediaObjectListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!
        
        cell.textLabel?.text = data[indexPath.row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch listType {
        case .artist :
            if let vc = MediaObjectListViewController.viewController {
                vc.initialData = initialData.filter({ $0.artistPersistentID == self.data[indexPath.row].id })
                vc.listType = .album
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .album :
            if let vc = MediaObjectListViewController.viewController {
                if indexPath.row == 0 {
                    vc.initialData = initialData
                } else {
                    vc.initialData = initialData.filter({ $0.albumPersistentID == self.data[indexPath.row].id })
                }
                
                vc.listType = .song
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .song :
            if let navigationController = navigationController as? MainNavigationController {
                navigationController.musicPlayerWidget.queue = MPMediaItemCollection(items: initialData)
                navigationController.musicPlayerWidget.player.nowPlayingItem = initialData[indexPath.row]
                navigationController.showMusicPlayer()
                navigationController.musicPlayerWidget.didSetSong()
            }
        default:
            print()
        }
    }
}

extension MediaObjectListViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: alphabetScrollView)
            let scrollToPoint = data.firstIndex(where: { $0.title > letters[Int(CGFloat(letters.count)*touchLocation.y/alphabetScrollView.frame.size.height)] })
            if scrollToPoint != nil {
                tableView.scrollToRow(at: IndexPath(row: scrollToPoint!, section: 0), at: .top, animated: false)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: alphabetScrollView)
            let scrollToPoint = data.firstIndex(where: { $0.title > letters[Int(CGFloat(letters.count)*touchLocation.y/alphabetScrollView.frame.size.height)] })
            if scrollToPoint != nil {
                tableView.scrollToRow(at: IndexPath(row: scrollToPoint!, section: 0), at: .top, animated: false)
            }
        }
    }
}
