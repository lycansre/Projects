//
//  APIVarsAndValues.swift
//  Virtual Tourist
//
//  Created by Programmer on 21/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import Foundation
import MapKit




 class APIVarsAndValues {
    
    struct Structure {
        
    static let APIScheme = "https"
    static let APIHost = "api.flickr.com"
    static let APIPath = "/services/rest"
    
    static let searchBBoxHalfWidth = 1.0
    static let searchBBoxHalfHight = 1.0
    static let searchLatRange = (-90.0, 90,0)
    static let searchLongRange = (-180.0, 180.0)
    
    }
    
    struct APIKeys {
    static let method = "method"
    static let APIKey = "api_key"
    static let extras = "extras"
    static let format = "format"
    static let noJSONCallBack = "nojsoncallback"
    static let safeSearch = "safe_search"
    static let text = "text"
    static let boundingBox = "bbox"
    static let page = "page"
    static let perPage = "per_page"
    }
    
    struct APIValues {
        
    static let SearchMethod = "flickr.photos.search"
    static let APIKeyValue = "6508876b7d0593f0fff5a03bb5b2d586"
    static let ResponseFormat = "json"
    static let DisableJSONCallback = "1"
    static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
    static let MediumURL = "url_m"
    static let useSafeSearch = "1"
    static var page = 1
    static var perPage = 12
    }

}
/*
 The App Garden
 Create an App API Documentation Feeds    What is the App Garden?
 
 Done! Here's the API key and secret for your new app:
 Virtual Toursit
 Key:
 6508876b7d0593f0fff5a03bb5b2d586
 
 Secret:
 62977f1df8f7c8ef
 
 Edit app details - Edit auth flow for this app - View all Apps by You*/

