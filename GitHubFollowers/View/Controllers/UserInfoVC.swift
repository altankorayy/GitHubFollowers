//
//  UserInfoVC.swift
//  GitHubFollowers
//
//  Created by Altan on 30.01.2024.
//

import UIKit

class UserInfoVC: UIViewController {
    
    var username: String?
    private let viewModel: UserInfoVM
    
    let headerView = UIView()
    
    init(viewModel: UserInfoVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        view.addSubview(headerView)
        
        viewModel.getUserInfo()
        
        configureNavigationBar()
        configureConstraints()
    }
    
    private func configureNavigationBar() {
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(didTapDoneButton))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc
    private func didTapDoneButton() {
        dismiss(animated: true)
    }
    
    func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    
    private func configureConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180)
        ])
    }
    
}

extension UserInfoVC: UserInfoOutput {
    func updateView(_ model: User) {
        DispatchQueue.main.async {
            self.add(childVC: GFUserInfoHeaderVC(user: model), to: self.headerView)
        }
    }
    
    func error(_ error: String) {
        print(error)
    }
}
