//
//  ViewController.swift
//  Project16
//
//  Created by Masipack Eletronica on 09/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), address: "http://en.wikipedia.org/wiki/London")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), address: "http://en.wikipedia.org/wiki/Oslo")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), address: "http://en.wikipedia.org/wiki/Paris")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), address: "http://en.wikipedia.org/wiki/Rome")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.036667), address: "http://en.wikipedia.org/wiki/Washington,_D.C.")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        
        title = "Capitals"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Style", style: .plain, target: self, action: #selector(setMapStyle))
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1
        guard annotation is Capital else { return nil }

        // 2
        let identifier = "Capital"

        // 3
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView

        if annotationView == nil {
            //4
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.pinTintColor = UIColor.green

            // 5
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            // 6
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = storyboard.instantiateViewController(identifier: "Detail") as! DetailViewController
        
        vc.capital = capital
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func setMapStyle() {
        let ac = UIAlertController(title: "Select map style...", message: nil,
                                   preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Standard", style: .default,
                                   handler: { _ in self.mapView.mapType = .standard }))
        ac.addAction(UIAlertAction(title: "Muted Standard", style: .default,
                                   handler: { _ in self.mapView.mapType = .mutedStandard }))
        ac.addAction(UIAlertAction(title: "Hybrid", style: .default,
                                   handler: { _ in self.mapView.mapType = .hybrid }))
        ac.addAction(UIAlertAction(title: "Hybrid Flyover", style: .default,
                                   handler: { _ in self.mapView.mapType = .hybridFlyover }))
        ac.addAction(UIAlertAction(title: "Satellite", style: .default,
                                   handler: { _ in self.mapView.mapType = .satellite }))
        ac.addAction(UIAlertAction(title: "Satellite Flyover", style: .default,
                                   handler: { _ in self.mapView.mapType = .satelliteFlyover }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
}

