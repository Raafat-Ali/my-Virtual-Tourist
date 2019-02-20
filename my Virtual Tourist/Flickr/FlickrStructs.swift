//
//  FlickrStructs.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation
// Mark: Flickr Data Module

struct ParsePhoto : Codable {
    let id : String
    let url_m : String
}

struct Photos:Codable {
    let perpage : Int
    let photo : [ParsePhoto]
    
}



struct FlickrResponse: Codable {
    let photos : Photos
    let stat : String
}
