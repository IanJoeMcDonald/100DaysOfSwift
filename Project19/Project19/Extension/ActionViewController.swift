//
//  ActionViewController.swift
//  Extension
//
//  Created by Masipack Eletronica on 10/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    @IBOutlet weak var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    var actionFiles = [String:ActionFile]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done,
                                                            target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Scripts", style: .plain,
                                                           target: self,
                                                           action: #selector(prewrittenScripts))
        loadActions()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillHideNotification,
                                       object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard),
                                       name: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil)
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues =
                        itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as?
                        NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        if let urlString = self?.pageURL {
                            print(urlString)
                            self?.script.text = self?.actionFiles[urlString]?.text ?? ""
                        }
                    }
                }
            }
        }
    }

    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text as Any]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary,
                                              typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        
        let newScript = ActionFile(title: pageTitle, text: script.text)
        actionFiles[pageURL] = newScript
        saveActions()
        
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
            as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0,
                                               bottom: keyboardViewEndFrame.height -
                                                view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
    
    @objc func prewrittenScripts() {
        let ac = UIAlertController(title: "Scripts", message: "Select from the scripts below...",
                                   preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Alert Title", style: .default,
                                   handler: { _ in self.script.text = "alert(document.title);"}))
        ac.addAction(UIAlertAction(title: "Alert URL", style: .default,
                                   handler: { _ in self.script.text = "alert(document.URL);"}))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    private func saveActions() {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(actionFiles) {
            UserDefaults.standard.set(data, forKey: "actionFiles")
        }
    }
    
    private func loadActions() {
        let decoder = JSONDecoder()
        
        if let data = UserDefaults.standard.value(forKey: "actionFiles") as? Data {
            if let decoded = try? decoder.decode([String: ActionFile].self, from: data) {
                actionFiles = decoded
            }
        }
    }

}
