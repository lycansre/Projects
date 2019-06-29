//
//  StaticFunctions.swift
//  Virtual Tourist
//
//  Created by Programmer on 21/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import Foundation
import MapKit
import UIKit


class StaticFunctions : UIViewController {
    
    
    
    static func getPhotosURLsFromWebsite(with coordinates: CLLocationCoordinate2D,pageNumber: Int, completion: @escaping([URL]?,Error?, String?) -> ()) {
        let parametersForMethods = [
            APIVarsAndValues.APIKeys.method : APIVarsAndValues.APIValues.SearchMethod,
            APIVarsAndValues.APIKeys.APIKey : APIVarsAndValues.APIValues.APIKeyValue,
            APIVarsAndValues.APIKeys.boundingBox : returnStringFromCoordinateForBBoxParameters(for: coordinates),
            APIVarsAndValues.APIKeys.extras: APIVarsAndValues.APIValues.MediumURL,
            APIVarsAndValues.APIKeys.noJSONCallBack: 1,
            APIVarsAndValues.APIKeys.format: "json",
            APIVarsAndValues.APIKeys.page: pageNumber,
            APIVarsAndValues.APIKeys.perPage: 20
            ] as [String : Any]
        
    
        //"format": "json",
        //"nojsoncallback": "1",
        //"page": pageNumber,
        //"per_page": 5
        
        func createURL (from parameters: [String:Any]) -> URL {
            var components = URLComponents()
            components.scheme = APIVarsAndValues.Structure.APIScheme
            components.host = APIVarsAndValues.Structure.APIHost
            components.path = APIVarsAndValues.Structure.APIPath
            components.queryItems = [URLQueryItem]()
            
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
            return components.url!
        }
        
        let urlRequest = URLRequest(url: createURL(from: parametersForMethods ))
        
        print(urlRequest)
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                completion(nil, error, nil)
                return
            }
            
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                completion(nil, nil, "There seems to be a problem, close the app and try again")
                return
            }
            
            guard let data = data else {
                completion(nil, nil, "No data available try again ")
                return
            }
            print(String(data: data, encoding: .utf8))
            guard let result = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                completion(nil, nil, "Data couldn't be converted to json.")
                return
            }
            
            guard let stat = result["stat"] as? String, stat == "ok" else {
                completion(nil, nil, "There seems to be a problem in Flickr API check this \(result)")
                return
            }
            guard let photosDictionary = result ["photos"] as? [String:Any] else {
                completion (nil,nil, "Couldn't find key photos in \(result)")
                return
            }
            
            guard let photosArray = photosDictionary["photo"] as? [[String:Any]] else {
                completion(nil, nil, "Couldn't find key photos in \(photosDictionary)")
                return
            }
            
            
            var photosURLs = [URL]()
            for photosDictionary in photosArray {
                guard let urlString = photosDictionary["url_m"] as? String else {return}
                let url = URL(string: urlString)
                photosURLs.append(url!)
            }
            
            
            completion(photosURLs, nil, nil)
        }
        task.resume()
        
    }
    
    
    static func returnStringFromCoordinateForBBoxParameters(for coordinate: CLLocationCoordinate2D) -> String {
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        
        let minimumLatitude = max(latitude - 1.0,-180 )
        let minimumLongitude = max(longitude - APIVarsAndValues.Structure.searchBBoxHalfHight, -90 )
        let maximumLatitude = max(latitude + APIVarsAndValues.Structure.searchBBoxHalfWidth,180 )
        let maximumLongitude = max(longitude + APIVarsAndValues.Structure.searchBBoxHalfHight, 90)
        return "\(minimumLatitude), \(minimumLongitude), \(maximumLatitude), \(maximumLongitude)"
    }
    
    
    
    
}




