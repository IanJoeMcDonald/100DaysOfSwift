//
//  DetailViewController.swift
//  Project1
//
//  Created by Ian McDonald on 01/01/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var selectedImage: String?
    var imageNumber: Int?
    var totalImages: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Picture \(imageNumber ?? 0) of \(totalImages ?? 0)"
        navigationItem.largeTitleDisplayMode = .never

        assert(selectedImage != nil, "No photo found")
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
