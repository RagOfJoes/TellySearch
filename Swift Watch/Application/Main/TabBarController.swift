//
//  ViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit
import Kingfisher

class TabBarController: UITabBarController {
    let floatingTabBarView: FloatingTabBarView = FloatingTabBarView(items: ["movies", "shows"], backgroundColor: UIColor(named: "tabBarColor"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set KingFisher Cache to only store images for a max of 1 day
        KingfisherManager.shared.cache.diskStorage.config.expiration = StorageExpiration.days(1)
        
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
        floatingTabBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -45).isActive = true
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
        navController.tabBarItem.title = title
        navController.navigationBar.isTranslucent = false
        navController.navigationBar.prefersLargeTitles = true
        navController.navigationBar.barTintColor = UIColor(named: "backgroundColor")
        
        // Shadow
        navController.navigationBar.layer.borderColor = UIColor.black.cgColor
        
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

extension TabBarController: UINavigationControllerDelegate {
    
}
