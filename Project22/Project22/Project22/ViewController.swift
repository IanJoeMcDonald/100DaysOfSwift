//
//  ViewController.swift
//  Project22
//
//  Created by Ian McDonald on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager?
    var firstBeaconFound = true
    
    @IBOutlet weak var distanceReading: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var circleView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        updateCircle(distance: .unknown)
        
        view.backgroundColor = .gray
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon],
                         satisfying beaconConstraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity, uuid: beacon.uuid)
        } else {
            update(distance: .unknown, uuid: nil)
        }
        
    }
    
    func startScanning() {
        let uuid1 = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5")!
        let uuid2 = UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0")!
        let uuid3 = UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935")!
        
        let uuidList = [uuid1, uuid2, uuid3]
        
        
        /// This code doesn't work, I have tried various different ways however only the last beacon added works. I may return in the future to try and fix this
        for index in 0..<uuidList.count {
            let uuid = uuidList[index]
            let beaconIdentity = CLBeaconIdentityConstraint(uuid: uuid)
            let beaconRegion = CLBeaconRegion(uuid: uuid, identifier: "Beacon\(index)")
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(satisfying: beaconIdentity)
        }
    }
    
    func update(distance: CLProximity, uuid: UUID?) {
        var showAlert = false
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"
                self.uuidLabel.text = uuid?.uuidString
                showAlert = true
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"
                self.uuidLabel.text = uuid?.uuidString
                showAlert = true
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
                self.uuidLabel.text = uuid?.uuidString
                showAlert = true
            default:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
                self.uuidLabel.text = "UNKNOWN"
            }
        }
        updateCircle(distance: distance)
        if showAlert && firstBeaconFound {
            firstBeaconFound = false
            
            let ac = UIAlertController(title: "Beacon Found", message: "Congratulations",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Close", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    func updateCircle(distance: CLProximity) {
        circleView.layer.cornerRadius = 128
        circleView.clipsToBounds = true
        UIView.animate(withDuration: 1) {
            switch distance{
            case .far:
                self.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
            case .near:
                self.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            case .immediate:
                self.circleView.transform = CGAffineTransform(scaleX: 1, y: 1)
            default:
                self.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
        
    }
}

