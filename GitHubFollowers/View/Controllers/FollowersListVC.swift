//
//  FollowersListVC.swift
//  GitHubFollowers
//
//  Created by Altan on 18.01.2024.
//

import UIKit

class FollowersListVC: GFDataLoadingVC {
    
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
    private var isLoadingMoreFollowers = false
    
    var followers: [Follower] = []
    var filteredFollowers: [Follower] = []
    var userInfo: User?
    
    private let viewModel: FollowersListVM
        
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
        
        configureCollectionView()
        configureDataSource()
        configureSearchController()
        configureNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.fetchFollowers()
        viewModel.getUserInfo()
        
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
        searchController.searchBar.placeholder = "Search for a username"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func configureNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItem = addButton
    }
    
    @objc
    private func didTapAddButton() {
        guard let login = userInfo?.login, let avatarUrl = userInfo?.avatar_url else { return }
        let favorite = Follower(login: login, avatar_url: avatarUrl)
        
        PersistanceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self else { return }
            guard let error else {
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
    }
    
    func emptyState() {
        let message = "This user doesn't have any followers. Go follow them 😀."
        DispatchQueue.main.async {
            self.showEmptyStateView(with: message, in: self.view)
        }
    }
}

extension FollowersListVC: FollowersListVMOutput {
    func updateView(_ model: [Follower]) {
        guard !model.isEmpty else { return }
        
        self.followers.append(contentsOf: model)
        updateData(on: followers)
    }
    
    func getUserInfo(_ model: User) {
        self.userInfo = model
    }
    
    func error(_ error: String) {
        presentGFAlertOnMainThread(title: "Bad Stuff Happend", message: error, buttonTitle: "OK")
        
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func presentDefaultErrorDelegate() {
        presentDefaultError()
    }
    
    func emptyStateContol() {
        emptyState()
    }
    
    func showActivityIndicator(_ state: Bool) {
        if state {
            showSpinnerView()
        } else {
            dismissSpinnerView()
        }
    }
    
}

extension FollowersListVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let height = scrollView.frame.size.height
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > (contentHeight - height) {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            
            viewModel.page += 1
            viewModel.fetchFollowers()

            viewModel.paginationFinished = { [weak self] in
                guard let self else { return }
                
                self.hasMoreFollowers = false
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

extension FollowersListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        isLoadingMoreFollowers = true
        
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            updateData(on: followers)
            isSearching = false
            return
        }
        
        isSearching = true
        
        filteredFollowers = followers.filter({ $0.login.lowercased().contains(filter.lowercased()) })
        updateData(on: filteredFollowers)
        
        isLoadingMoreFollowers = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        updateData(on: followers)
    }
}

