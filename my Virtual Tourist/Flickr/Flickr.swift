//
//  Flickr.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation

class Flickr: NSObject {
    
    var session = URLSession.shared // shared Session
    
    override init() { // initializer
        super.init()
    }

//Mark: Search Area
func bboxString(latitude: Double, longitude: Double) -> String {
    
    let minimumLon = max(longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0)
    let minimumLat = max(latitude  - Flickr.SearchBBoxHalfHeight,Flickr.SearchLatRange.0)
    let maximumLon = min(longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1)
    let maximumLat = min(latitude  + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1)
    return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
}

func taskForGETMethod<D: Decodable>(parameters: [String:AnyObject],decode:D.Type, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
    
    /* 1. Set the parameters */
    var parametersWithApiKey = parameters
    /* 2/3. Build the URL, Configure the request */
    
    
    var request = NSMutableURLRequest(url: tmdbURLFromParameters(parametersWithApiKey))
    
    
    /* 4. Make the request */
    let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
        
        func sendError(_ error: String) {
            print(error)
            let userInfo = [NSLocalizedDescriptionKey : error]
            completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
        }
        
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            sendError("\(error!.localizedDescription)")
            return
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            sendError("status code other than 2xx!")
            return
        }
        
        /* GUARD: Was there any data returned? */
        guard let data = data else {
            sendError("No data was returned by the request!")
            return
        }
        
        
        /* 5/6. Parse the data and use the data (happens in completion handler) */
        self.convertDataWithCompletionHandler(data, decode:decode,completionHandlerForConvertData: completionHandlerForGET)
        
    }
    /* 7. Start the request */
    task.resume()
    
    return task
    
    
}




private func convertDataWithCompletionHandler<D: Decodable>(_ data: Data,decode:D.Type, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
    
    
    do {
        let obj = try JSONDecoder().decode(decode, from: data)
        completionHandlerForConvertData(obj as AnyObject, nil)
        
    } catch {
        let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
        completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
    }
    
}

// create a URL from parameters
private func tmdbURLFromParameters(_ parameters: [String:AnyObject]) -> URL {
    
    var components = URLComponents()
    components.scheme = Flickr.Consts.ApiScheme
    components.host = Flickr.Consts.ApiHost
    components.path = Flickr.Consts.ApiPath
    
    components.queryItems = [URLQueryItem]()
    
    for (key, value) in parameters {
        let queryItem = URLQueryItem(name: key, value: "\(value)")
        components.queryItems!.append(queryItem)
        
    }
    
    let url = components.url!
    
    
    return url
}




// MARK: Shared Instance as singleton

class func sharedInstance() -> Flickr {
    struct Singleton {
        static var sharedInstance = Flickr()
    }
    return Singleton.sharedInstance
}
}

