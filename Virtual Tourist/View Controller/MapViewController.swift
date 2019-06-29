//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Programmer on 16/06/2019.
//  Copyright © 2019 Programmer. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class MapViewControler: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate  {

    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedDataController : NSFetchedResultsController<Pin>!
    
    var context : NSManagedObjectContext {
        return DataModel.shared.viewContext
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        prepareFetchDataController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedDataController = nil
    }
    
    func prepareFetchDataController () {
        let fetchRequest : NSFetchRequest <Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor (key: "creationDate", ascending: false)
        ]
        
        fetchedDataController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedDataController.delegate = self
        
        do {
            try fetchedDataController.performFetch()
            updateMap()
        }
        catch {
            fatalError("Fetching data wasn't successful : \(error.localizedDescription)")
        }
    }
   
    func updateMap() {
        guard let pins = fetchedDataController.fetchedObjects else { return }
        for pin in pins {
            if mapView.annotations.contains(where: {pin.isEqual(to: $0.coordinate) }) {continue}
                let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinates
            mapView.addAnnotation(annotation)
            }
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToImages" {
            let imagesCollection = segue.destination as! ImagesCollection
            imagesCollection.pin = sender as? Pin
        }
    }
    
    func mapView(_ mapView: MKMapView,didSelect view: MKAnnotationView) {
        let pin = fetchedDataController.fetchedObjects?.filter {$0.isEqual(to: view.annotation!.coordinate) }.first!
        performSegue(withIdentifier: "goToImages", sender: pin)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateMap()
    }

    @IBAction func longGesture(_ sender: UILongPressGestureRecognizer) {
        if sender.state != .began {return}
        let touchTip = sender.location(in: mapView)
        let pin = Pin(context: context)
        pin.coordinates = mapView.convert(touchTip, toCoordinateFrom: mapView)
        try? context.save()
    }
}

