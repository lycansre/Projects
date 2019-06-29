//
//  ImagesCollection.swift
//  Virtual Tourist
//
//  Created by Programmer on 18/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import UIKit
import UIKit
import CoreData
import MapKit

private let reuseIdentifier = "Cell"

class ImagesCollection: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var grayIndicator: UIActivityIndicatorView!
    @IBOutlet weak var labelEmptyCollection: UILabel!
    @IBOutlet weak var imageCollection: UICollectionView!
    
    var pin : Pin!
    var fetchedDataController : NSFetchedResultsController<Photo>!
    var pageNo = 1
    var deleteData = false
    

    func warnUser (title: String, message: String?) {
        let warning = UIAlertController(title: title, message: message, preferredStyle: .alert)
        warning.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(warning, animated: true, completion: nil)
        }
    }
    
    
    var context : NSManagedObjectContext {
        return DataModel.shared.viewContext
    }
    
    var photosReady : Bool {
        return (fetchedDataController.fetchedObjects?.count ?? 0) != 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.labelEmptyCollection.isHidden = true
        prepareFetchDataController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedDataController = nil
    }
    
    func prepareFetchDataController () {
        let fetchRequest : NSFetchRequest <Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor (key: "creationDate", ascending: false)
        ]
        fetchRequest.predicate = NSPredicate(format: "photoToPin == %@", pin)
        fetchedDataController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedDataController.delegate = self
        
        
        
        
        do {
            try fetchedDataController.performFetch()
            
            if photosReady {
                refreshView(refreshing: false)
                imageCollection.reloadData()
            } else {
                newCollectionPressed(self)
            }
        }
        catch {
            fatalError("Fetching data wasn't successful : \(error.localizedDescription)")
        }
        
    }
    
    func refreshView (refreshing: Bool) {
        imageCollection.isUserInteractionEnabled = !refreshing
        if refreshing {
            newCollectionButton.title = ""
            grayIndicator.startAnimating()
            grayIndicator.isHidden = false
        }
        else {
            grayIndicator.stopAnimating()
            newCollectionButton.title = "New Collection"
            grayIndicator.isHidden = true
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.willTransition(to: newCollection, with: coordinator)
        imageCollection.reloadData()
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        code
        return fetchedDataController.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellView", for: indexPath) as! CollectionCell
        let imageDisplayedInCell = fetchedDataController.object(at: indexPath)
        cell.imageCell.setCell(newPhotoimage: imageDisplayedInCell)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let imageDisplayedInCell = fetchedDataController.object(at: indexPath)
        try? self.context.save()
        
        let alert = UIAlertController(title: "Option?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Share", style: .default, handler: { (_) in
            let image = imageDisplayedInCell.getImage()
                try? self.context.save()
            let imageShare = [ image! ]
            let activityViewController = UIActivityViewController(activityItems: imageShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
        
        }))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { (_) in
            self.context.delete(imageDisplayedInCell)
//            try? self.context.save()
        }))
        present(alert, animated: true, completion: nil)
        
    
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.width-20) / 3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        refreshView(refreshing: true)
        if photosReady {
            deleteData = true
            for image in fetchedDataController.fetchedObjects! {
                context.delete(image)
            }
            try? context.save()
            deleteData = false
        }
        StaticFunctions.getPhotosURLsFromWebsite(with: pin.coordinates, pageNumber: pageNo) { (urls, error, errorMessage) in
            DispatchQueue.main.async {
                self.refreshView(refreshing: false)
                
                guard error == nil && errorMessage == nil else {
                    self.warnUser(title: "Error", message: error?.localizedDescription ?? errorMessage)
                    return
                }
                guard let urls = urls, !urls.isEmpty else {
                    self.labelEmptyCollection.isHidden = false
                    return
                }
                self.labelEmptyCollection.isHidden = true
                for url in urls {
                    let photo = Photo (context: self.context)
                    photo.photoURL = url
                    photo.photoToPin = self.pin
                }
                try? self.context.save()
            }
        }
        pageNo += 1
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        imageCollection.reloadData()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        if let indexPath = indexPath, type == .delete && !deleteData {
            imageCollection.deleteItems(at: [indexPath])
            return
        }
        
        if let indexPath = indexPath, type == .insert {
            imageCollection.insertItems(at: [indexPath])
            return
        }
        
        if let newIndexPath = newIndexPath, let oldIndexPath = indexPath, type == .move {
            imageCollection.moveItem(at: oldIndexPath, to: newIndexPath)
            return
        }
        
        if type != .update {
            imageCollection.reloadData()
        }
    }
    
}

