//
//  GFItemInfoVC.swift
//  GitHubFollowers
//
//  Created by Altan on 2.02.2024.
//

import UIKit

class GFItemInfoVC: UIViewController {
    
    let stackView = UIStackView()
    let itemInfoViewFirst = GFItemInfoView()
    let itemInfoViewSecond = GFItemInfoView()
    let actionButton = GFButton()
    
    var user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureBackgroundView()
        layoutUI()
        configureStackView()
    }
    
    private func configureBackgroundView() {
        view.layer.cornerRadius = 18
        view.clipsToBounds = true
        view.backgroundColor = .secondarySystemBackground
    }
    
    private func configureStackView() {
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.addArrangedSubview(itemInfoViewFirst)
        stackView.addArrangedSubview(itemInfoViewSecond)
    }
    
    private func layoutUI() {
        view.addSubviews(stackView, actionButton)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.heightAnchor.constraint(equalToConstant: 50),
            
            actionButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

}
