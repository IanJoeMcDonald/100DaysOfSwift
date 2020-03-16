//
//  ViewController.swift
//  MilestoneChallenge9
//
//  Created by Ian McDonald on 16/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

enum Location {
    case top, bottom
}

class ViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    var topText = "" {
        didSet {
            renderImage()
        }
    }
    
    var bottomText = "" {
        didSet {
            renderImage()
        }
    }
    
    var memeImage: UIImage? {
        didSet {
            renderImage()
        }
    }
    
    var renderedImage: UIImage? {
        didSet {
            imageView.image = renderedImage
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                           target: self,
                                                           action: #selector(addPhotoPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                            target: self,
                                                            action: #selector(sharePressed))
    }

    func getText(for location: Location) {
        let title: String
        let message: String
        
        switch location {
        case .top:
            title = "Top Text"
            message = "Insert the text for the top of the meme"
            
        case .bottom:
            title = "Bottom Text"
            message = "Insert the text for the bottom of the meme"
        }
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            self.setText(ac.textFields?[0].text ?? "", for: location)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.setText("", for: location)
        }))
        present(ac, animated: true)
    }
    
    func setText(_ text: String, for location: Location) {
        if location == .top {
            topText = text
        } else {
            bottomText = text
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        memeImage = image
        
        dismiss(animated: true)
    }
    
    func renderImage() {
        guard let image = memeImage else { return }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        
        let imageRect = CGRect(origin: CGPoint(x: 0, y: 0), size: image.size)
        
        let img = renderer.image { ctx in
            image.draw(in: imageRect)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "Chalkduster", size: 60) as Any,
                .paragraphStyle: paragraphStyle,
                .foregroundColor: UIColor.white
            ]
            
            let topAttString = NSAttributedString(string: topText, attributes: attrs)
            topAttString.draw(with: CGRect(x: 0, y: 0,
                                               width: image.size.width,
                                               height: image.size.height / 3),
                                  options: .usesLineFragmentOrigin, context: nil)
            
            let bottomAttString = NSAttributedString(string: bottomText, attributes: attrs)
            let textSize = bottomAttString.size()
            bottomAttString.draw(with: CGRect(x: 0, y: image.size.height - textSize.height,
                                            width: image.size.width,
                                            height: textSize.height),
                                 options: .usesLineFragmentOrigin, context: nil)
        }
        
        renderedImage = img
    }
    
    @objc func addPhotoPressed() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func sharePressed() {
        guard let jpegImage = renderedImage?.jpegData(compressionQuality: 0.8) else { return }
        
        let vc = UIActivityViewController(activityItems: [jpegImage],
                                          applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @IBAction func topButtonPressed(_ sender: UIButton) {
        getText(for: .top)
    }
    
    @IBAction func bottomButtonPressed(_ sender: UIButton) {
        getText(for: .bottom)
    }
    
}

