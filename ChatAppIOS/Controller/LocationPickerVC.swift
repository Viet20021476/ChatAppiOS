//
//  LocationPickerVC.swift
//  ChatAppIOS
//
//  Created by Nguyễn Duy Việt on 22/08/2022.
//

import UIKit
import CoreLocation
import MapKit

protocol LocationPickerVCDelegate {
    func getLocation(coordinates: CLLocationCoordinate2D)
}

class LocationPickerVC: BaseViewController {
    
    var delegate: LocationPickerVCDelegate?
    
    var coordinates: CLLocationCoordinate2D?
    var isPickable = true
    
    var map = MKMapView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(map)
        
        // Do any additional setup after loading the view.
        
        if isPickable {
            
            if let coor = self.coordinates {
                let pin = MKPointAnnotation()
                pin.coordinate = coor
                map.addAnnotation(pin)
                let region = MKCoordinateRegion(center: coor, latitudinalMeters: CLLocationDistance(exactly: 100)!, longitudinalMeters: CLLocationDistance(exactly: 100)!)
                map.setRegion(map.regionThatFits(region), animated: true)
            }
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send",
                                                                style: .done,
                                                                target: self,
                                                                action: #selector(sendLocation))
            
            map.isUserInteractionEnabled = true
            
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(didTapMap(sender:)))
            tapGes.numberOfTapsRequired = 1
            tapGes.numberOfTouchesRequired = 1
            map.addGestureRecognizer(tapGes)
        } else {
            if let coor = self.coordinates {
                let pin = MKPointAnnotation()
                pin.coordinate = coor
                map.addAnnotation(pin)
                let region = MKCoordinateRegion(center: coor, latitudinalMeters: CLLocationDistance(exactly: 100)!, longitudinalMeters: CLLocationDistance(exactly: 100)!)
                map.setRegion(map.regionThatFits(region), animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        map.frame = view.bounds
    }
    
    @objc func sendLocation() {
        if let coor = coordinates {
            delegate?.getLocation(coordinates: coor)
            navigationController?.popViewController(animated: true)
        } else {
            return
        }
    }
    
    @objc func didTapMap(sender: UITapGestureRecognizer) {
        let locationInView = sender.location(in: map)
        coordinates = map.convert(locationInView, toCoordinateFrom: map)
        
        for annotation in map.annotations {
            map.removeAnnotation(annotation)
        }
        
        // Drop a pin on that location
        let pin = MKPointAnnotation()
        pin.coordinate = coordinates!
        map.addAnnotation(pin)
        
    }
    
}
