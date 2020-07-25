//
//  ViewController.swift
//  Swift Watch
//
//  Created by Victor Ragojos on 7/23/20.
//  Copyright © 2020 Victor Ragojos. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    let floatingTabBarView: FloatingTabBarView = FloatingTabBarView(items: ["movies", "shows"], backgroundColor: UIColor(named: "tabBarColor"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let moviesVC = createNavViewController(viewController: MoviesViewController(), title: "Movies", imageName: "movies")
        
        let showsVC = createNavViewController(viewController: ShowsViewController(), title: "Shows", imageName: "shows")
        
        let tabBarList = [moviesVC, showsVC]
        
        viewControllers = tabBarList
    }
    
    private func createNavViewController(viewController: UIViewController, title: String, imageName: String) -> UIViewController {

           viewController.navigationItem.title = title

           let navController = UINavigationController(rootViewController: viewController)
           navController.navigationBar.prefersLargeTitles = true
           navController.tabBarItem.title = title
           navController.tabBarItem.image = UIImage(named: imageName)

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
