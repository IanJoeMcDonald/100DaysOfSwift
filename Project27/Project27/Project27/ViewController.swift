//
//  ViewController.swift
//  Project27
//
//  Created by Masipack Eletronica on 16/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        drawRectangle()
    }

    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            let rectangle =  CGRect(x: 0, y: 0, width: 512, height: 512)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            let rectangle =  CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5)
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = img
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = img
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            let rotations = 16
            let amount  = Double.pi / Double(rotations)
            
            for _ in 0 ..< rotations {
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))

        let img = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256)
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi/2)
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    func drawImagesAndText() {
        // 1
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            // 2
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            // 3
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]
            
            // 4
            let string = "The best-laid schemes o'\nmicean' men gang aft agley"
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448),
                                  options: .usesLineFragmentOrigin, context: nil)
            
            // 5
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
            
        }
        
        // 6
        imageView.image = img
    }
    
    func drawEmoji() {
        let center = CGPoint(x: 256, y: 256)
        let r: CGFloat = 256
        let flip: CGFloat = -1
        
        let theta = 2.0 * Double.pi * (2.0 / 5)
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512))
        
        let img = renderer.image { ctx in
            let x: CGFloat = r * CGFloat(sin(0 * theta)) + center.x
            let y: CGFloat = r * CGFloat(cos(0 * theta)) * flip + center.y
            ctx.cgContext.move(to: CGPoint(x: x, y: y))
            for index in 1 ..< 5 {
                let x: CGFloat = r * CGFloat(sin(Double(index) * theta))
                let y: CGFloat = r * CGFloat(cos(Double(index) * theta))
                
                ctx.cgContext.addLine(to: CGPoint(x: x + center.x, y: y * flip + center.y))
            }
            ctx.cgContext.closePath()
            ctx.cgContext.setFillColor(UIColor.yellow.cgColor)
            ctx.cgContext.fillPath()
        }
        
        imageView.image = img
    }
    
    func drawTwin() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 500, height: 100))
        
        let img = renderer.image { ctx in
            ctx.cgContext.move(to: CGPoint(x: 5, y: 2.5))
            ctx.cgContext.addLine(to: CGPoint(x: 95, y: 2.5))
            ctx.cgContext.move(to: CGPoint(x: 47.5, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 47.5, y: 100))
            
            ctx.cgContext.move(to: CGPoint(x: 100,y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 147.5, y: 100))
            ctx.cgContext.addLine(to: CGPoint(x: 195, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 242.5, y: 100))
            ctx.cgContext.addLine(to: CGPoint(x: 290, y: 0))
            
            ctx.cgContext.move(to: CGPoint(x: 300, y: 2.5))
            ctx.cgContext.addLine(to: CGPoint(x: 390, y: 2.5))
            ctx.cgContext.move(to: CGPoint(x: 300, y: 97.5))
            ctx.cgContext.addLine(to: CGPoint(x: 390, y: 97.5))
            ctx.cgContext.move(to: CGPoint(x: 345, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 345, y: 100))
            
            ctx.cgContext.move(to: CGPoint(x: 400, y: 100))
            ctx.cgContext.addLine(to: CGPoint(x: 400, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: 490, y: 100))
            ctx.cgContext.addLine(to: CGPoint(x: 490, y: 0))
        
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = img
    }
    
    @IBAction func redrawTapped(_ sender: UIButton) {
        currentDrawType += 1
        
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
        case 1:
            drawCircle()
        case 2:
            drawCheckerboard()
        case 3:
            drawRotatedSquares()
        case 4:
            drawLines()
        case 5:
            drawImagesAndText()
        case 6:
            drawEmoji()
        case 7:
            drawTwin()
            
        default:
            break
        }
    }
}

