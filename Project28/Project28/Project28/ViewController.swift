//
//  ViewController.swift
//  Project28
//
//  Created by Masipack Eletronica on 17/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    @IBOutlet weak var secret: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)
        
        title = "Nothing to see here"
        checkForPassword()
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue else { return }
        
        let keyboardSceneEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardSceneEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top:0, left: 0,
                                               bottom: keyboardViewEndFrame.height -
                                                view.safeAreaInsets.bottom,
                                               right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self,
                                                            action: #selector(saveSecretMessage))
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder()
        secret.isHidden = true
        title = "Nothing to see here"
        
        navigationItem.rightBarButtonItem = nil
    }
    
    func checkForPassword() {
        if let _ = KeychainWrapper.standard.string(forKey: "Password") { return }
        
        let ac = UIAlertController(title: "Set Unlock Password",
                                   message: "Enter the password to unlock the secret message",
                                   preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].isSecureTextEntry = true
        ac.addAction(UIAlertAction(title: "Set", style: .default, handler: { _ in
            if let password = ac.textFields?[0].text {
                KeychainWrapper.standard.set(password, forKey: "Password")
            }
        }))
        present(ac, animated: true)
    }
    
    func comparePassword() {
        let ac = UIAlertController(title: "Enter Unlock Password", message: nil,
                                   preferredStyle: .alert)
        ac.addTextField()
        ac.textFields?[0].isSecureTextEntry = true
        ac.addAction(UIAlertAction(title: "Unlock", style: .default, handler: { [weak self] _ in
            if let password = ac.textFields?[0].text {
                let storedPassword = KeychainWrapper.standard.string(forKey: "Password")
                if password == storedPassword {
                    self?.unlockSecretMessage()
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:
            reason) { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.unlockSecretMessage()
                    } else {
                        self?.comparePassword()
                    }
                }
            }
        } else {
           comparePassword()
        }
    }
}

