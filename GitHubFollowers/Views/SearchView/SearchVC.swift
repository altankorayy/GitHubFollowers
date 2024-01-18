//
//  SearchViewController.swift
//  GitHubFollowers
//
//  Created by Altan on 17.01.2024.
//

import UIKit

protocol TextFieldTextDelegate: AnyObject {
    func textFieldText(_ text: String)
}

class SearchVC: UIViewController {
    
    private let logoImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.image = UIImage(named: "gh-logo")
        return image
    }()
    
    private let usernameTextField = GFTextField()
    private let getFollowersButton = GFButton(backgroundColor: .systemGreen, title: "Get Followers")
    
    weak var delegate: TextFieldTextDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubviews(logoImage, usernameTextField, getFollowersButton)
        
        usernameTextField.delegate = self
        getFollowersButton.addTarget(self, action: #selector(pushFollowersListVC), for: .touchUpInside)
        
        configureConstraints()
        createDismissKeyboardTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    @objc
    private func pushFollowersListVC() {
        guard let text = usernameTextField.text, !text.isEmpty else {
            presentGFAlertOnMainThread(title: "Empty Username", message: "Please enter a username. We need to know who to look for 😀", buttonTitle: "OK")
            return
        }
        let followersListVC = FollowersListVC()
        guard let text = usernameTextField.text else { return }
        self.delegate?.textFieldText(text)
        followersListVC.title = text
        navigationController?.pushViewController(followersListVC, animated: true)
    }
    
    private func createDismissKeyboardTapGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            logoImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            logoImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImage.heightAnchor.constraint(equalToConstant: 200),
            logoImage.widthAnchor.constraint(equalToConstant: 200),
            
            usernameTextField.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 48),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            
            getFollowersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            getFollowersButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            getFollowersButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            getFollowersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

}

extension SearchVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pushFollowersListVC()
        return true
    }
}
