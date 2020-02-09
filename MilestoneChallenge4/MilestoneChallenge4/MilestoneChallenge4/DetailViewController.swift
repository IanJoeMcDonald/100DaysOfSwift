//
//  DetailViewController.swift
//  MilestoneChallenge4
//
//  Created by Ian McDonald on 09/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var ImageView: UIImageView!
    var captionedImage: CaptionedImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit,
                                                            target: self,
                                                            action: #selector(editCaption))
        loadImageAndTitle()
    }
    
    func loadImageAndTitle() {
        guard let captionedImage = captionedImage else { fatalError("Captioned Image not set")}
        title = captionedImage.caption
        let path = DocumentsDirectory.shared.get().appendingPathComponent(captionedImage.image)
        ImageView.image = UIImage(contentsOfFile: path.path)
    }
    
    @objc func editCaption() {
        let ac = UIAlertController(title: "Caption",
                                   message: "What caption would you like to give the image?",
                                   preferredStyle: .alert)
        
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Update", style: .default) { [weak self, weak ac] _ in
            let imageCaption = ac?.textFields?[0].text ?? "Untitled"
            if let captionedImage = self?.captionedImage {
                captionedImage.caption = imageCaption
                self?.loadImageAndTitle()
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}
