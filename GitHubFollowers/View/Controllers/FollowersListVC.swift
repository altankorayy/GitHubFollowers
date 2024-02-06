//
//  FollowersListVC.swift
//  GitHubFollowers
//
//  Created by Altan on 18.01.2024.
//

import UIKit

class FollowersListVC: UIViewController {
    
    enum Section { //Hashable
        case main
    }
    
    private var activityIndicator = UIActivityIndicatorView()
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!
    
    private var username: String?
    private var page = 1
    private var hasMoreFollowers = true
    private var isSearching = false
    
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var userInfo: User?
    
    private let viewModel: FollowersListVM
    
    private let spinnerView = GFSpinnerView()
    
    init(viewModel: FollowersListVM) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        viewModel.fetchFollowers()
        viewModel.getUserInfo()
        
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        configureNavigationBar()
        configureSpinnerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createThreeColumnFlowLayout())
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowersCell.self, forCellWithReuseIdentifier: FollowersCell.identifier)
    }
    
    func createThreeColumnFlowLayout() -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let padding: CGFloat = 12
        let minimumItemSpacing: CGFloat = 10
        
        let availableWidth = width - (padding * 2) - (minimumItemSpacing * 2)
        let itemWidth = availableWidth / 3
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth + 40)
        
        return flowLayout
    }
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView, cellProvider: { collectionView, indexPath, follower in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowersCell.identifier, for: indexPath) as? FollowersCell else { return UICollectionViewCell() }
            cell.set(followers: follower)
            return cell
        })
    }
    
    func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search for a username"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func configureSpinnerView() {
        spinnerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spinnerView)
        
        spinnerView.alpha = 0
        
        NSLayoutConstraint.activate([
            spinnerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinnerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            spinnerView.widthAnchor.constraint(equalToConstant: 100),
            spinnerView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func startAnimating() {
        UIView.animate(withDuration: 0.4) {
            self.spinnerView.alpha = 1
        }
    }
    
    private func stopAnimating() {
        UIView.animate(withDuration: 0.7) {
            self.spinnerView.alpha = 0
        }
    }
    
    @objc
    private func didTapAddButton() {
        guard let login = userInfo?.login, let avatarUrl = userInfo?.avatar_url else { return }
        let favorite = Follower(login: login, avatar_url: avatarUrl)
        
        PersistanceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                self.presentGFAlertOnMainThread(title: "Success!", message: "You have successfully favorited this user 🎉", buttonTitle: "Hooray!")
                return
            }
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
        }
    }
    
    func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async { [weak self] in
            self?.dataSource.apply(snapshot, animatingDifferences: true)
        }
        startAnimating()
    }
    
    func emptyState() {
        let message = "This user doesn't have any followers. Go follow them 😀."
        
        DispatchQueue.main.async {
            self.showEmptyStateView(with: message, in: self.view)
        }
    }
}

extension FollowersListVC: FollowersListVMOutput {
    func error(_ error: String) {
        presentGFAlertOnMainThread(title: "Bad Stuff Happend", message: error, buttonTitle: "OK")
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func updateView(_ model: [Follower]) {
        guard !model.isEmpty else { return }
        
        self.followers.append(contentsOf: model)
        updateData(on: followers)
    }
    
    func getUserInfo(_ model: User) {
        self.userInfo = model
    }
    
    func emptyStateContol() {
        emptyState()
    }
}

extension FollowersListVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > (contentHeight - height) {
            guard hasMoreFollowers else { return }
            
            stopAnimating()
            
            viewModel.page += 1
            viewModel.fetchFollowers()

            viewModel.paginationFinished = { [weak self] in
                guard let self = self else { return }
                
                self.hasMoreFollowers = false
                startAnimating()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]
        
        let userService: UserService = NetworkManager()
        let userInfoVM = UserInfoVM(userService: userService, username: follower.login)
        let destinationVC = UserInfoVC(viewModel: userInfoVM)
        let navController = UINavigationController(rootViewController: destinationVC)
        present(navController, animated: true)
    }
}

extension FollowersListVC: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            updateData(on: followers)
            isSearching = false
            return
        }
        
        isSearching = true
        
        filteredFollowers = followers.filter({ $0.login.lowercased().contains(filter.lowercased()) })
        updateData(on: filteredFollowers)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
}

