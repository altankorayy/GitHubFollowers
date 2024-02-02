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
    let itemViewFirst = UIView()
    let itemViewSecond = UIView()
    
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
        view.addSubviews(headerView, itemViewFirst, itemViewSecond)
        
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
        itemViewFirst.translatesAutoresizingMaskIntoConstraints = false
        itemViewSecond.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 20),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewFirst.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            itemViewFirst.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            itemViewFirst.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            itemViewFirst.heightAnchor.constraint(equalToConstant: 140),
            
            itemViewSecond.topAnchor.constraint(equalTo: itemViewFirst.bottomAnchor, constant: 20),
            itemViewSecond.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            itemViewSecond.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            itemViewSecond.heightAnchor.constraint(equalToConstant: 140),
        ])
    }
    
}

extension UserInfoVC: UserInfoOutput {
    func updateView(_ model: User) {
        DispatchQueue.main.async {
            self.add(childVC: GFUserInfoHeaderVC(user: model), to: self.headerView)
            self.add(childVC: GFRepoItemInfoVC(user: model), to: self.itemViewFirst)
            self.add(childVC: GFFollowerItemVC(user: model), to: self.itemViewSecond)
        }
    }
    
    func error(_ error: String) {
        print(error)
    }
}
