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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(shareTapped))
        navigationItem.largeTitleDisplayMode = .never

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
    
    @objc func shareTapped() {
        guard let image = imageView.image else { return }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        
        let img = renderer.image { ctx in
            
            image.draw(in: rect)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .right
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle,
                .backgroundColor: UIColor.black,
                .foregroundColor: UIColor.white
            ]
            
            let string = "From Storm Viewer"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            attributedString.draw(with: rect,
                                  options: .usesLineFragmentOrigin, context: nil)
            
            
        }
        
        let vc = UIActivityViewController(activityItems: [img, selectedImage],
                                          applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }

}
