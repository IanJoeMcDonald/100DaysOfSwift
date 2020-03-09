//
//  Capital.swift
//  Project16
//
//  Created by Masipack Eletronica on 09/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import MapKit

class Capital: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var address: String

    init(title: String, coordinate: CLLocationCoordinate2D, address: String) {
        self.title = title
        self.coordinate = coordinate
        self.address = address
    }
}
