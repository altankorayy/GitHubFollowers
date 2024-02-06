//
//  GFSpinnerView.swift
//  GitHubFollowers
//
//  Created by Altan on 6.02.2024.
//

import UIKit

class GFSpinnerView: UIView {

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
