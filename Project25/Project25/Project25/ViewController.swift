//
//  ViewController.swift
//  Project25
//
//  Created by Ian McDonald on 14/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {

    var images = [UIImage]()
    
    var peerID = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        title = "Selfie Share"
        let camera = UIBarButtonItem(barButtonSystemItem: .camera, target: self,
                                     action: #selector(importPicture))
        let text = UIBarButtonItem(title: "Text", style: .plain, target: self,
                                   action: #selector(sendText))
        navigationItem.rightBarButtonItems = [camera, text]
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                  action: #selector(showConnectionPrompt))
        let show = UIBarButtonItem(title: "Show", style: .plain, target: self,
                                  action: #selector(showConnections))
        navigationItem.leftBarButtonItems = [add, show]
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil,
                              encryptionPreference: .required)
        mcSession?.delegate = self
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    @objc func sendText() {
        let ac = UIAlertController(title: "Send Text", message: "Enter text below to send text",
                                   preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak self]_ in
            if let text = ac.textFields?[0].text {
                guard let mcSession = self?.mcSession else { return }
                if mcSession.connectedPeers.count > 0 {
                    do {
                        try mcSession.send(Data(text.utf8), toPeers: mcSession.connectedPeers,
                                           with: .reliable)
                    } catch {
                        let ac = UIAlertController(title: "Send error",
                                                   message: error.localizedDescription,
                                                   preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @objc func showConnections() {
        var connsList = ""
        
        if mcSession?.connectedPeers.count == 0 {
            connsList = "None"
        } else if let mcSession = mcSession {
            for index in 0..<mcSession.connectedPeers.count {
                connsList += mcSession.connectedPeers[index].displayName + "\n"
            }
        }
        
        let ac = UIAlertController(title: "Connections", message: connsList, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        
        dismiss(animated: true)
        
        images.insert(image, at: 0)
        collectionView.reloadData()
        
        // 1
        guard let mcSession = mcSession else { return }
        
        // 2
        if mcSession.connectedPeers.count > 0 {
            // 3
            if let imageData = image.pngData() {
                // 4
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers,
                                       with: .reliable)
                } catch {
                    // 5
                    let ac = UIAlertController(title: "Send error",
                                               message: error.localizedDescription,
                                               preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default,
                                   handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default,
                                   handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
            
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
            let ac = UIAlertController(title: "Disconnect", message: "\(peerID.displayName) had disconnected", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        @unknown default:
            print("Unknown state received; \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                let text = String(decoding: data, as: UTF8.self)
                let ac = UIAlertController(title: "\(peerID.displayName) sent a message",
                    message: text, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Close", style: .cancel))
                self?.present(ac, animated: true)
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

}

