//
//  EditedImage.swift
//  Virtual Tourist
//
//  Created by Programmer on 18/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import Foundation
import UIKit





class EditedImage: UIImageView {

    lazy var ai: UIActivityIndicatorView = {
        var ai = UIActivityIndicatorView(style: .gray)
        addSubview(ai)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        ai.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        ai.hidesWhenStopped = true
        return ai
    }()
    
    
    var photo: Photo?
    
    func setCell(newPhotoimage: Photo) {
        if photo != nil {
            if photo?.creationDate == newPhotoimage.creationDate {
                return
            }
        }
        photo = newPhotoimage
        
        if photo == nil || photo?.photoURL == nil {
            return
        }
        
        self.ai.startAnimating()
        self.image = nil
    
        DispatchQueue.global(qos: .background).async {
            let data = try? Data(contentsOf: (self.photo?.photoURL)!)
            
            DispatchQueue.main.async {
                self.ai.stopAnimating()
                self.image = UIImage(data: data!)
                
                self.photo?.photoData = data
                try? DataModel.shared.viewContext.save()
            }
        }
    }

}
