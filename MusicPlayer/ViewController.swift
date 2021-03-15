//
//  ViewController.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import UIKit
import MediaPlayer

class ArtistsViewController: UIViewController {
    
    var artists: [Artist] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialize()
    }
}

//MARK: Initialization
extension ArtistsViewController {
    func initialize() {
        tableView.delegate = self
        tableView.dataSource = self
        
        MPMediaLibrary.requestAuthorization { (status) in
            if status == .authorized {
                let query = MPMediaQuery.artists().items!
                
                for artist in query {
                    if(!self.artists.contains(where: {$0.id == artist.artistPersistentID})) {
                        self.artists.append(Artist(id: artist.artistPersistentID, title: artist.artist ?? "No Artist"))
                    }
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

//MARK: Table View Delegate and Data Source
extension ArtistsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")!
        
        cell.textLabel?.text = artists[indexPath.row].title
        
        return cell
    }
}
