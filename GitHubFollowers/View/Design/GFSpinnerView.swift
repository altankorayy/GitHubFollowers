//
//  GFSpinnerView.swift
//  GitHubFollowers
//
//  Created by Altan on 6.02.2024.
//

import UIKit

final class GFSpinnerView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
        configureSpinnerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func configureView() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
    }
    
    private func configureSpinnerView() {
        let spinnerView = UIActivityIndicatorView(style: .large)
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinnerView)
        
        spinnerView.startAnimating()
        
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

}
