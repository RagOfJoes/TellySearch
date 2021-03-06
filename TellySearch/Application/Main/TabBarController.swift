//
//  ViewController.swift
//  TellySearch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher

class TabBarController: UITabBarController {
    private lazy var floatingTabBarView: FloatingTabBarView = {
        let floatingTabBarView: FloatingTabBarView = FloatingTabBarView(items: ["movies", "shows", "search"], shouldBlur: false)
        floatingTabBarView.backgroundColor = UIColor(named: "tabBarColor")
        return floatingTabBarView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set KingFisher Cache to only store images for a max of 1 day
        // KingfisherManager.shared.cache.clearCache()
        // KingfisherManager.shared.cache.diskStorage.config.expiration = StorageExpiration.days(1)
        
        // do {
        //    try C.Movie?.removeAll()
        //    try C.Person?.removeAll()
        //    try C.Season?.removeAll()
        //    try C.Show?.removeAll()
        //    print("Cleared Cache")
        // } catch {
        //    print("Failed to clear cache")
        // }
        
        setupView()
        
        setupTabItems()
        setupTabBar()
    }
    
    // MARK: - Setup Main View
    private func setupView() {
        view.backgroundColor = UIColor(named: "backgroundColor")
    }
    
    // MARK: - Setup Tab Bar
    private func setupTabBar() {
        tabBar.isHidden = true
        
        floatingTabBarView.delegate = self
        view.addSubview(floatingTabBarView)
        
        floatingTabBarView.hideTabBar(false)
        floatingTabBarView.centerXInSuperview()
        
        // Apply Floating Effect by lifting Tab Bar up
        floatingTabBarView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15).isActive = true
    }
    
    // MARK: - Setup Tab Items
    private func setupTabItems() {
        let moviesVC = createNavViewController(viewController: MoviesViewController(), title: "Movies")
        
        let showsVC = createNavViewController(viewController: ShowsViewController(), title: "Shows")
        
        let tabBarList = [moviesVC, showsVC]
        
        viewControllers = tabBarList
    }
    
    private func createNavViewController(viewController: UIViewController, title: String) -> UIViewController {
        let navController = UINavigationController(rootViewController: viewController)
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.tintColor = .systemOrange
        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.layer.borderColor = UIColor.clear.cgColor
        navController.navigationBar.barTintColor = UIColor(named: "backgroundColor")?.withAlphaComponent(0.2)
        
        viewController.navigationItem.title = title
        
        return navController
    }
}

extension TabBarController: FloatingTabBarViewDelegate {
    func did(selectIndex: Int) {
        selectedIndex = selectIndex
    }
    
    func hideTabBar(hide: Bool) {
        floatingTabBarView.hideTabBar(hide)
    }
}
