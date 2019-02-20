//
//  FlickrConsts.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation


// MARK: - Flickr (Constants)


extension Flickr {
    struct  Consts {
        // Mark: API key & URL 414670749d055b5051cde31e50e06d5d
        static let ApiKey = "414670749d055b5051cde31e50e06d5d"
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
    }
    
    static let SearchBBoxHalfWidth = 0.2
    static let SearchBBoxHalfHeight = 0.2
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)
    
    
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Extras = "extras"
        static let SafeSearch = "safe_search"
        static let PhotosPerPage = "per_page"
        static let BoundingBox = "bbox"
        static let Page = "page"
        
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "414670749d055b5051cde31e50e06d5d"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
        static let PhotosPerPage = "21"
        static let Page = Int( arc4random_uniform(UInt32(5)))
    }
    
    
    
    
    
    
}
