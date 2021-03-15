//
//  LandingViewController.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import UIKit
import MediaPlayer

class LandingViewController: UIViewController {
    
    enum SearchOptions: Int, CaseIterable {
        case artist = 0
        case song
        case playlist
        
        var title: String {
            switch self {
            case .artist : return "Artist"
            case .song : return "Song"
            case .playlist : return "Playlist"
            }
        }
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var warningLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initialize()
    }
}

//MARK: Initialization
extension LandingViewController {
    func initialize() {
        tableView.delegate = self
        tableView.dataSource = self
        
        MPMediaLibrary.requestAuthorization { (status) in
            DispatchQueue.main.async {
                self.warningLabel.isHidden = status == .authorized
                self.tableView.isHidden = status != .authorized
            }
        }
    }
}

//MARK: Table View Delegate and Data Source
extension LandingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!
        
        if let searchOption = SearchOptions(rawValue: indexPath.row) {
            cell.textLabel?.text = searchOption.title
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let searchOption = SearchOptions(rawValue: indexPath.row) {
            
            let query = MPMediaQuery.artists().items!
            
            switch searchOption {
            case .artist :
                if let vc = MediaObjectListViewController.viewController {
                    vc.initialData = query
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .song :
                if let vc = MediaObjectListViewController.viewController {
                    vc.initialData = query
                    vc.listType = .song
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case .playlist : print("playlist")
            }
        }
    }
}
