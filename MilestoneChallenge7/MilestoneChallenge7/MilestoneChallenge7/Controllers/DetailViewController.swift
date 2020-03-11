//
//  DetailViewController.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var coordinator: MainCoordinator!
    var note: Note!
    
    private var detailView: DetailView!
    private var modifyingText = false {
        didSet {
            if modifyingText {
                navigationItem.rightBarButtonItems = [doneButton, deleteButton, shareButton]
            } else {
                navigationItem.rightBarButtonItems = [deleteButton, shareButton]
            }
        }
    }
    
    private let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self,
                                               action: #selector(deleteNote))
    private let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self,
                                              action: #selector(shareNote))
    private let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self,
                                             action: #selector(resignKeyboard))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        instantiateView()
        instantiateNotifications()
        modifyingText = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if modifyingText {
            updateNote()
        }
    }
    
    private func instantiateView() {
        detailView = DetailView()
        detailView.setText(note.text)
        view = detailView
    }
    
    private func instantiateNotifications() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        nc.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
    }
    
    private func updateNote() {
        note.text = detailView.text
        note.date = Date()
        coordinator.updateNote(note)
    }
    
    @objc private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            detailView.adjustForKeyboard(offset: .zero)
        } else {
            detailView.adjustForKeyboard(offset: UIEdgeInsets(top: 0, left: 0,
                                                              bottom: keyboardViewEndFrame.height
                                                                - view.safeAreaInsets.bottom,
                                                              right: 0))
            modifyingText = true
        }
    }
    
    @objc private func resignKeyboard() {
        detailView.endEditing(true)
        modifyingText = false
        updateNote()
    }
    
    @objc private func deleteNote() {
        coordinator.deleteNote(withId: note.id)
    }
    
    @objc private func shareNote() {
        coordinator.shareNote(text: note.text)
    }
}
