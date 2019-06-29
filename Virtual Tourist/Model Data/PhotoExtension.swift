//
//  PhotoExtension.swift
//  Virtual Tourist
//
//  Created by Programmer on 24/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import Foundation
import UIKit
import MapKit


extension Photo {
    
    func set (image: UIImage) {
        self.photoData = image.pngData()
    }
    
    func getImage () -> UIImage? {
        return (photoData == nil) ? nil : UIImage(data: photoData!)
    }
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}
