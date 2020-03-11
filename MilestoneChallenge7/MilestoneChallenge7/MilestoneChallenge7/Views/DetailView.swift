//
//  DetailView.swift
//  MilestoneProject7
//
//  Created by Masipack Eletronica on 11/03/20.
//  Copyright © 2020 Ian McDonald. All rights reserved.
//

import UIKit

class DetailView: UIView {
    
    var text: String {
        return textView.text
    }
    private var textView: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialize() {
        initializeView()
        initializeConstraints()
    }
    
    private func initializeView() {
        textView = UITextView()
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textView)
    }
    
    private func initializeConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leftAnchor.constraint(equalTo: leftAnchor),
            textView.rightAnchor.constraint(equalTo: rightAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func adjustForKeyboard(offset: UIEdgeInsets) {
        textView.contentInset = offset
        textView.scrollIndicatorInsets = textView.contentInset

        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    func setText(_ text: String) {
        textView.text = text
    }
}
