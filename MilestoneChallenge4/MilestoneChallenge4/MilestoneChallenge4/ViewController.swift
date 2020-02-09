//
//  ViewController.swift
//  MilestoneChallenge4
//
//  Created by Ian McDonald on 09/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var captionedImages = [CaptionedImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(addNewImage))
        
        
        loadUserDefaults()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        saveUserDefaults()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return captionedImages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd MMM y"
        cell.textLabel?.text = captionedImages[indexPath.row].caption
        cell.detailTextLabel?.text = formatter.string(from: captionedImages[indexPath.row].date)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "DetailViewController")
            as? DetailViewController {
            vc.captionedImage = captionedImages[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func addNewImage() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            selectSourceForImage()
        } else {
            selectFromCameraRoll()
        }
    }
    
    func selectSourceForImage() {
        let ac = UIAlertController(title: "Select Source...", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Camera", style: .default){ [weak self] _ in
            self?.takePictureWithCamera()
        })
        ac.addAction(UIAlertAction(title: "Cameral Roll", style: .default) { [weak self] _ in
            self?.selectFromCameraRoll()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func selectFromCameraRoll() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func takePictureWithCamera() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func loadUserDefaults() {
        if let savedImages = UserDefaults.standard.object(forKey: "images") as? Data {
            do {
                captionedImages = try JSONDecoder().decode([CaptionedImage].self, from: savedImages)
            } catch {
                print("Failed to load saved Images")
            }
        }
    }
    
    func saveUserDefaults() {
        if let savedImages = try? JSONEncoder().encode(captionedImages) {
            UserDefaults.standard.set(savedImages, forKey: "images")
        } else {
            print("Failed to save images")
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo
        info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = DocumentsDirectory.shared.get().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let captionedImage = CaptionedImage(caption: "Untitled", image: imageName)
        captionedImages.append(captionedImage)
        
        dismiss(animated: true) {
            self.captionImage()
        }
    }
    
    func captionImage() {
        let ac = UIAlertController(title: "Caption",
                                   message: "What caption would you like to give the image?",
                                   preferredStyle: .alert)
        
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Add", style: .default) { [weak self, weak ac] _ in
            let imageCaption = ac?.textFields?[0].text ?? "Untitled"
            if let captionedImage = self?.captionedImages.last {
                captionedImage.caption = imageCaption
                self?.tableView.reloadData()
                self?.saveUserDefaults()
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
}

