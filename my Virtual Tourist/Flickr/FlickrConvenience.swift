//
//  FlickrConvenience.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import Foundation
import UIKit

extension Flickr{
    

    
    func getPhotosFormFlicker(latitude:Double ,longitude:Double, _ completionHandlerForFlickerPhoto: @escaping (_ success: Bool,_ photoData: [Any]?,_   :String?, _ errorString: String?) -> Void) {
        
        
        let bBox = self.bboxString(latitude: latitude, longitude: longitude)
        
        let parameters = [
            Flickr.ParameterKeys.Method           : Flickr.ParameterValues.SearchMethod
            , Flickr.ParameterKeys.APIKey         : Flickr.ParameterValues.APIKey
            , Flickr.ParameterKeys.Format         : Flickr.ParameterValues.ResponseFormat
            , Flickr.ParameterKeys.Extras         : Flickr.ParameterValues.MediumURL
            , Flickr.ParameterKeys.NoJSONCallback : Flickr.ParameterValues.DisableJSONCallback
            , Flickr.ParameterKeys.SafeSearch     : Flickr.ParameterValues.UseSafeSearch
            , Flickr.ParameterKeys.BoundingBox    : bBox
            , Flickr.ParameterKeys.PhotosPerPage  : Flickr.ParameterValues.PhotosPerPage
            ,Flickr.ParameterKeys.Page : Flickr.ParameterValues.Page
            ] as [String : Any]
        
        /* 2. Make the request */
        
        _ = taskForGETMethod( parameters: parameters as [String : AnyObject] , decode: FlickrResponse.self) { (result, error) in
            
            
            if let error = error {
                
                completionHandlerForFlickerPhoto(false ,nil ,nil,"\(error.localizedDescription)")
            }else {
                
                let newResult = result as! FlickrResponse
                
                let resultData = newResult.photos.photo
                
                if newResult.photos.photo.isEmpty {
                    
                    let noPhotoMessage = "no images for this pin"
                    
                    completionHandlerForFlickerPhoto(true ,nil ,noPhotoMessage,nil)
                    
                } else {
                    completionHandlerForFlickerPhoto(true ,resultData,nil,nil)
                    
                }
                
                
                
                
            }
        }
        
    }
    
    
    
    
    
}


