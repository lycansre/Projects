//
//  PinExtension.swift
//  Virtual Tourist
//
//  Created by Programmer on 20/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import Foundation
import MapKit

extension Pin {
    var coordinates : CLLocationCoordinate2D {
        set {
            longitude = newValue.longitude
            latitude = newValue.latitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
    }
    
    func isEqual(to coordinates: CLLocationCoordinate2D) -> Bool {
        
        return (latitude == coordinates.latitude && longitude == coordinates.longitude)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
