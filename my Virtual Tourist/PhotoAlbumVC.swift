//
//  PhotoAlbumVC.swift
//  my Virtual Tourist
//
//  Created by Raafat Ali on 28/01/2019.
//  Copyright © 2019 Raafat Ali. All rights reserved.
//

import UIKit
import MapKit
import CoreData

import Alamofire
import SwiftyJSON
import NVActivityIndicatorView

class PhotoAlbumVC: UIViewController {
    
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var noImageLable: UILabel!
    
    //weather
   
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    
    let apiKey = "e31c6d872cbb6510a72dd98ff2eb39b6"
    var lat = 5.9
    var lon = 33.6
    var activityIndicatior: NVActivityIndicatorView!
//    let locationMa
    
  
    
    var pin: Pin!
    
    var photosUrlArray = [URL]()
    var selectedPhotos = [IndexPath]()
    
    
   
    
    
    private var blockOperations: [BlockOperation] = []
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", self.pin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newCollectionButton.isEnabled = false
        
        setupFetchedResultsController()
        
        //If it's 0 that mean there're no images downloaded yet !
        if self.fetchedResultsController.fetchedObjects?.count == 0 {
            getPhotosFromFlikr()
        }
        
        createAnnotation()
        setFlowLayout()
        
        collectionView.allowsMultipleSelection = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        
     getWeather()
    }
    func getPhotosFromFlikr(){
        Flickr.sharedInstance().getPhotosFormFlicker(latitude: pin.latitude, longitude: pin.longitude, { (success, photoData,NoPhotoMessage, errorString)  in
            
            if success {
                
                if NoPhotoMessage == nil {
                    
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = true
                    }
                    
                    if let photo = photoData as? [ParsePhoto] {
                        
                        for i in photo {
                            self.photosUrlArray.append(URL(string: i.url_m)!)
                            
                        }
                        
                        self.downloadImagesAndsavaItToPhotoData()
                        
                        
                    }
                }else {
                    DispatchQueue.main.async {
                        self.noImageLable.isHidden = false
                        self.noImageLable.text = NoPhotoMessage
                    }
                }
                
                
                
            }else
            {
               
               myAlert.AlertMsg(on: self, with: "sorry, I couldn't get photos. please try again later ")
                 
            }
        })
    }
    
    func setFlowLayout(){
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    
    @IBAction func newCollectionTapped(_ sender: UIButton) {
        
        if sender.currentTitle == "New Collection" {
            
            guard let fetchedResults = self.fetchedResultsController.fetchedObjects else {
                return
            }
            
            photosUrlArray.removeAll()
            
            for i in fetchedResults {
                dataController.viewContext.delete(i)
                try? dataController.viewContext.save()
            }
            
            getPhotosFromFlikr()
            
        } else if sender.currentTitle == "Remove Selected Pictures" {
            
            sender.setTitle("New Collection", for: .normal)
            
            deletePhotos()
            
            
        }
        
    }
    
    
    func createAnnotation(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        self.mapView.addAnnotation(annotation)
        
        
        //zooming to location
        let coredinate:CLLocationCoordinate2D = CLLocationCoordinate2DMake(pin.latitude, pin.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.07, longitudeDelta: 0.07)
        let region = MKCoordinateRegion(center: coredinate, span: span)
        self.mapView.setRegion(region, animated: true)
      
   
    }
    
    func updateUI(cell:PhotoAlbumCollectionViewCell, status:Bool) {
        
        if status == false {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            
        } else {
            cell.activityIndicator.stopAnimating()
            cell.activityIndicator.isHidden = true
            
            
        }
    }
    
    func downloadImagesAndsavaItToPhotoData(){
        
        if ((fetchedResultsController.fetchedObjects?.isEmpty)!) {
            
            for url in photosUrlArray {
                
                let dataTask = URLSession.shared.dataTask(with: url) {
                    data, response, error in
                    
                    if error == nil {
                        if let data = data {
                            
                            self.addPhotosToCoreData(data:data)
                            
                            
                            
                        }
                        
                    }else {
                        print(error!)
                    }
                    
                }
                dataTask.resume()
                
            }
            
            
            
            
        }
        
    }
    
    func addPhotosToCoreData(data:Data) {
        let photo = Photo(context: dataController.viewContext)
        
        photo.imgData = data
        photo.creationDate = Date()
        photo.pin = pin
        
        do
        {
            try dataController.viewContext.save()
        }
        catch
        {
            //ERROR
            print(error)
        }
        
    }
    
    func deletePhotos() {
        
        var photosToDelete: [Photo] = [Photo]()
        
        for i in selectedPhotos {
            photosToDelete.append(fetchedResultsController.object(at: i))
        }
        
        for i in photosToDelete {
            dataController.viewContext.delete(i)
            try? dataController.viewContext.save()
        }
        
        selectedPhotos.removeAll()
        
    }
    
    
    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }
//------------------------------------------------------------------------
func getWeather()
{
lat = pin.latitude
lon = pin.longitude
/*  Alamofire.request("http//api.openweathermap.org/data/2.5/weahter?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON{*/

Alamofire.request("https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON{
        response in
        if let responseStr = response.result.value {
            let jsonResponse = JSON(responseStr)
            let jsonWeather = jsonResponse["weather"].array![0]
            let jsonTemp  = jsonResponse["main"]
            let iconName = jsonWeather["icon"].stringValue
         
            
// SELF.locagionLabel.text = jsonResponse["name"].stringValue
            self.conditionImageView.image = UIImage(named: iconName)
   //self.conditionLa
     self.temperatureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
            
        }
    }
    
    }
    
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}



//=========================================================




//Mark: extensions
extension PhotoAlbumVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        
        if let sectionInfo = self.fetchedResultsController.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.selectedView.isHidden = true
        
        self.updateUI(cell: cell, status: false)
        
        
        
        let arrayData = self.fetchedResultsController.fetchedObjects!
        cell.imageFlikr.image =  UIImage(data: arrayData[indexPath.row].imgData!)
        
        
        self.updateUI(cell: cell, status: true)
        
        newCollectionButton.isEnabled = true
        
        
        
        
        
        
        return cell
        
    }
    
    
}




extension PhotoAlbumVC: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.selectedView.isHidden = false
        newCollectionButton.setTitle("Remove Selected Pictures", for: .normal)
        
        selectedPhotos.append(indexPath)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoAlbumCollectionViewCell
        
        cell.selectedView.isHidden = true
        
        selectedPhotos.remove(at: indexPath.startIndex)
        
        if selectedPhotos.count == 0 {
            newCollectionButton.setTitle("New Collection", for: .normal)
        }
    }
    
}


//Mark : CoreData FetchedResultsController
extension PhotoAlbumVC:NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        
        let op: BlockOperation
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.insertItems(at: [newIndexPath]) }
            
        case .delete:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.deleteItems(at: [indexPath]) }
        case .move:
            guard let indexPath = indexPath,  let newIndexPath = newIndexPath else { return }
            op = BlockOperation { self.collectionView.moveItem(at: indexPath, to: newIndexPath) }
        case .update:
            guard let indexPath = indexPath else { return }
            op = BlockOperation { self.collectionView.reloadItems(at: [indexPath]) }
        }
        
        blockOperations.append(op)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }
    
    
}

