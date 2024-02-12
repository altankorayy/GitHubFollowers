//
//  GFDataLoadingVC.swift
//  GitHubFollowers
//
//  Created by Altan on 7.02.2024.
//

import UIKit

class GFDataLoadingVC: UIViewController {
    
    var spinnerView = GFSpinnerView()
    
    public func showSpinnerView() {
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        
        spinnerView.alpha = 0
        
        UIView.animate(withDuration: 0.35) {
            self.spinnerView.alpha = 0.8
        }
        
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinnerView.widthAnchor.constraint(equalToConstant: 100),
            spinnerView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    public func dismissSpinnerView() {
        DispatchQueue.main.async {
            self.spinnerView.removeFromSuperview()
        }
    }
    
    public func showEmptyStateView(with message: String, in view: UIView) {
        let emptyStateView = GFEmptyStateView(message: message)
        emptyStateView.frame = view.bounds
        view.addSubview(emptyStateView)
    }
    
}
