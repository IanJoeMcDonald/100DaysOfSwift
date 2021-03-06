//
//  ViewController.swift
//  Project10
//
//  Created by Masipack Eletronica on 06/02/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    var people = [Person]()
    var hiddenPeople = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        NotificationCenter.default.addObserver(self, selector: #selector(lockPeople),
                                               name: UIApplication.willResignActiveNotification,
                                               object: nil)
        lockPeople()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person",
                                                            for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        
        cell.name.text = person.name
        
        let path = getDocumentsDitectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha:0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        
        let ac = UIAlertController(title: "Rename or Delete person",
                                   message: "Would you like to rename or remove this person?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Rename", style: .default) { [weak self] _ in
            self?.renamePersonAlertController(path: indexPath)
        })
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deletePersonAlertController(path: indexPath)
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func renamePersonAlertController(path: IndexPath) {
        let person = people[path.item]
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName
            
            self?.collectionView.reloadData()
        })
        
        present(ac, animated: true)
    }
    
    func deletePersonAlertController(path: IndexPath) {
        let ac = UIAlertController(title: "Delete person",
                                   message: "Are you sure you want to remove this person?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.people.remove(at: path.item)
            self?.collectionView.reloadData()
        })
        
        present(ac, animated: true)
    }
    
    @objc func addNewPerson() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            selectLocationAlertController()
        } else {
            cameraRollPicker()
        }
    }
    
    func selectLocationAlertController() {
        let ac = UIAlertController(title: "Camera or Photo Roll",
                                   message: "Would you like to take a picture or select one from the camera roll?",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.cameraPicker()
        })
        ac.addAction(UIAlertAction(title: "Photo Roll", style: .default) { [weak self] _ in
            self?.cameraRollPicker()
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func cameraRollPicker() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func cameraPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo
                                info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDitectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        print(people)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDitectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func unlockPeople() {
        for index in 0 ..< hiddenPeople.count {
            let person = hiddenPeople.remove(at: index)
            people.append(person)
        }
        collectionView.reloadData()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                           action: #selector(addNewPerson))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(lockPeople))
    }
    
    @objc func lockPeople() {
        for index in 0 ..< people.count {
            let person = people.remove(at: index)
            hiddenPeople.append(person)
        }
        collectionView.reloadData()
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Auth", style: .plain,
                                                            target: self,
                                                            action: #selector(authenticateUser))
    }
    
    @objc func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
            reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockPeople()
                    } else {
                        let ac = UIAlertController(title: "Authentication failed",
                                                   message: "You could not be verified; please try again.",
                                                   preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        } else {
           let ac = UIAlertController(title: "Biometry unavailable",
                                      message: "Your device is not configured for biometric authentication.",
                                      preferredStyle: .alert)
           ac.addAction(UIAlertAction(title: "OK", style: .default))
           present(ac, animated: true)
        }
    }
}

