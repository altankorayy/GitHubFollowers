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
    let dateLabel = GFBodyLabel(textAlignment: .center)
    
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
        view.addSubviews(headerView, itemViewFirst, itemViewSecond, dateLabel)
        
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
            headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: 30),
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
            
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dateLabel.topAnchor.constraint(equalTo: itemViewSecond.bottomAnchor, constant: 20),
            dateLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
}

extension UserInfoVC: UserInfoOutput {
    func updateView(_ model: User) {
        DispatchQueue.main.async {
            let repoItemVC = GFRepoItemInfoVC(user: model)
            repoItemVC.delegate = self
            
            let followerItemVC = GFFollowerItemVC(user: model)
            followerItemVC.delegate = self
            
            self.add(childVC: GFUserInfoHeaderVC(user: model), to: self.headerView)
            self.add(childVC: repoItemVC, to: self.itemViewFirst)
            self.add(childVC: followerItemVC, to: self.itemViewSecond)
            self.dateLabel.text = "GitHub since \(model.created_at.convertToDisplayFormat())"
        }
    }
    
    func error(_ error: String) {
        print(error)
    }
}

extension UserInfoVC: UserInfoVCDelegate {
    func didTapGithubProfile(for user: User) {
        guard let url = URL(string: user.html_url) else {
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The url attached to this user is invalid.", buttonTitle: "OK")
            return
        }
        presentSafariVC(with: url)
    }
    
    func didTapGetFollowers(for user: User) {
        guard user.followers != 0 else {
            presentGFAlertOnMainThread(title: "No Followers", message: "This user has no followers. What a shame 😔", buttonTitle: "So sad")
            return
        }
        
        let userService: UserService = NetworkManager()
        let viewModel = FollowersListVM(userService: userService, username: user.login)
        let followersListVC = FollowersListVC(viewModel: viewModel)
        
        followersListVC.title = user.login
        navigationController?.pushViewController(followersListVC, animated: true)
    }
}
