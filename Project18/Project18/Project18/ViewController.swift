//
//  ViewController.swift
//  Project18
//
//  Created by Masipack Eletronica on 09/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("I'm inside the viewDidLoad() method!")
        print(1, 2, 3, 4, 5)
        print("Some message", terminator: "")
        print(1, 2, 3, 4, 5, separator: "-")
        
        assert(1==1, "Maths failure!")
        // Commented out to prevent crash
        //assert(1==2, "Maths failure!")
        
        assert(myReallySlowMethod() == true, "The slow method returned false, which is a bad thing!")
        
        for i in 1 ... 100 {
            print("Got number \(i)")
        }
    }
    
    func myReallySlowMethod() -> Bool {
        // Do some long/complicated calculations here
        return true
    }


}

