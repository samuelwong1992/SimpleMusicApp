//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import UIKit
import MediaPlayer

class MediaObjectListViewController: UIViewController {
    
    static var viewController: MediaObjectListViewController? {
        return UIStoryboard(name: StoryboardConstants.Storyboard.Main.rawValue, bundle: nil).instantiateViewController(identifier: "ArtistsViewController") as? MediaObjectListViewController
    }
    
    var data: [MediaObject] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
}

//MARK: Initialization
extension MediaObjectListViewController {
    func initialize() {
        tableView.delegate = self
        tableView.dataSource = self
        
        let query = MPMediaQuery.artists().items!
        
        for artist in query {
            if(!self.data.contains(where: {$0.id == artist.artistPersistentID})) {
                self.data.append(MediaObject(id: artist.artistPersistentID, title: artist.artist ?? "No Artist"))
            }
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
}
