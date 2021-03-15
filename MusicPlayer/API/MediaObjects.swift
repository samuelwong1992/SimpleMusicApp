//
//  MediaObjects.swift
//  MusicPlayer
//
//  Created by Samuel Wong on 9/3/21.
//

import Foundation
import MediaPlayer

class MediaObject {
    var id: MPMediaEntityPersistentID!
    var title: String!
    
    init(id: MPMediaEntityPersistentID?, title: String) {
        self.id = id
        self.title = title
    }
}
