//
//  ViewController.swift
//  MilestoneChallenge8
//
//  Created by Masipack Eletronica on 12/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var viewMove: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func buttonPressed(_ sender: UIButton) {
        viewMove.bounceOut(duration: 4)
        6.times { print("Hello!") }
        let minus3 = -3
        minus3.times { print("Fail") }
        var array = ["Hello", "Removed", "World!"]
        array.remove(item: "Removed")
        print(array)
    }
}

extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) {
            self.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

extension Int {
    func times(closure: () ->Void) {
        if self > 0 {
            for _ in 1...self {
                closure()
            }
        }
    }
}

extension Array where Element:Comparable {
    mutating func remove(item: Element) {
        if let index = self.firstIndex(of: item) {
            self.remove(at: index)
        }
    }
}

