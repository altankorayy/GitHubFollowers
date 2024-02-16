//
//  GFTextField.swift
//  GitHubFollowers
//
//  Created by Altan on 17.01.2024.
//

import UIKit

final class GFTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 12
        layer.borderWidth = 2
        layer.borderColor = UIColor.systemGray4.cgColor
        tintColor = .label
        textColor = .label
        adjustsFontSizeToFitWidth = true
        backgroundColor = .tertiarySystemBackground
        autocorrectionType = .no
        placeholder = "Enter a username"
        textAlignment = .center
        returnKeyType = .go
        minimumFontSize = 12
        clearButtonMode = .whileEditing
    }
}
